class NodeViewsWorker
  include Sidekiq::Worker

  sidekiq_options debounce: true

  def perform
    NodeInheritedAuthzRead.refresh
  end
end
