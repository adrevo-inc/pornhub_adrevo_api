class CreateVideoChannelMaps < ActiveRecord::Migration[6.0]
  def change
    create_table :video_channel_maps, id: false do |t|
      t.string :channel
      t.string :video_id, :primary_key => true
      t.string :video_type
 
      t.timestamps
    end
  end
end
