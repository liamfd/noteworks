require 'spec_helper'

describe Work do
	it "can be instantiated" do
    	Work.new.should be_an_instance_of(Work)
  	end

  	describe modify_element do

  		before :each do
  		end

  		context "inserting node" do
  		end

  		context "inserting note" do

  			it "uses the existing note if possible" do

  			end

  			it "doesn't creates a new note if there wasn't one before" do

  			end
  		end
  	end
end