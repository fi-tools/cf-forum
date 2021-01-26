class AuthorsController < ApplicationController
  before_action :set_author, only: [:show]

  def show
  end

  def mine
  end

  private

  def set_author
    @author = Author.includes(posts: [:content_versions]).find(params[:id])
  end
end
