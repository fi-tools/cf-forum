class NodesController < ApplicationController
  before_action :set_node, only: [:show, :edit, :update, :destroy, :subtree]
  before_action :set_parent, only: [:new, :new_comment]
  before_action :set_node_to_children_map, only: [:show, :subtree]
  before_action :authenticate_user!, only: [:new, :new_comment, :create]

  # GET /nodes
  # GET /nodes.json
  def index
    # TODO: permissions
    set_node_to_root
  end

  # GET /nodes/1
  # GET /nodes/1.json
  def show
    # TODO: permissions
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

  # # GET /nodes/1/edit
  # def edit
  # end

  # POST /nodes
  # POST /nodes.json
  def create
    # TODO: permissions
    params = node_params
    @parent_id = params[:parent_id]
    node_params = params.slice(:parent_id)
    cv_params = params.slice(:title, :body)
    author_params = params.slice(:name)

    @author = Author.find_or_create_by(**author_params.merge(:user => current_user))
    @node = Node.new(node_params.merge :author => @author)
    @cv = ContentVersion.new(cv_params.merge :node => @node, :author => @author)

    respond_to do |format|
      if @author.save! and @node.save! && @cv.save!
        format.html { redirect_to @node, notice: "Node was successfully created." }
        format.json { render :show, status: :created, location: @node }
      else
        format.html { render :new, :parent_id => @parent_id }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # # PATCH/PUT /nodes/1
  # # PATCH/PUT /nodes/1.json
  # def update
  #   respond_to do |format|
  #     if @node.update(node_params)
  #       format.html { redirect_to @node, notice: "Node was successfully updated." }
  #       format.json { render :show, status: :ok, location: @node }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @node.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /nodes/1
  # # DELETE /nodes/1.json
  # def destroy
  #   @node.destroy
  #   respond_to do |format|
  #     format.html { redirect_to nodes_url, notice: "Node was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_node
    @node = Node.find(params[:id])
  end

  def set_parent(parent_id = params[:parent_id])
    @parent_id = parent_id
  end

  def set_node_to_root
    @node = Node.find(0)
  end

  def set_node_to_children_map
    tree = [@node] + @node.children_rec(true)
    @node_id_to_children = Hash.new { |h, k| h[k] = Array.new }
    puts tree.select
    tree.each do |n|
      @node_id_to_children[n.id] += (tree.select { |n2| n2.parent_id == n.id })
      # n.direct_children = @tree.select(->(n2) { n2.parent.id == n.id })
    end
  end

  def children_of(node_id)
    Node.find(node_id).children_rec
  end

  # Only allow a list of trusted parameters through.
  def node_params
    params.require(:node).permit(:parent_id, :title, :body, :name)
  end
end
