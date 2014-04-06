require 'spec_helper'

describe "work_groups/show" do
  before(:each) do
    @work_group = assign(:work_group, stub_model(WorkGroup,
      :name => "Name",
      :user_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1/)
  end
end
