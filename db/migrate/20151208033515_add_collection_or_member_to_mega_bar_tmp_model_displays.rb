class AddCollectionOrMemberToMegaBarTmpModelDisplays < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_model_displays, :collection_or_member, :string
  end
end
