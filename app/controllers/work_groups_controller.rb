class WorkGroupsController < ApplicationController
  before_action :set_work_group, only: [:show, :edit, :update, :destroy]

  respond_to :html, :json, :js

  # GET /work_groups
  # GET /work_groups.json
  def index
    @work_groups = WorkGroup.all
  end

  # GET /work_groups/1
  # GET /work_groups/1.json
  def show
  end

  # GET /work_group/new
  def new
    @work_group = WorkGroup.new
    @user = User.find(params[:user_id])
    render(:layout => false)
  end

  # GET /work_groups/1/edit
  def edit
    @user = User.find(params[:user_id])
    render(:layout => false)
  end

  # POST /work_group
  # POST /work_group.json
  def create
    @work_group = WorkGroup.new(work_group_params)
    @user= User.find(work_group_params[:user_id])
    @work_groups = @user.work_groups

    if @work_group.save
      respond_with(:layout => false )
    else
      respond_with @work_group, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    @user= User.find(work_group_params[:user_id])
    @work_groups = @user.work_groups

    if @work_group.update(work_group_params)
      respond_with(:layout => false )
    else
      respond_with @work_group, status: :unprocessable_entity
    end
  end

  # DELETE /work_groups/1
  # DELETE /work_groups/1.json
  def destroy
    @work_group.destroy
    @user = User.find(params[:user_id])
    @users = @user.work_groups

    respond_to do |format|
      format.js { render :layout=>false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work_group
      @work_group = WorkGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def work_group_params
      params.require(:work_group).permit(:name, :user_id)
    end
end
