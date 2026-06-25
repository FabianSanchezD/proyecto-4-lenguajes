class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.integer :stage, null: false, default: 0
      t.references :group, foreign_key: true, null: true
      t.references :home_team, foreign_key: { to_table: :teams }, null: true
      t.references :away_team, foreign_key: { to_table: :teams }, null: true
      t.integer :home_goals, null: true
      t.integer :away_goals, null: true
      t.integer :home_penalties, null: true
      t.integer :away_penalties, null: true
      t.boolean :played, null: false, default: false
      t.integer :slot, null: true
      t.references :next_match, foreign_key: { to_table: :matches }, null: true
      t.string :next_slot, null: true

      t.timestamps
    end
  end
end
