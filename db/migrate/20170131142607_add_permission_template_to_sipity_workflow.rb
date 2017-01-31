class AddPermissionTemplateToSipityWorkflow < ActiveRecord::Migration
  def change
    add_column :sipity_workflows, :permission_template_id, :integer, null: false
    add_index :sipity_workflows, :permission_template_id
  end
end
