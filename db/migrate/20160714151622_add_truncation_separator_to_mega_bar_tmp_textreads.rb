class AddTruncationSeparatorToMegaBarTmpTextreads < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_textreads, :truncation_separator, :string
  end
end
