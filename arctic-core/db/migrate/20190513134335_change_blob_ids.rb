class ChangeBlobIds < ActiveRecord::Migration[5.2]
  def change
    ActiveStorage::Attachment.all.each { |attachment| attachment.purge }
    ActiveRecord::Base.connection.truncate(:active_storage_blobs)

    drop_table :active_storage_attachments

    create_table :active_storage_attachments do |t|
      t.string :name,     null: false
      t.uuid :record_id, null: false
      t.string :record_type, null: false
      t.references :blob,     null: false
      t.datetime :created_at, null: false

      t.index [ :record_type, :record_id, :name, :blob_id ], name: "index_active_storage_attachments_uniqueness", unique: true
    end
  end
end



