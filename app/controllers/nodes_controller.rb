class NodesController < ApplicationController
  before_action :set_user
  before_action :set_node, only: []
  before_action :set_parent, only: [:new, :new_comment]
  before_action :set_node_to_children_map, only: [:show, :subtree, :view_as]
  before_action :authenticate_user!, only: [:new, :new_comment, :create]

  helper_method :current_user

  # GET /nodes
  # GET /nodes.json
  def index
    set_node_to_children_map(0)
  end

  # GET /nodes/1
  # GET /nodes/1.json
  def show
    # TODO: permissions
  end

  # GET /view_as/:view_name/:id
  def view_as
    @view_type = params[:view_name]
  end

  def subtree
    # TODO: permissions
  end

  # GET /nodes/new
  def new
    # TODO: permissions
    @node = Node.new
  end

  def new_comment
    # TODO: permissions
    @node = Node.new
  end

  # POST /nodes
  # POST /nodes.json
  def create
    # TODO: permissions
    safe_params = new_node_params
    @parent = Node.find(safe_params[:parent_id].to_i)
    node_params = safe_params.slice(:parent_id)
    cv_params = safe_params.slice(:title, :body)
    author_params = { id: safe_params[:author_id].to_i }

    @author = Author.where(**author_params.merge(:user => current_user)).first
    @node = Node.new(node_params.merge :author => @author)
    @cv = ContentVersion.new(cv_params.merge :node => @node, :author => @author)

    respond_to do |format|
      if @author.save! && @node.save! && @cv.save!
        format.html { redirect_to @node, notice: "Node was successfully created." }
        format.json { render :show, status: :created, location: @node }
      else
        format.html { render :new, :parent_id => @parent.id }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  def count_descendants(node)
    cs = @node_id_to_children[node.id]
    cs.count + (cs.map { |c| count_descendants(c) }).sum
  end

  helper_method :count_descendants

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = current_user
  end

  # deprecated, use set_node_to_children_map
  def set_node
    @node = Node.find_readable(params[:id].to_i, current_user)
  end

  def set_parent(parent_id = params[:parent_id].to_i)
    # todo: is set_parent okay like this?
    # i understand set_node is like okay in ruby/rails conventions - MK
    @parent = Node.find_readable(parent_id, @user)
  end

  # this sets both @node and @node_id_to_children
  def set_node_to_children_map(id = params[:id].to_i)
    @node_id_to_children = Node.with_descendants_map(id, @user)
    @node = @node_id_to_children[-1].first
  end

  # Only allow a list of trusted parameters through.
  def new_node_params
    params.require(:node).permit(:parent_id, :title, :body, :author_id)
  end
end
