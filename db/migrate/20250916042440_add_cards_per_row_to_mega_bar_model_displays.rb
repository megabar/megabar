class AddCardsPerRowToMegaBarModelDisplays < ActiveRecord::Migration[8.0]
  def change
    add_column :mega_bar_model_displays, :cards_per_row, :integer
  end
end
