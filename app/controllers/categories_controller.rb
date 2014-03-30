class CategoriesController < ApplicationController
  before_action :set_node, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json

  # GET /nodes
  # GET /nodes.json
  def index
    @categories = Category.all
  end

  # GET /nodes/1
  # GET /nodes/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_node
      @category = Category.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def node_params
      params.require(:category).permit(:name, :color)
    end
end