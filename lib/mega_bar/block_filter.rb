module MegaBar
  class BlockFilter
    def initialize(layout_section, rout, page_info)
      @layout_section = layout_section
      @rout = rout
      @page_info = page_info
    end

    def filter
      blocks = base_blocks
      return blocks unless @layout_section.rules.present?

      case @layout_section.rules
      when "specific"
        filter_specific_blocks(blocks)
      when "chosen"
        filter_chosen_blocks(blocks)
      else
        blocks
      end
    end

    private

    def base_blocks
      blocks = MegaBar::Block.by_layout_section(@layout_section.id).order(position: :asc)
      blocks = blocks.by_actions(@rout[:action]) unless @rout.blank?
      blocks
    end

    def filter_specific_blocks(blocks)
      rout_terms = @page_info[:page_path].split("/").reject! { |c| (c.nil? || c.empty?) }
      best_block = find_best_matching_block(blocks, rout_terms)
      blocks.reject { |b| b.id != best_block.id }
    end

    def find_best_matching_block(blocks, rout_terms)
      diff = 20
      prev_diff = 21
      best = nil

      blocks.each do |block|
        page_path_terms = block.path_base.split("/").map { |m| m if m[0] != ":" } - ["", nil]
        next if (rout_terms - page_path_terms).size != rout_terms.size - page_path_terms.size
        next if (page_path_terms.empty? && !rout_terms.empty?)

        current_diff = (rout_terms - page_path_terms).size
        if current_diff < prev_diff
          best = block
          prev_diff = current_diff
        end
      end

      best
    end

    def filter_chosen_blocks(blocks)
      model = MegaBar::Model.where(classname: @page_info[:terms][0].classify).first
      chosen_fields = model.fields.where("field LIKE ?", "%template%").pluck(:field)
      chosen_obj = @page_info[:terms][0].classify.constantize.find(@page_info[:vars][0].to_i)
      chosen_blocks = chosen_fields.map { |f| chosen_obj.send(f) }
      blocks.where(id: chosen_blocks)
    end
  end
end 