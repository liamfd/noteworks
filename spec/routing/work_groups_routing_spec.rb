require "spec_helper"

describe WorkGroupsController do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/work_groups").to route_to("work_groups#index")
    end

    it "routes to #new" do
      expect(:get => "/work_groups/new").to route_to("work_groups#new")
    end

    it "routes to #show" do
      expect(:get => "/work_groups/1").to route_to("work_groups#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/work_groups/1/edit").to route_to("work_groups#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/work_groups").to route_to("work_groups#create")
    end

    it "routes to #update" do
      expect(:put => "/work_groups/1").to route_to("work_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/work_groups/1").to route_to("work_groups#destroy", :id => "1")
    end

  end
end
