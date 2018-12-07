class MakeTagUniqueByNameAndMission < ActiveRecord::Migration[5.1]
  def up
    select_sql = "SELECT array_agg(id), name, mission_id FROM tags GROUP BY name, mission_id HAVING count(*) > 1"
    duplicate_tags = execute(select_sql)
    remove_index(:tags, column: [:name, :mission_id])
    add_index :tags, [:name, :mission_id], unique: true, name: "index_tags_on_name_and_mission_id", where: "(deleted_at IS NULL)"
    add_index :tags,[:name], unique: true, name: "index_tags_on_name_where_mission_id_null", where: "(deleted_at IS NULL AND mission_id IS NULL)"
  end

  def down
    remove_index :tags,[:name, :mission_id], where: "(deleted_at IS NULL)"
    remove_index :tags,[:name], where: "(deleted_at IS NULL AND mission_id IS NULL)"
    add_index(:tags, [:name, :mission_id])
  end
end
