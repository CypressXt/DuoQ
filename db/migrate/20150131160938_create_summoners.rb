class CreateSummoners < ActiveRecord::Migration
  def change
    create_table :summoners do |t|
      t.string :name

      t.timestamps
    end
  end
end
