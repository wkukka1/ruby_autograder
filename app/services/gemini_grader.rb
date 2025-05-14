class GeminiGrader
  include HTTParty
  base_uri 'https://generativelanguage.googleapis.com'

  def initialize(api_key:, model: ENV.fetch('GEMINI_MODEL', 'gemini-2.0-flash'))
    @api_key = api_key
    @model   = model
  end

  def grade(content:, assignment_type:)
    url = "/v1beta/models/#{@model}:generateContent?key=#{@api_key}"

    payload = {
      contents: [
        {
          parts: [{ text: build_prompt(content, assignment_type) }]
        }
      ],
      generationConfig: {
        temperature:     0.0,
        candidateCount:  1,
        maxOutputTokens: 512
      }
    }

    resp = self.class.post(
      url,
      headers: { 'Content-Type' => 'application/json' },
      body:    payload.to_json
    )

    puts "Gemini raw response:\n#{resp.body}\n\n"

    handle_errors!(resp)
    parse_response(JSON.parse(resp.body))
  end

  private

  def build_prompt(content, assignment_type)
    <<~PROMPT
      You are an expert grader.
      **Return raw JSON only** with keys (no markdown/code fences):
      - "grade"       (integer 0–100)
      - "feedback"    (string of strengths & weaknesses)
      - "suggestions" (string with concrete improvement tips)

      Grade this #{assignment_type} submission:

      #{content}
    PROMPT
  end

  def handle_errors!(response)
    return if response.success?
    err = JSON.parse(response.body)['error'] rescue response.body
    raise "Gemini API error (HTTP #{response.code}): #{err}"
  end

  def parse_response(body)
    raw = body.dig('candidates', 0, 'content', 'parts', 0, 'text') ||
          body.dig('choices',    0, 'message', 'content')

    json_str = raw
      .gsub(/\A```(?:json)?\s*/, '') 
      .gsub(/```+\z/, '') 
      .strip

    JSON.parse(json_str)
  end
end
