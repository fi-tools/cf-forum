class NodesController < ApplicationController
  before_action :set_user_id
  before_action :set_node, only: [:show, :edit, :update, :destroy, :subtree, :view_as]
  before_action :set_parent, only: [:new, :new_comment]
  before_action :set_node_to_children_map, only: [:show, :subtree, :view_as]
  before_action :authenticate_user!, only: [:new, :new_comment, :create]

  helper_method :current_user

  # GET /nodes
  # GET /nodes.json
  def index
    # TODO: permissions
    @node = Node.root
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

  # # GET /nodes/1/edit
  # def edit
  # end

  # POST /nodes
  # POST /nodes.json
  def create
    # TODO: permissions
    safe_params = new_node_params
    @parent_id = safe_params[:parent_id]
    node_params = safe_params.slice(:parent_id)
    cv_params = safe_params.slice(:title, :body)
    author_params = safe_params.slice(:name)

    @author = Author.find_or_create_by(**author_params.merge(:user => current_user))
    @node = Node.new(node_params.merge :author => @author)
    @cv = ContentVersion.new(cv_params.merge :node => @node, :author => @author)

    respond_to do |format|
      if @author.save! && @node.save! && @cv.save!
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
  def set_user_id
    @user_id = current_user&.id
  end

  def set_node
    @node = Node.find(params[:id])
    can_read = @node.who_can_read
    unless can_read.include? "all"
      authenticate_user!
      overlap = can_read & current_user.groups
      if overlap.count == 0
        redirect_to root_path, :notice => "No permissions to view."
      end
    end
  end

  def set_parent(parent_id = params[:parent_id])
    # todo: is set_parent okay like this?
    # i understand set_node is like okay in ruby/rails conventions - MK
    @parent_id = parent_id
  end

  def set_node_to_children_map
    @node_id_to_children = @node.descendants_map(@user_id)
  end

  # Only allow a list of trusted parameters through.
  def new_node_params
    params.require(:node).permit(:parent_id, :title, :body, :name)
  end
end
