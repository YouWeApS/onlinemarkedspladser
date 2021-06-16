class AddNewOrderStateToDandomainConfig < ActiveRecord::Migration[5.2]

  PROP = {
      title: 'Dandomain new order state ID',
      type: :string,
      format: :presence,
  }.freeze

  def up
    Channel.where("name ~ 'Dandomain'").find_each do |c|
      c.config_schema['properties'][:new_order_state_id] = PROP
      c.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end