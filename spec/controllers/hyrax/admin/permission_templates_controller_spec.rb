require 'spec_helper'

RSpec.describe Hyrax::Admin::PermissionTemplatesController do
  routes { Hyrax::Engine.routes }
  before do
    sign_in create(:user)
    allow(Hyrax::Forms::PermissionTemplateForm).to receive(:new).with(permission_template).and_return(form)
  end
  let(:hyrax) { Hyrax::Engine.routes.url_helpers }

  context "without admin privleges" do
    describe "update" do
      let(:admin_set) { create(:admin_set) }
      let(:permission_template) { create(:permission_template, admin_set_id: admin_set.id) }
      it "is unauthorized" do
        # This spec was not firing as expected. It was getting a nil permission template. This mock expectation is a bit
        # odd, but it needs to go rather deep into CanCan to behave accordingly.
        allow(controller.current_ability).to receive(:can?).with(:update, permission_template).and_return(false)
        put :update, params: { id: permission_template, admin_set_id: permission_template.admin_set_id }
        expect(assigns(:permission_template)).to eq(permission_template)
        expect(response).to be_unauthorized
      end
    end
  end

  let(:form) { instance_double(Hyrax::Forms::PermissionTemplateForm) }

  context "when signed in as an admin" do
    describe "update participants" do
      let(:admin_set) { create(:admin_set) }
      let!(:permission_template) { Hyrax::PermissionTemplate.create!(admin_set_id: admin_set.id) }
      let(:grant_attributes) { [{ "agent_type" => "user", "agent_id" => "bob", "access" => "view" }] }
      let(:input_params) do
        { admin_set_id: admin_set.id,
          permission_template: form_attributes }
      end
      let(:form_attributes) { { visibility: 'open', access_grants_attributes: grant_attributes } }

      it "is successful" do
        expect(controller).to receive(:authorize!).with(:update, permission_template)
        expect(form).to receive(:update).with(ActionController::Parameters.new(form_attributes).permit!)
        put :update, params: input_params
        expect(response).to redirect_to(hyrax.edit_admin_admin_set_path(admin_set, locale: 'en', anchor: 'participants'))
        expect(flash[:notice]).to eq "The administrative set's participant rights have been updated"
      end
    end
  end
end
