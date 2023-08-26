class CreateActiveAdminComments < ActiveRecord::Migration[6.0]
  def self.up
    connection.execute 'DROP TABLE IF EXISTS active_admin_comments'
    create_table :active_admin_comments, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.string :namespace
      t.text   :body
      t.references :resource, polymorphic: true, index: false
      t.references :author, polymorphic: true, index: false
      t.timestamps
    end
    add_index :active_admin_comments, :namespace, :length => 20
    change_column :active_admin_comments, :resource_type, :string, :limit => 50
    add_index :active_admin_comments, [:resource_type, :resource_id]
    change_column :active_admin_comments, :author_type, :string, :limit => 50
    add_index :active_admin_comments, [:author_type, :author_id]
  end

  def self.down
    drop_table :active_admin_comments
  end
end
