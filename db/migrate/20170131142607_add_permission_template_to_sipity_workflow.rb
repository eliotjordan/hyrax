class AddPermissionTemplateToSipityWorkflow < ActiveRecord::Migration
  def change
    add_column :sipity_workflows, :permission_template_id, :integer, index: true
  end
end
