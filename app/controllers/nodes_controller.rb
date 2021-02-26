class NodesController < ApplicationController
  before_action :set_user
  before_action :set_node, only: []
  before_action :set_parent, only: [:new, :new_comment]
  before_action :set_node_to_children_map, only: [:show, :subtree, :view_as, :focus]
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

  # GET /focus/:node/on/:id
  def focus
    ancestors_map, @node = Node.ancestors_until_parent(params[:id], params[:node])
    if @node.nil?
      raise ActiveRecord::RecordNotFound, "Parent node (id: #{params[:id]}) does not connect to child node (id: #{params[:node]})."
    end
    @children_lookup = @children_lookup.merge(ancestors_map)
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
    # TODO: permissions (allowed to create child?)
    safe_params = new_node_params
    @parent = Node.find(safe_params[:parent_id].to_i)
    node_params = safe_params.slice(:parent_id)
    cv_params = safe_params.slice(:title, :body)
    author_params = { id: safe_params[:author_id].to_i, user: current_user }
    tag_decl_ids = safe_params[:tag_decl_ids]

    @author = Author.where(**author_params).first
    @node = Node.new(node_params.merge :author => @author)
    @cv = ContentVersion.new(cv_params.merge :node => @node, :author => @author)
    @tags = []
    if !tag_decl_ids.nil? 
      tag_decl_ids.each do |anchored_tag|
        @anchored_tag_decl = TagDecl.find(anchored_tag)
        @tag_decl = TagDecl.new(:user => @user, :target => @node, :anchored => @anchored_tag_decl, :tag => "include_" + @anchored_tag_decl.tag)
        @tags << @tag_decl
      end
    end

    respond_to do |format|
      begin 
        ActiveRecord::Base.transaction do 
          @author.save!
          @node.save! 
          @cv.save!
          @tags.each &:save! 
          format.html { redirect_to @node, notice: "Node was successfully created." }
          format.json { render :show, status: :created, location: @node }
        end
      rescue ActiveRecord::ActiveRecordError => e
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
    _, @children_lookup, @parent = Node.children_rec_arhq(parent_id, @user, limit_nodes_lower: 1)
  end

  # this sets both @node and @node_id_to_children
  def set_node_to_children_map(id = params[:id].to_i)
    # we want to set @node after calling children_rec_arhq so we check permissions
    _, @children_lookup, @node = Node.children_rec_arhq(id, current_user)
    if @node.nil?
      raise ActiveRecord::RecordNotFound, "Node(id: #{id}) not found."
    end
  end

  # Only allow a list of trusted parameters through.
  def new_node_params
    params.require(:node).permit(:parent_id, :title, :body, :author_id, tag_decl_ids:[])
  end
end
