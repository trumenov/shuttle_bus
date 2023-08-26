# This migration comes from active_storage (originally 20170806125915)
class CreateActiveStorageTables < ActiveRecord::Migration[6.0]
  def self.up
    connection.execute 'DROP TABLE IF EXISTS active_storage_attachments'
    connection.execute 'DROP TABLE IF EXISTS active_storage_blobs'
    create_table :active_storage_blobs, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.string   :key,        null: false, :limit => 30
      t.string   :filename,   null: false, :limit => 200
      t.string   :content_type, :limit => 50
      t.text     :metadata
      t.bigint   :byte_size,  null: false
      t.string   :checksum,   null: false, :limit => 50
      t.datetime :created_at, null: false

      t.index [ :key ], unique: true
    end

    create_table :active_storage_attachments, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.string     :name,     null: false, :limit => 140
      t.references :record,   null: false, polymorphic: true, index: false
      t.references :blob,     null: false

      t.datetime :created_at, null: false
      # t.index [ :record_type, :record_id, :name, :blob_id ], name: "index_active_storage_attachments_uniqueness", unique: true
      t.foreign_key :active_storage_blobs, column: :blob_id
    end
    change_column :active_storage_attachments, :record_type, :string, :limit => 50
    add_index :active_storage_attachments, [ :record_type, :record_id, :name, :blob_id ], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  def self.down
    drop_table :active_storage_attachments
    drop_table :active_storage_blobs
  end
end
