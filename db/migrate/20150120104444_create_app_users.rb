class CreateAppUsers < ActiveRecord::Migration
  def change
    create_table :app_users do |t|

      t.timestamps
    end
  end
end
