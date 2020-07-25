# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_18_101640) do

  create_table "channels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "channel"
    t.string "label"
    t.integer "pre_num"
    t.integer "pub_num"
    t.integer "l_sub"
    t.integer "c_sub"
    t.integer "feature"
    t.integer "rank"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "videos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "video_id"
    t.string "title"
    t.timestamp "publish_date"
    t.integer "views"
    t.string "duration"
    t.float "rating"
    t.integer "ratings"
    t.string "tags"
    t.string "categories"
    t.string "pornstars"
    t.string "url"
    t.string "default_thumb"
    t.string "thumb"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
