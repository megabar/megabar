class AddTruncationSeparatorToMegaBarTmpTextreads < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_textreads, :truncation_separator, :string
  end
end
