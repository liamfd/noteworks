class WorksController < ApplicationController
  before_action :set_work, only: [:show, :edit, :update, :destroy, :testnetwork, :takenotes, :updatenotes, 
    :mod_element, :add_element, :del_element, :category_list, :toggle_privacy]

  respond_to :html, :json, :js

  # GET /works
  # GET /works.json
  def index
    @works = Work.all
  end

  # GET /works/1
  # GET /works/1.json
  def show
  end

  # GET /work_group/new
  def new
    @work = Work.new
    @group = WorkGroup.find(params[:group_id])
    render(:layout => false)
  end

  # GET /work/1/edit
  def edit
    @group = WorkGroup.find(params[:group_id])
    render(:layout => false)
  end

  # POST /work
  # POST /work.json
  def create
    @work = Work.new(work_params)
    @group= WorkGroup.find(work_params[:group_id])
    binding.pry
    @works = @group.works

    @work.save #figure out why this is necessary later
    if @work.save
      respond_with @group, :layout => false
    else
      respond_with @work, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /works/1
  # PATCH/PUT /works/1.json
  def update
    @group= WorkGroup.find(work_params[:group_id])
    binding.pry
    @works = @group.works
    if @work.update(work_params)
      respond_with(@group, :layout => false )
    else
      respond_with @work, status: :unprocessable_entity
    end
  end

  # DELETE /work_groups/1
  # DELETE /work_groups/1.json
  def destroy
    @work.destroy
    @group = WorkGroup.find(params[:group_id])
    @works = @group.works

    respond_to do |format|
      format.js { render :layout=>false }
    end
  end

  # GET /works/1/takenotes
  def takenotes
    @nodes = @work.nodes
    @links = @work.links
    gon.rabl "app/views/works/show.json.rabl", as: "elements"
  end


  # PATCH/PUT /works/1
  # PATCH/PUT /works/1.json
  def updatenotes
    #@nodes = @work.nodes
    #@links = @work.links
    respond_to do |format|
      if @work.update(work_params)
        format.html { redirect_to action: 'takenotes'}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @work.errors, status: :unprocessable_entity }
      end
    end
  end

  def mod_element
    line_number = params[:line_number]
    line_content = params[:line_content]

    #wrap input in array if needed, map the vals to the correct type
    line_numbers = Array.wrap(line_number)
    line_contents = Array.wrap(line_content)
    line_numbers.map! { |num| num.to_i }
    line_contents.map! {|cont| cont.to_s}
    ##binding.pry

    modded_element_json = @work.modify_element(line_numbers, line_contents)
    gon.changed = @modded_element.to_json
   
    respond_to do |format|
      format.json {render :json => modded_element_json}
    end
  end

  def add_element
    line_number = params[:line_number]
    line_content = params[:line_content]
   
    #wrap input in array if needed, map the vals to the correct type
    line_numbers = Array.wrap(line_number)
    line_contents = Array.wrap(line_content)
    line_numbers.map! {|num| num.to_i}
    line_contents.map! {|cont| cont.to_s}
    #binding.pry

    @modded_element = @work.add_new_element(line_numbers, line_contents)
    gon.changed = @modded_element.to_json

    respond_to do |format|
      format.js {render :json => @modded_element}
    end
  end

  def del_element
    line_number = params[:line_number]

    #wrap input in array if needed, map the vals to the correct type
    line_numbers = Array.wrap(line_number)
    line_numbers.map! {|num| num.to_i}
   
    @modded_element = @work.delete_element(line_numbers)
    gon.changed = @modded_element.to_json

    respond_to do |format|
      format.js {render :json => @modded_element}
    end
  end

  #PATCH works/1/toggle_privacy
  def toggle_privacy
    if @work.toggle_privacy
      respond_with(@work, :layout => false)
    else
      respond_with @work, status: :unprocessable_entity
    end
  end

  def category_list
    @categories = @work.categories.where.not(name:"")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work
      @work = Work.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def work_params
      params.require(:work).permit(:markup, :group_id, :name)
    end
end
