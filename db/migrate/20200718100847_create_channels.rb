class CreateChannels < ActiveRecord::Migration[6.0]
  def change
    create_table :channels do |t|
      t.string  :channel
      t.string  :label
      t.integer :pre_num
      t.integer :pub_num
      t.integer :l_sub
      t.integer :c_sub
      t.integer :feature
      t.integer :rank

      t.timestamps
    end
  end
end
