class WorksController < ApplicationController

  # GET /works
  # GET /works.json
  def index
  	@works = Work.all
  end

  # GET /works/1
  # GET /works/1.json
  def show
  end
end
