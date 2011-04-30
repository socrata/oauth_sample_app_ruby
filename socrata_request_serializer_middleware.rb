require 'json'
require 'faraday'

# the OAuth2 rubygem insists on adding the access_token to not only the header,
# but also in the http params, whether as a GET param on in the POST body. we
# don't want this behavior, because SODA only ever looks in the Authorization
# header, and can get confused if you attempt to give it a parameter of
# access_token when it isn't expecting it. luckily, the OAuth2 gem also uses
# faraday to send its requests, which means that we can easily supplant their
# behavior with our own if we add some middleware to filter the content before
# we send it off. that is what this class does; if we are authorized, set our
# content-type to be json for convenience, delete the access_token parameter
# from the params body, and the serialize the remainder (which we actually
# wanted to send) to json before sending it all off to SODA.

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
