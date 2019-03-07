class AddIdentifiersIndex < ActiveRecord::Migration
  def up
    remove_column :users, :username
    change_column :users, :email, :string, null: true, limit: 191

    #add_index "works", ["pmid", "published_on", "id"], name: "index_works_on_pmid_published_on_id", limit: 191
    #add_index "works", ["pmid"], name: "index_works_on_pmid", unique: true, length: 100
    #add_index "works", ["pmcid", "published_on", "id"], name: "index_works_on_pmcid_published_on_id",length: { "pmcid" => 9, "published_on" =>100 }
    add_index "works", ["pmcid"], name: "index_works_on_pmcid", unique: true, length: 100
    add_index "works", ["canonical_url", "published_on", "id"], name: "index_works_on_url_published_on_id", length: { "canonical_url" => 100 }
    add_index "works", ["canonical_url"], name: "index_works_on_url", length: 100
  end

  def down
    add_column :users, :username, :string
    change_column :users, :email, :string, null: false

    remove_index "works", name: "index_works_on_pmid_published_on_id"
    remove_index "works", name: "index_works_on_pmid"
    remove_index "works", name: "index_works_on_pmcid_published_on_id"
    remove_index "works", name: "index_works_on_pmcid"
    remove_index "works", name: "index_works_on_url_published_on_id"
    remove_index "works", name: "index_works_on_url"
  end
end
