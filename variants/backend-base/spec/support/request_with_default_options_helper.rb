module RequestWithDefaultOptionsHelper
  def default_options
    @default_options ||= {}.with_indifferent_access
  end

  def get(path, **options)
    super(path, **default_options.deep_merge(options).symbolize_keys)
  end

  def post(path, **options)
    super(path, **default_options.deep_merge(options).symbolize_keys)
  end

  def put(path, **options)
    super(path, **default_options.deep_merge(options).symbolize_keys)
  end

  def patch(path, **options)
    super(path, **default_options.deep_merge(options).symbolize_keys)
  end

  def delete(path, **options)
    super(path, **default_options.deep_merge(options).symbolize_keys)
  end
end

RSpec.configure do |config|
  config.include(RequestWithDefaultOptionsHelper, type: :request)
end
