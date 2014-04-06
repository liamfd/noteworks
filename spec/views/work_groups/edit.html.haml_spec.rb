require 'spec_helper'

describe "work_groups/edit" do
  before(:each) do
    @work_group = assign(:work_group, stub_model(WorkGroup,
      :name => "MyString",
      :user_id => 1
    ))
  end

  it "renders the edit work_group form" do
    render

    assert_select "form[action=?][method=?]", work_group_path(@work_group), "post" do
      assert_select "input#work_group_name[name=?]", "work_group[name]"
      assert_select "input#work_group_user_id[name=?]", "work_group[user_id]"
    end
  end
end
