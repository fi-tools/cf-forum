class AuthorsController < ApplicationController
  before_action :set_author, only: [:show]

  helper_method :current_user

  def show
  end

  def mine
  end

  private

  def set_author
    @author = Author.find(params[:id])
    @posts = Node.joins(:readable_by_users).where("nodes_readables.user_id = ?", (current_user ? current_user.id : nil)).joins(:content).where("content_versions.author_id = ?", @author.id).includes(:content)
  end
end
