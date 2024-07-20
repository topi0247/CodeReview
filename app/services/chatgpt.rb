class Chatgpt
  include HTTParty

  attr_reader :api_url, :options, :model, :message
  def initialize(message, model = 'gpt-4o-mini')
    api_key = ENV['OPENAI_API_KEY']
    @options = {
      headers:  {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{api_key}"
      }
    }
    @api_url = 'https://api.openai.com/v1/chat/completions'
    @model = model
    @message = message
  end

  def call
    body = {
      model: model,
      messages: [{role: 'user', content: message}]
    }
    response = HTTParty.post(api_url, body: body.to_json, **options, timeout: 100)
    raise response['error']['message'] unless response.code == 200
    response['choices'][0]['message']['content']
  end

  class << self
    def call(message, model = 'gpt-4o-mini')
      new(message, model).call
    end
  end
end
