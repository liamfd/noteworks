require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe WorkGroupsController do

  # This should return the minimal set of attributes required to create a valid
  # WorkGroup. As you add validations to WorkGroup, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "name" => "MyString" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # WorkGroupsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all work_groups as @work_groups" do
      work_group = WorkGroup.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:work_groups)).to eq([work_group])
    end
  end

  describe "GET show" do
    it "assigns the requested work_group as @work_group" do
      work_group = WorkGroup.create! valid_attributes
      get :show, {:id => work_group.to_param}, valid_session
      expect(assigns(:work_group)).to eq(work_group)
    end
  end

  describe "GET new" do
    it "assigns a new work_group as @work_group" do
      get :new, {}, valid_session
      expect(assigns(:work_group)).to be_a_new(WorkGroup)
    end
  end

  describe "GET edit" do
    it "assigns the requested work_group as @work_group" do
      work_group = WorkGroup.create! valid_attributes
      get :edit, {:id => work_group.to_param}, valid_session
      expect(assigns(:work_group)).to eq(work_group)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new WorkGroup" do
        expect {
          post :create, {:work_group => valid_attributes}, valid_session
        }.to change(WorkGroup, :count).by(1)
      end

      it "assigns a newly created work_group as @work_group" do
        post :create, {:work_group => valid_attributes}, valid_session
        expect(assigns(:work_group)).to be_a(WorkGroup)
        expect(assigns(:work_group)).to be_persisted
      end

      it "redirects to the created work_group" do
        post :create, {:work_group => valid_attributes}, valid_session
        expect(response).to redirect_to(WorkGroup.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved work_group as @work_group" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(WorkGroup).to receive(:save).and_return(false)
        post :create, {:work_group => { "name" => "invalid value" }}, valid_session
        expect(assigns(:work_group)).to be_a_new(WorkGroup)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(WorkGroup).to receive(:save).and_return(false)
        post :create, {:work_group => { "name" => "invalid value" }}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested work_group" do
        work_group = WorkGroup.create! valid_attributes
        # Assuming there are no other work_groups in the database, this
        # specifies that the WorkGroup created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(WorkGroup).to receive(:update).with({ "name" => "MyString" })
        put :update, {:id => work_group.to_param, :work_group => { "name" => "MyString" }}, valid_session
      end

      it "assigns the requested work_group as @work_group" do
        work_group = WorkGroup.create! valid_attributes
        put :update, {:id => work_group.to_param, :work_group => valid_attributes}, valid_session
        expect(assigns(:work_group)).to eq(work_group)
      end

      it "redirects to the work_group" do
        work_group = WorkGroup.create! valid_attributes
        put :update, {:id => work_group.to_param, :work_group => valid_attributes}, valid_session
        expect(response).to redirect_to(work_group)
      end
    end

    describe "with invalid params" do
      it "assigns the work_group as @work_group" do
        work_group = WorkGroup.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(WorkGroup).to receive(:save).and_return(false)
        put :update, {:id => work_group.to_param, :work_group => { "name" => "invalid value" }}, valid_session
        expect(assigns(:work_group)).to eq(work_group)
      end

      it "re-renders the 'edit' template" do
        work_group = WorkGroup.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(WorkGroup).to receive(:save).and_return(false)
        put :update, {:id => work_group.to_param, :work_group => { "name" => "invalid value" }}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested work_group" do
      work_group = WorkGroup.create! valid_attributes
      expect {
        delete :destroy, {:id => work_group.to_param}, valid_session
      }.to change(WorkGroup, :count).by(-1)
    end

    it "redirects to the work_groups list" do
      work_group = WorkGroup.create! valid_attributes
      delete :destroy, {:id => work_group.to_param}, valid_session
      expect(response).to redirect_to(work_groups_url)
    end
  end

end