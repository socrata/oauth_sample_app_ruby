require 'json'
require 'faraday'

class SocrataRequestSerializerMiddleware < Faraday::Middleware
  def call(env)
    # serialize to json, but only if we're already authorized.
    if env[:request_headers]['Authorization']
      env[:request_headers]['Content-Type'] = 'application/json'
      if env[:body] && (env[:body].is_a? Hash)
        env[:body].delete 'access_token' # socrata api uses headers; we don't want this
        env[:body] = env[:body].to_json
      end
    end

    @app.call env
  end
end
