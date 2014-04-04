class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :set_categories, only: [:index, :destroy, :create]

  respond_to :html, :json, :js

  # GET /categories
  # GET /categories.json
  def index
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
  end

  # GET /categories/new
  def new
    @category = Category.new
    render(:layout => false)
  end

  # GET /categories/1/edit
  def edit
    render(:layout => false)
  end

  # POST /categories
  # POST /categories.json
  def create
    #this will turn into @work.build.nodes? pass work_id?
    @category = Category.new(category_params)

    if @category.save
      respond_with(:layout => false )
    else
      respond_with @category, status: :unprocessable_entity
    end
 
    #if @category.save
    #  respond_with(:layout => !request.xhr? )
    #else
   #   format.json { render json: @category.errors, status: :unprocessable_entity }
  #  end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.json { render json: @category.to_json }
      else
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /category/1
  # DELETE /category/1.json
  def destroy
    @category.destroy
    respond_to do |format|
        format.js { render :layout=>false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    #do not allow them access to the default category
    def set_categories
      @categories = Category.where.not(name:"")
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:name, :color)
    end
end