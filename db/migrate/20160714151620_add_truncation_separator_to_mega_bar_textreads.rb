class AddTruncationSeparatorToMegaBarTextreads < ActiveRecord::Migration
  def change
    add_column :mega_bar_textreads, :truncation_separator, :string
  end
end
