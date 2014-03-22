require 'spec_helper'

describe LinkCollection do
  it "has a valid factory" do
  	expect(FactoryGirl.build(:link_collection)).to be_valid
  end

  it "is invalid without a node" do
  	expect(FactoryGirl.build(:link_collection, node: nil)).not_to be_valid
  end

  describe "add_links" do

  	before :each do
  		@macbeth = FactoryGirl.build(:node, title: "Macbeth")
  		@macduff = FactoryGirl.build(:node, title: "MacDuff")
  		@macbeth = FactoryGirl.build(:node, title: "Banquo")
  		@link_coll = FactoryGirl.build(:link_collection)
  	end

  	it "takes text array and returns links" do
  		@link_coll.add_links("MacBeth, MacDuff, Banquo")
  		expect(@link_coll.links).not_to be_empty
  	end

  	it "takes empty text array and returns no links" do
  		@link_coll.add_links("")
  		expect(@link_coll.links).to be_empty
  	end

  	it "takes incorrect text array and returns no links" do
  	end
	
	it "takes text array and returns correct links" do
  	end


  end

end
