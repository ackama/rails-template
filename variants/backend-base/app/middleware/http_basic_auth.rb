class HttpBasicAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    if username && password
      auth = Rack::Auth::Basic.new(@app) do |u, p|
        u == username && p == password
      end

      auth.call(env)
    else
      @app.call(env)
    end
  end

  def username
    ENV.fetch("HTTP_BASIC_AUTH_USERNAME", nil)
  end

  def password
    ENV.fetch("HTTP_BASIC_AUTH_PASSWORD", nil)
  end
end
