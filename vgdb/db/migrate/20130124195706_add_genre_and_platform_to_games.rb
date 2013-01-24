class AddGenreAndPlatformToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :genre_id, :integer
    add_column :games, :platform_id, :integer
  end

  def self.down
    remove_column :games, :genre_id
    remove_column :games, :platform_id
  end
end
