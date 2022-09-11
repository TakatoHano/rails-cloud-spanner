# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_09_11_052115) do
  create_table "articles", id: { limit: 8 }, force: :cascade do |t|
    t.string "title"
    t.string "body"
    t.time "created_at", null: false
    t.time "updated_at", null: false
  end

  create_table "comments", id: { limit: 8 }, force: :cascade do |t|
    t.string "commenter"
    t.string "body"
    t.integer "article_id", limit: 8, null: false
    t.time "created_at", null: false
    t.time "updated_at", null: false
  end

  add_foreign_key "comments", "articles"
end
