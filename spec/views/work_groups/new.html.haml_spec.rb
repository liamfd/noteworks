require 'spec_helper'

describe "work_groups/new" do
  before(:each) do
    assign(:work_group, stub_model(WorkGroup,
      :name => "MyString",
      :user_id => 1
    ).as_new_record)
  end

  it "renders new work_group form" do
    render

    assert_select "form[action=?][method=?]", work_groups_path, "post" do
      assert_select "input#work_group_name[name=?]", "work_group[name]"
      assert_select "input#work_group_user_id[name=?]", "work_group[user_id]"
    end
  end
end
