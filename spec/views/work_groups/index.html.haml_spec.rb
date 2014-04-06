require 'spec_helper'

describe "work_groups/index" do
  before(:each) do
    assign(:work_groups, [
      stub_model(WorkGroup,
        :name => "Name",
        :user_id => 1
      ),
      stub_model(WorkGroup,
        :name => "Name",
        :user_id => 1
      )
    ])
  end

  it "renders a list of work_groups" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
