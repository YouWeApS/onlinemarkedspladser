class CreateVendorLocks < ActiveRecord::Migration[5.2]
  def change
    create_table :vendor_locks, id: :uuid do |t|
      t.uuid :target_id, null: false
      t.string :target_type, null: false
      t.uuid :vendor_id, null: false
      t.timestamps
    end

    add_index :vendor_locks, :vendor_id
    add_index :vendor_locks, :target_id
    add_index :vendor_locks, :target_type
    add_index :vendor_locks, %i[vendor_id target_id target_type], unique: true
  end
end
