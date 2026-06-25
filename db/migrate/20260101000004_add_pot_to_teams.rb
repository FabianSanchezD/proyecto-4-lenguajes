class AddPotToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :pot, :integer
  end
end
