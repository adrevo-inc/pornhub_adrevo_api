class CreateVideos < ActiveRecord::Migration[6.0]
  def change
    create_table :videos do |t|
      t.string    :video_id
      t.string    :title
      t.timestamp :publish_date
      t.integer   :views
      t.string    :duration
      t.float     :rating
      t.integer   :ratings
      t.string    :tags
      t.string    :categories
      t.string    :pornstars
      t.string    :url
      t.string    :default_thumb
      t.string    :thumb

      t.timestamps
    end
  end
end
