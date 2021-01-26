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
    @posts = Node.get_nodes_readable_by(current_user) { |q| where("author_id = #{author.id}") }
      .joins(:content_versions)
  end
end
