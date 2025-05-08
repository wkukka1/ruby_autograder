class GeminiGrader
  include HTTParty
  base_uri ENV.fetch('GEMINI_API_URL', 'https://gemini.googleapis.com')

  def initialize(content:, assignment_type:)
    @content = content
    @type = assignment_type
    @api_key = ENV.fetch('GEMINI_API_KEY')
  end

  def grade
    prompt = build_prompt
    response = self.class.post(
      "/v1beta2/models/text-bison-001:generateMessage",
      headers: { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{@api_key}" },
      body: {
        prompt: { text: prompt },
        temperature: 0.2,
        candidate_count: 1
      }.to_json
    )
    parse_response(response)
  end

  private

  def build_prompt
    <<~PROMPT
      You are an expert grader. Grade the following #{@type} submission. Provide:
      1. A grade from 0 to 100.
      2. Detailed feedback on strengths and weaknesses.
      3. Suggestions for improvement.

      Submission:
      #{@content}
    PROMPT
  end

  def parse_response(response)
    data = JSON.parse(response.body)
    candidate = data.dig('candidates', 0, 'content')
    { raw: candidate }
  end
end
