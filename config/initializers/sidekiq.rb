Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Debounce
  end

  config.redis = { url: "redis://host.docker.internal:6379/0" }
end

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://host.docker.internal:6379/0" }
end
