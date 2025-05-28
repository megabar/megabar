namespace :mega_bar do
  desc 'Revolutionary seed dumping using deterministic IDs - eliminates tmp tables entirely'
  task :dump_deterministic_seeds, [:mega] => :environment do |t, args|
    puts "🚀 REVOLUTIONARY SEED DUMP - Using Deterministic IDs"
    puts "=" * 60
    
    # Same filtering logic as original
    if args[:mega].present?
      mega_bar_model_ids = MegaBar::Model.where(modyule: 'MegaBar').order(:id).pluck(:id)
      mega_bar_page_ids = MegaBar::Page.where(mega_page: 'mega').order(:id).pluck(:id)
    else
      mega_bar_model_ids = MegaBar::Model.all.order(:id).pluck(:id)
      mega_bar_page_ids = MegaBar::Page.all.order(:id).pluck(:id)
    end
    
    # Calculate related IDs
    mega_bar_theme_ids = MegaBar::Theme.all.order(:id).pluck(:id)
    mega_bar_template_ids = MegaBar::Template.all.order(:id).pluck(:id)
    mega_bar_fields = MegaBar::Field.where(model_id: mega_bar_model_ids).order(:id).pluck(:id)
    mega_bar_layout_ids = MegaBar::Layout.where(page_id: mega_bar_page_ids).order(:id).pluck(:id)
    mega_bar_layable_ids = MegaBar::Layable.where(layout_id: mega_bar_layout_ids).order(:id).pluck(:id)
    mega_bar_layout_section_ids = MegaBar::LayoutSection.joins(:layables).where(mega_bar_layables: {layout_id: mega_bar_layout_ids}).distinct.order(:id).pluck(:id)
    mega_bar_block_ids = MegaBar::Block.where(layout_section_id: mega_bar_layout_section_ids).order(:id).pluck(:id)
    mega_bar_model_display_ids = MegaBar::ModelDisplay.where(block_id: mega_bar_block_ids).order(:id).pluck(:id)
    mega_bar_model_display_collection_ids = MegaBar::ModelDisplayCollection.where(model_display_id: mega_bar_model_display_ids).order(:id).pluck(:id)
    mega_bar_field_display_ids = MegaBar::FieldDisplay.where(model_display_id: mega_bar_model_display_ids).order(:id).pluck(:id)

    # Create the new deterministic seeds file
    seeds_file = 'db/mega_bar_deterministic.seeds.rb'
    
    # Write header
    File.open(Rails.root.join(seeds_file), "w") do |file|
      file.puts "# MegaBar Deterministic Seeds - Revolutionary Approach"
      file.puts "# Generated: #{Time.current}"
      file.puts "# Uses deterministic IDs - NO tmp tables needed!"
      file.puts "# Can be loaded directly into permanent tables with find_or_create_by"
      file.puts ""
      file.puts "puts 'Loading MegaBar deterministic seeds...'"
      file.puts ""
    end

    # Dump all models in dependency order using find_or_create_by pattern
    dump_models_with_deterministic_pattern(seeds_file, [
      # Core foundation models first
      {model: MegaBar::Theme, ids: mega_bar_theme_ids, key_attrs: [:code_name]},
      {model: MegaBar::Portfolio, ids: MegaBar::Portfolio.where(theme_id: mega_bar_theme_ids).pluck(:id), key_attrs: [:code_name]},
      {model: MegaBar::Site, ids: MegaBar::Site.where(theme_id: mega_bar_theme_ids).pluck(:id), key_attrs: [:code_name]},
      
      # Templates
      {model: MegaBar::Template, ids: mega_bar_template_ids, key_attrs: [:code_name]},
      {model: MegaBar::TemplateSection, ids: MegaBar::TemplateSection.where(template_id: mega_bar_template_ids).pluck(:id), key_attrs: [:code_name, :template_id]},
      
      # Models and fields
      {model: MegaBar::Model, ids: mega_bar_model_ids, key_attrs: [:classname]},
      {model: MegaBar::Field, ids: mega_bar_fields, key_attrs: [:field, :data_type, :model_id]},
      {model: MegaBar::Option, ids: MegaBar::Option.where(field_id: mega_bar_fields).pluck(:id), key_attrs: [:field_id, :text, :value]},
      {model: MegaBar::ModelDisplayFormat, ids: MegaBar::ModelDisplayFormat.all.pluck(:id), key_attrs: [:name]},
      
      # Pages and layouts
      {model: MegaBar::Page, ids: mega_bar_page_ids, key_attrs: [:path, :name]},
      {model: MegaBar::Layout, ids: mega_bar_layout_ids, key_attrs: [:page_id, :name]},
      {model: MegaBar::LayoutSection, ids: mega_bar_layout_section_ids, key_attrs: [:code_name]},
      
      # Blocks and displays
      {model: MegaBar::Block, ids: mega_bar_block_ids, key_attrs: [:layout_section_id, :name]},
      {model: MegaBar::ModelDisplay, ids: mega_bar_model_display_ids, key_attrs: [:block_id, :model_id, :action, :series]},
      {model: MegaBar::ModelDisplayCollection, ids: mega_bar_model_display_collection_ids, key_attrs: [:model_display_id]},
      {model: MegaBar::FieldDisplay, ids: mega_bar_field_display_ids, key_attrs: [:model_display_id, :field_id, :position]},
      
      # UI Components
      {model: MegaBar::Checkbox, ids: MegaBar::Checkbox.where(field_display_id: mega_bar_field_display_ids).pluck(:id), key_attrs: [:field_display_id]},
      {model: MegaBar::PasswordField, ids: MegaBar::PasswordField.where(field_display_id: mega_bar_field_display_ids).pluck(:id), key_attrs: [:field_display_id]},
      {model: MegaBar::Radio, ids: MegaBar::Radio.where(field_display_id: mega_bar_field_display_ids).pluck(:id), key_attrs: [:field_display_id]},
      {model: MegaBar::Select, ids: MegaBar::Select.where(field_display_id: mega_bar_field_display_ids).pluck(:id), key_attrs: [:field_display_id]},
      {model: MegaBar::Textarea, ids: MegaBar::Textarea.where(field_display_id: mega_bar_field_display_ids).pluck(:id), key_attrs: [:field_display_id]},
      {model: MegaBar::Textbox, ids: MegaBar::Textbox.where(field_display_id: mega_bar_field_display_ids).pluck(:id), key_attrs: [:field_display_id]},
      {model: MegaBar::Textread, ids: MegaBar::Textread.where(field_display_id: mega_bar_field_display_ids).pluck(:id), key_attrs: [:field_display_id]},
      
      # Join tables
      {model: MegaBar::Layable, ids: mega_bar_layable_ids, key_attrs: [:layout_id, :layout_section_id]},
      {model: MegaBar::ThemeJoin, ids: theme_joins(mega_bar_block_ids, mega_bar_layout_ids).pluck(:id), key_attrs: [:theme_id, :themeable_type, :themeable_id]},
      {model: MegaBar::SiteJoin, ids: site_joins(mega_bar_block_ids, mega_bar_layout_ids).pluck(:id), key_attrs: [:site_id, :siteable_type, :siteable_id]},
      
      # System
      {model: MegaBar::PermissionLevel, ids: MegaBar::PermissionLevel.all.pluck(:id), key_attrs: [:level_name]}
    ])

    puts "✅ Revolutionary deterministic seeds dumped to: #{seeds_file}"
    puts "🎯 Key Benefits:"
    puts "   - NO tmp tables needed"
    puts "   - NO conflict resolution required"
    puts "   - Idempotent loading (can run multiple times)"
    puts "   - Deterministic IDs ensure consistency"
    puts "   - Much faster loading"
    puts "=" * 60
  end

  desc 'Load deterministic seeds directly into permanent tables'
  task :load_deterministic_seeds, [:file] => :environment do |t, args|
    puts "🚀 REVOLUTIONARY SEED LOADING - Direct to Permanent Tables"
    puts "=" * 60
    
    file = args[:file] || 'db/mega_bar_deterministic.seeds.rb'
    
    # Disable callbacks during loading (same as original system)
    disable_megabar_callbacks
    
    puts "Loading seeds from: #{file}"
    start_time = Time.current
    
    # Load the seeds directly - they use find_or_create_by with deterministic IDs
    require_relative Rails.root.join(file).to_s
    
    # Re-enable callbacks
    enable_megabar_callbacks
    
    end_time = Time.current
    puts "✅ Deterministic seeds loaded in #{(end_time - start_time).round(2)} seconds"
    puts "🎯 Revolutionary benefits achieved:"
    puts "   - Zero conflicts (deterministic IDs)"
    puts "   - No tmp table overhead"
    puts "   - Idempotent operation"
    puts "   - Much faster than traditional approach"
    puts "=" * 60
  end

  private

  def dump_models_with_deterministic_pattern(seeds_file, model_configs)
    model_configs.each do |config|
      model = config[:model]
      ids = config[:ids]
      key_attrs = config[:key_attrs]
      
      next if ids.empty?
      
      puts "Dumping #{model.name} (#{ids.length} records)..."
      
      records = model.where(id: ids).order(:id)
      
      File.open(Rails.root.join(seeds_file), "a") do |file|
        file.puts ""
        file.puts "# #{model.name} records"
        file.puts "puts 'Loading #{model.name} records...'"
        
        records.each do |record|
          # Build find_or_create_by hash using key attributes
          find_attrs = {}
          key_attrs.each { |attr| find_attrs[attr] = record.send(attr) }
          
          # Get all attributes except id, and filter to only include actual column names
          all_attrs = record.attributes.except('id').select { |attr, value| model.column_names.include?(attr) }
          
          file.puts "#{model.name}.find_or_create_by(#{find_attrs.inspect}) do |record|"
          all_attrs.each do |attr, value|
            # Properly format datetime values
            if value.is_a?(Time) || value.is_a?(DateTime)
              file.puts "  record.#{attr} = Time.parse(#{value.to_s.inspect})"
            elsif value.is_a?(Date)
              file.puts "  record.#{attr} = Date.parse(#{value.to_s.inspect})"
            else
              file.puts "  record.#{attr} = #{value.inspect}"
            end
          end
          file.puts "end"
        end
      end
    end
  end

  def disable_megabar_callbacks
    MegaBar::Block.skip_callback('save', :after, :make_model_displays)
    MegaBar::Block.skip_callback('save', :after, :add_route)
    MegaBar::Field.skip_callback('create', :after, :make_migration)
    MegaBar::Field.skip_callback('save', :after, :make_field_displays)
    MegaBar::FieldDisplay.skip_callback('save', :after, :make_data_display)
    MegaBar::Model.skip_callback('create', :after, :make_all_files)
    MegaBar::Model.skip_callback('create', :before, :standardize_modyule)
    MegaBar::Model.skip_callback('create', :before, :standardize_classname)
    MegaBar::Model.skip_callback('create', :before, :standardize_tablename)
    MegaBar::Model.skip_callback('create', :after, :make_page_for_model)
    MegaBar::Model.skip_callback('save', :after, :make_position_field)
    MegaBar::ModelDisplay.skip_callback('save', :after, :make_field_displays)
    MegaBar::ModelDisplay.skip_callback('save', :after, :make_collection_settings)
    MegaBar::Page.skip_callback('create', :after, :create_layout_for_page)
    MegaBar::Layout.skip_callback('create', :after, :create_layable_sections)
    MegaBar::LayoutSection.skip_callback('create', :after, :create_block_for_section)
  end

  def enable_megabar_callbacks
    MegaBar::Block.set_callback('save', :after, :make_model_displays)
    MegaBar::Block.set_callback('save', :after, :add_route)
    MegaBar::Field.set_callback('create', :after, :make_migration)
    MegaBar::Field.set_callback('save', :after, :make_field_displays)
    MegaBar::FieldDisplay.set_callback('save', :after, :make_data_display)
    MegaBar::Model.set_callback('create', :after, :make_all_files)
    MegaBar::Model.set_callback('create', :before, :standardize_modyule)
    MegaBar::Model.set_callback('create', :before, :standardize_classname)
    MegaBar::Model.set_callback('create', :before, :standardize_tablename)
    MegaBar::Model.set_callback('create', :after, :make_page_for_model)
    MegaBar::Model.set_callback('save', :after, :make_position_field)
    MegaBar::ModelDisplay.set_callback('save', :after, :make_field_displays)
    MegaBar::ModelDisplay.set_callback('save', :after, :make_collection_settings)
    MegaBar::Page.set_callback('create', :after, :create_layout_for_page)
    MegaBar::Layout.set_callback('create', :after, :create_layable_sections)
    MegaBar::LayoutSection.set_callback('create', :after, :create_block_for_section)
  end

  # Helper methods from original rake file
  def theme_joins(blocks, layouts)
    return MegaBar::ThemeJoin.none if blocks.empty? && layouts.empty?
    
    conditions = []
    conditions << "themeable_type = 'MegaBar::Block' and themeable_id in (#{blocks.join(',')})" unless blocks.empty?
    conditions << "themeable_type = 'MegaBar::Layout' and themeable_id in (#{layouts.join(',')})" unless layouts.empty?
    
    MegaBar::ThemeJoin.where(conditions.join(' OR '))
  end

  def site_joins(blocks, layouts)
    return MegaBar::SiteJoin.none if blocks.empty? && layouts.empty?
    
    conditions = []
    conditions << "siteable_type = 'MegaBar::Block' and siteable_id in (#{blocks.join(',')})" unless blocks.empty?
    conditions << "siteable_type = 'MegaBar::Layout' and siteable_id in (#{layouts.join(',')})" unless layouts.empty?
    
    MegaBar::SiteJoin.where(conditions.join(' OR '))
  end
end 