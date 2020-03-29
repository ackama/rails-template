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
    ENV["HTTP_BASIC_AUTH_USERNAME"]
  end

  def password
    ENV["HTTP_BASIC_AUTH_PASSWORD"]
  end
end