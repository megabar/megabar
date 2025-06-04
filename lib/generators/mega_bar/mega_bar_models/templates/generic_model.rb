<% the_module_array.each do | m | %>module <%=m %>
<% end %><% if the_module_array.include?('MegaBar') %>  class <%= classname %> < ActiveRecord::Base
    <%= position %>
    
    # 🚀 REVOLUTIONARY DETERMINISTIC ID SYSTEM
    # This model uses deterministic IDs for conflict-free seed loading
    before_create :set_deterministic_id
    
    # TODO: Implement deterministic_id method for this model
    # 
    # STEP 1: Choose an ID range (coordinate with team to avoid conflicts):
    #   - UI Components: 15000-28999 (Textbox: 15000-15999, Date: 28000-28999, etc.)
    #   - Core Models: 29000+ (next available range)
    #
    # STEP 2: Define unique identifier based on model's key attributes
    # STEP 3: Add this model to deterministic seed dump/load tasks
    #
    # Example for UI Component (uses field_display_id):
    # def self.deterministic_id(field_display_id)
    #   identifier = "<%= classname.underscore %>_#{field_display_id}"
    #   hash = Digest::MD5.hexdigest(identifier)
    #   base_id = YOUR_RANGE_START + (hash.to_i(16) % 1000)
    #   
    #   while self.exists?(id: base_id)
    #     base_id += 1
    #     break if base_id >= YOUR_RANGE_END
    #   end
    #   
    #   base_id
    # end
    def self.deterministic_id(*args)
      raise NotImplementedError, "🚀 Please implement deterministic_id method for #{self.name}. See comments above for guidance."
    end

    private

    def set_deterministic_id
      unless self.id
        # TODO: Pass appropriate arguments based on your model's unique attributes
        # Example: self.id = self.class.deterministic_id(self.field_display_id)
        raise NotImplementedError, "🚀 Please implement set_deterministic_id for #{self.class.name}. Pass unique attributes to deterministic_id method."
      end
    end
  end<% else %>  class <%= classname %> < ActiveRecord::Base
    <%= position %>
  end<% end %>
<% the_module_array.each do | m | %>end <% end %>
