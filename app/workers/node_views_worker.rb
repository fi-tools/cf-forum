class NodeViewsWorker
  include Sidekiq::Worker

  sidekiq_options debounce: true

  def perform
    NodeDescendant.refresh
    NodeInheritedAuthzRead.refresh
  end
end
