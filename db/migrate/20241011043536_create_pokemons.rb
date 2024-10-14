class CreatePokemons < ActiveRecord::Migration[7.0]
  def change
    create_table :pokemons do |t|
      t.string :name
      t.string :types
      t.string :image
      t.boolean :captured
      t.datetime :capture_date

      t.timestamps
    end
  end
end
