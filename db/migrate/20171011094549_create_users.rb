class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :count
      t.belongs_to :campaign
      t.timestamps
    end
  end
end
