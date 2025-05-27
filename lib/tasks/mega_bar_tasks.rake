# desc "This is the file that you don't really want to know about! "
# Its a file that handles the complexities of loading lots of configuration data into new and existing installations,
#  as well as dumping configuration to be committed back to megabar master. "
# if ever new core tables are added to megabar, you need to carefully add it in the right places in this file
# That's a little tricky to do. A free six pack of your favorite micro brew if you can add one properly!

# task :mega_bar do
#   # Task goes here
# end
require 'fileutils'
require 'seed_dump'

namespace :mega_bar do
  desc 'engine_init' # just for testing
  task engine_init: :environment do
    # TODO see if it already was run.
    line = 'Rails.application.routes.draw do'
    text = File.read('config/routes.rb')
    new_contents = text.gsub( /(#{Regexp.escape(line)})/mi, "#{line}\n\n  MegaRoute.load(['/mega-bar']).each do |route|\n    match route[:path] => \"\#{route[:controller]}\#\#{route[:action]}\", via: route[:method], as: route[:as]\n  end \n  ##### MEGABAR BEGIN #####\n  mount MegaBar::Engine, at: '/mega-bar'\n  ##### MEGABAR END #####\n")
    File.open('config/routes.rb', "w") {|file| file.puts new_contents }
    unless File.directory?('app/assets/javascripts')
      FileUtils.mkdir_p('app/assets/javascripts')
    end
    IO.write("app/assets/javascripts/application.js", "//= require mega_bar/application.js ", mode: 'a')

    # File.open('app/assets/javascripts/application.js', 'a') { |f|
    #   f.puts "//= require mega_bar/application.js "
    # }

    File.open('app/assets/stylesheets/application.css', 'a') { |f|
      f.puts "//= require mega_bar/application.css "
    }

    Rake::Task["db:migrate"].invoke
    Rake::Task['mega_bar:data_load'].invoke

    puts "mounted the engine in the routes file"
    puts 'added mega_bar assets to the pipeline'
    puts " migrated the mega_bar db. "
    puts " and loaded the data."
    puts "Yer all set!"
  end

  desc "Setup test database - drops, loads schema, migrates and seeds the test db"
  task :test_db_setup => [:pre_reqs] do
    Rails.env = ENV['RAILS_ENV'] = 'test'
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['megabar:data_load'].invoke
    ActiveRecord::Base.establish_connection
    Rake::Task['db:migrate'].invoke
  end


  desc 'load data from the mega_bar.seeds.rb file into the local db, checking for and resolving conflicts along the way'
  # task data_load: :environment do
  task :data_load, [:file, :model_set]  => :environment do |t, args|
    # this is the core function of allowing multiple repos contribute back to a single one.
    # It could be used within a single organization or to commit back to the real mega_bar gem.
    # perm refers to the regular tables and objects.. like mega_bar_models
    # tmp refers to the 'tmp tables' and objects like mega_bar_tmp_models
    # c is usually a specific 'conflict' hash. c gets passed around a bit.
    # mega_classes are a list of classes we consider 'core' and that have their data loaded here (and conflict resolved)
    # conflict resolution involves createing a new perm record and then making sure anything that used the tmp record as a foreign key gets the new id in it.
    # what this all means is that if you add a new 'core' thing, you'll have to:
    #   add it to the mega_bar_classes array
    #   and probably add a resolver function.
    puts "Loading Route Information..." if args[:model_set] == 'routes'
    mega_classes = get_mega_classes
    route_classes = [MegaBar::Page, MegaBar::Layout, MegaBar::LayoutSection, MegaBar::Layable, MegaBar::Block, MegaBar::ModelDisplay, MegaBar::Model]
    mega_classes.delete_if { |x| not route_classes.include? x[:perm_class] } if args[:model_set] == 'routes'

    all_conflicts = []
    # display_classes = [[MegaBar::TmpTextbox, MegaBar::Textbox, 'TextBox'],[MegaBar::TmpTextread, MegaBar::Textread, 'TextRead']]
    mega_ids = []
    
    # Initialize field ID mapping hash to track reassignments
    @field_id_mapping = {}
    
    # Initialize model_display_id mapping hash to track reassignments
    @model_display_id_mapping = {}
    
    # Initialize page_id mapping hash to track reassignments
    @page_id_mapping = {}
    
    # Initialize layout_id mapping hash to track reassignments
    @layout_id_mapping = {}
    
    # Initialize layout_section_id mapping hash to track reassignments
    @layout_section_id_mapping = {}
    
    mega_classes.each do |mc|
      mc[:tmp_class].delete_all # delete everything that is in the tmp_tables
      mega_ids << mc[:id]
    end
    file = args[:file].nil? ? "../../db/mega_bar.seeds.rb" : Rails.root.to_s + args[:file]
    require_relative file #LOADS SEEDS INTO TMP TABLES
    
    # Check for foreign key mismatches after seed loading
    puts "=== CHECKING FOR FOREIGN KEY MISMATCHES ==="
    field_ids = MegaBar::TmpField.pluck(:id)
    orphaned_options = MegaBar::TmpOption.where.not(field_id: field_ids)
    orphaned_field_displays = MegaBar::TmpFieldDisplay.where.not(field_id: field_ids)
    
    puts "Field IDs in TmpField: #{field_ids.min}-#{field_ids.max} (#{field_ids.count} total)"
    puts "Orphaned options: #{orphaned_options.pluck(:field_id, :value)}"
    puts "Orphaned field_displays: #{orphaned_field_displays.pluck(:field_id, :model_display_id)}"
    
    # Fix orphaned references by mapping missing field IDs to existing ones
    if orphaned_options.any? || orphaned_field_displays.any?
      puts "=== FIXING ORPHANED REFERENCES ==="
      
      # Find the actual field mappings by field name
      transformation_field = MegaBar::TmpField.find_by(field: "transformation")
      include_time_field = MegaBar::TmpField.find_by(field: "include_time")
      
      puts "  transformation_field: #{transformation_field&.attributes}"
      puts "  include_time_field: #{include_time_field&.attributes}"
      
      field_id_mapping = {}
      # Map the orphaned IDs to the correct TMP field IDs (not the final PERM IDs)
      field_id_mapping[189] = transformation_field.id if transformation_field
      field_id_mapping[190] = include_time_field.id if include_time_field
      
      puts "  Field mappings: #{field_id_mapping}"
      
      field_id_mapping.each do |old_id, new_id|
        if field_ids.include?(new_id)
          options_updated = MegaBar::TmpOption.where(field_id: old_id).update_all(field_id: new_id)
          field_displays_updated = MegaBar::TmpFieldDisplay.where(field_id: old_id).update_all(field_id: new_id)
          puts "  Mapped field_id #{old_id} → #{new_id}: #{options_updated} options, #{field_displays_updated} field_displays"
        end
      end
    end
    
    # Debug: Show what field displays exist after orphaned reference fixing
    puts "=== TMP FIELD DISPLAYS AFTER ORPHANED REFERENCE FIXING ==="
    tmp_field_displays_174 = MegaBar::TmpFieldDisplay.where(model_display_id: 174)
    puts "Field displays for model_display_id 174: #{tmp_field_displays_174.count}"
    tmp_field_displays_174.each do |fd|
      puts "  ID: #{fd.id}, field_id: #{fd.field_id}, header: '#{fd.header}', position: #{fd.position}"
    end
    
    # Show all unique field_ids in TmpFieldDisplay
    all_field_ids = MegaBar::TmpFieldDisplay.pluck(:field_id).uniq.sort
    puts "All field_ids in TmpFieldDisplay: #{all_field_ids}"
    
    # Show field displays by field_id for Date fields
    date_field_ids = MegaBar::TmpField.where(model_id: 29).pluck(:id).sort
    puts "Date field IDs in TmpField: #{date_field_ids}"
    date_field_ids.each do |field_id|
      count = MegaBar::TmpFieldDisplay.where(field_id: field_id).count
      puts "  Field #{field_id}: #{count} field displays"
    end
    puts "============================================================"
    # start conflict resolution
    MegaBar::Block.skip_callback(       'save',   :after, :make_model_displays)
    MegaBar::Block.skip_callback(       'save',   :after, :add_route)
    MegaBar::Field.skip_callback(       'create', :after, :make_migration)
    MegaBar::Field.skip_callback(       'save',   :after, :make_field_displays)
    MegaBar::FieldDisplay.skip_callback('save',   :after, :make_data_display)
    MegaBar::Model.skip_callback(       'create', :after, :make_all_files)
    MegaBar::Model.skip_callback(       'create', :before, :standardize_modyule)
    MegaBar::Model.skip_callback(       'create', :before, :standardize_classname)
    MegaBar::Model.skip_callback(       'create', :before, :standardize_tablename)
    MegaBar::Model.skip_callback(       'create', :after, :make_page_for_model)
    MegaBar::Model.skip_callback(       'save',   :after, :make_position_field)
    MegaBar::ModelDisplay.skip_callback('save',   :after, :make_field_displays)
    MegaBar::ModelDisplay.skip_callback('save',   :after, :make_collection_settings)
    MegaBar::Page.skip_callback(        'create', :after, :create_layout_for_page)
    MegaBar::Layout.skip_callback(      'create', :after, :create_layable_sections)
    MegaBar::LayoutSection.skip_callback( 'create', :after,  :create_block_for_section)

    # start conflict detection
    # @@prex_all = []

    # Find Date model ID for logging - check both TMP and permanent tables
    date_model_tmp = MegaBar::TmpModel.find_by(classname: 'Date')
    date_model_perm = MegaBar::Model.find_by(classname: 'Date')
    date_model_id = date_model_tmp&.id
    puts "=== DATE MODEL TRACKING ==="
    puts "  TMP Date model: #{date_model_tmp ? "ID #{date_model_tmp.id}" : "NOT FOUND"}"
    puts "  PERM Date model: #{date_model_perm ? "ID #{date_model_perm.id}" : "NOT FOUND"}"
    puts "  Using date_model_id: #{date_model_id}"
    puts "=========================="

    mega_classes.each do |mc|
      puts "\n=== PROCESSING #{mc[:perm_class]} ==="
      
      # Special debugging for FieldDisplay processing
      if mc[:tmp_class] == MegaBar::TmpFieldDisplay
        puts "=== TMP FIELD DISPLAY STATE BEFORE PROCESSING ==="
        puts "  Field ID mappings: #{@field_id_mapping}"
        puts "  Model Display ID mappings: #{@model_display_id_mapping}"
        
        date_model_id = MegaBar::TmpModel.find_by(classname: 'Date')&.id
        if date_model_id
          date_field_ids = MegaBar::TmpField.where(model_id: date_model_id).pluck(:id)
          puts "  Date field IDs: #{date_field_ids}"
          
          # Show all TmpFieldDisplays for model_display_id 174 (and its mapped version)
          original_model_display_id = 174
          mapped_model_display_id = @model_display_id_mapping[original_model_display_id] || original_model_display_id
          
          puts "  Looking for TmpFieldDisplays with model_display_id #{original_model_display_id} (maps to #{mapped_model_display_id})"
          fd_174 = MegaBar::TmpFieldDisplay.where(model_display_id: mapped_model_display_id).order(:position)
          puts "  TmpFieldDisplays for model_display_id #{mapped_model_display_id}: #{fd_174.count}"
          fd_174.each do |fd|
            original_field_id = fd.field_id
            mapped_field_id = @field_id_mapping[original_field_id] || original_field_id
            mapping_info = mapped_field_id != original_field_id ? " (maps to #{mapped_field_id})" : ""
            puts "    ID: #{fd.id}, field_id: #{fd.field_id}#{mapping_info}, header: '#{fd.header}', position: #{fd.position}"
          end
        end
        puts "=== END TMP FIELD DISPLAY STATE ==="
      end

      mc[:tmp_class].all.order(id: :asc).each do |tmp|
        dupe_hash = {}
        tmp.reload
        
        # Special handling for FieldDisplay: map field_id and model_display_id using our tracking
        if mc[:tmp_class] == MegaBar::TmpFieldDisplay
          original_field_id = tmp.field_id
          mapped_field_id = @field_id_mapping[original_field_id] || original_field_id
          
          original_model_display_id = tmp.model_display_id
          mapped_model_display_id = @model_display_id_mapping[original_model_display_id] || original_model_display_id
          
          if mapped_field_id != original_field_id || mapped_model_display_id != original_model_display_id
            puts "*** FIELD ID MAPPING FOR FIELDDISPLAY ***"
            puts "  Original field_id: #{original_field_id} -> Mapped field_id: #{mapped_field_id}"
            puts "  Original model_display_id: #{original_model_display_id} -> Mapped model_display_id: #{mapped_model_display_id}"
            puts "  TmpFieldDisplay: #{tmp.id}, header: '#{tmp.header}'"
            
            # Use the mapped IDs for the dupe_hash lookup
            mc[:unique].each do |u|
              if u == :field_id
                dupe_hash[u] = mapped_field_id
              elsif u == :model_display_id
                dupe_hash[u] = mapped_model_display_id
              else
                dupe_hash[u] = tmp[u]
              end
            end
          else
            mc[:unique].each { |u| dupe_hash[u] = tmp[u] }
          end
        # Special handling for Layout: map page_id using our tracking
        elsif mc[:tmp_class] == MegaBar::TmpLayout
          original_page_id = tmp.page_id
          mapped_page_id = @page_id_mapping[original_page_id] || original_page_id
          
          if mapped_page_id != original_page_id
            puts "*** PAGE ID MAPPING FOR LAYOUT ***"
            puts "  Original page_id: #{original_page_id} -> Mapped page_id: #{mapped_page_id}"
            puts "  TmpLayout: #{tmp.id}, name: '#{tmp.name}'"
            
            # Use the mapped page_id for the dupe_hash lookup
            mc[:unique].each do |u|
              if u == :page_id
                dupe_hash[u] = mapped_page_id
              else
                dupe_hash[u] = tmp[u]
              end
            end
          else
            mc[:unique].each { |u| dupe_hash[u] = tmp[u] }
          end
        # Special handling for Layable: map layout_id and layout_section_id using our tracking
        elsif mc[:tmp_class] == MegaBar::TmpLayable
          original_layout_id = tmp.layout_id
          mapped_layout_id = @layout_id_mapping[original_layout_id] || original_layout_id
          
          original_layout_section_id = tmp.layout_section_id
          mapped_layout_section_id = @layout_section_id_mapping[original_layout_section_id] || original_layout_section_id
          
          if mapped_layout_id != original_layout_id || mapped_layout_section_id != original_layout_section_id
            puts "*** LAYOUT/LAYOUT_SECTION ID MAPPING FOR LAYABLE ***"
            puts "  Original layout_id: #{original_layout_id} -> Mapped layout_id: #{mapped_layout_id}"
            puts "  Original layout_section_id: #{original_layout_section_id} -> Mapped layout_section_id: #{mapped_layout_section_id}"
            puts "  TmpLayable: #{tmp.id}"
            
            # Use the mapped IDs for the dupe_hash lookup
            mc[:unique].each do |u|
              if u == :layout_id
                dupe_hash[u] = mapped_layout_id
              elsif u == :layout_section_id
                dupe_hash[u] = mapped_layout_section_id
              else
                dupe_hash[u] = tmp[u]
              end
            end
          else
            mc[:unique].each { |u| dupe_hash[u] = tmp[u] }
          end
        elsif mc[:tmp_class] == MegaBar::TmpBlock
          # Check if this block references Date model displays OR is in Date layout
          date_block_model_displays = MegaBar::TmpModelDisplay.where(block_id: tmp.id, model_id: date_model_id)
          date_page = MegaBar::TmpPage.find_by(path: '/mega-bar/dates')
          date_layout = date_page ? MegaBar::TmpLayout.find_by(page_id: date_page.id) : nil
          date_layout_sections = date_layout ? MegaBar::TmpLayable.where(layout_id: date_layout.id).pluck(:layout_section_id) : []
          
          if date_block_model_displays.any? || date_layout_sections.include?(tmp.layout_section_id)
            is_date_related = true
            puts "*** PROCESSING DATE BLOCK: #{tmp.name} (tmp_id: #{tmp.id}) ***"
            puts "  layout_section_id: #{tmp.layout_section_id}"
            puts "  date_layout_sections: #{date_layout_sections}"
          end
        elsif mc[:tmp_class] == MegaBar::TmpLayable
          # Check if this layable connects to the Date layout
          date_page = MegaBar::TmpPage.find_by(path: '/mega-bar/dates')
          date_layout = date_page ? MegaBar::TmpLayout.find_by(page_id: date_page.id) : nil
          
          if date_layout && tmp.layout_id == date_layout.id
            is_date_related = true
            puts "*** PROCESSING DATE LAYABLE: layout_id=#{tmp.layout_id}, layout_section_id=#{tmp.layout_section_id} (tmp_id: #{tmp.id}) ***"
          end
        else
          mc[:unique].each { |u| dupe_hash[u] = tmp[u] }
        end
        
        obj = mc[:perm_class].find_or_initialize_by(dupe_hash)
        attributes = tmp.attributes.select { |attr, value|  mc[:tmp_class].column_names.include?(attr.to_s) }
        attributes.delete("id") unless attributes["id"] == 0
        
        # For FieldDisplay, also update the field_id and model_display_id in attributes if they were mapped
        if mc[:tmp_class] == MegaBar::TmpFieldDisplay
          original_field_id = tmp.field_id
          mapped_field_id = @field_id_mapping[original_field_id] || original_field_id
          
          original_model_display_id = tmp.model_display_id
          mapped_model_display_id = @model_display_id_mapping[original_model_display_id] || original_model_display_id
          
          if mapped_field_id != original_field_id
            attributes["field_id"] = mapped_field_id
            puts "  Updated attributes field_id: #{original_field_id} -> #{mapped_field_id}"
          end
          
          if mapped_model_display_id != original_model_display_id
            attributes["model_display_id"] = mapped_model_display_id
            puts "  Updated attributes model_display_id: #{original_model_display_id} -> #{mapped_model_display_id}"
          end
        # For Layout, also update the page_id in attributes if it was mapped
        elsif mc[:tmp_class] == MegaBar::TmpLayout
          original_page_id = tmp.page_id
          mapped_page_id = @page_id_mapping[original_page_id] || original_page_id
          
          if mapped_page_id != original_page_id
            attributes["page_id"] = mapped_page_id
            puts "  Updated attributes page_id: #{original_page_id} -> #{mapped_page_id}"
          end
        # For Layable, also update the layout_id and layout_section_id in attributes if they were mapped
        elsif mc[:tmp_class] == MegaBar::TmpLayable
          original_layout_id = tmp.layout_id
          mapped_layout_id = @layout_id_mapping[original_layout_id] || original_layout_id
          
          original_layout_section_id = tmp.layout_section_id
          mapped_layout_section_id = @layout_section_id_mapping[original_layout_section_id] || original_layout_section_id
          
          if mapped_layout_id != original_layout_id
            attributes["layout_id"] = mapped_layout_id
            puts "  Updated attributes layout_id: #{original_layout_id} -> #{mapped_layout_id}"
          end
          
          if mapped_layout_section_id != original_layout_section_id
            attributes["layout_section_id"] = mapped_layout_section_id
            puts "  Updated attributes layout_section_id: #{original_layout_section_id} -> #{mapped_layout_section_id}"
          end
        end
        
        # Date-specific logging
        is_date_related = false
        if mc[:tmp_class] == MegaBar::TmpModel && tmp.classname == 'Date'
          is_date_related = true
          puts "*** PROCESSING DATE MODEL ***"
          puts "  tmp.id: #{tmp.id}, tmp.classname: #{tmp.classname}"
        elsif mc[:tmp_class] == MegaBar::TmpField && tmp.model_id == date_model_id
          is_date_related = true
          puts "*** PROCESSING DATE FIELD: #{tmp.field} (tmp_id: #{tmp.id}) ***"
        elsif mc[:tmp_class] == MegaBar::TmpModelDisplay && tmp.model_id == date_model_id
          is_date_related = true
          puts "*** PROCESSING DATE MODEL DISPLAY: #{tmp.action} (tmp_id: #{tmp.id}) ***"
        elsif mc[:tmp_class] == MegaBar::TmpModelDisplay && tmp.id == 174
          is_date_related = true
          puts "*** PROCESSING MODEL DISPLAY 174: #{tmp.action} (model_id: #{tmp.model_id}, block_id: #{tmp.block_id}) ***"
        elsif mc[:tmp_class] == MegaBar::TmpFieldDisplay
          # Check if this field display references a Date field OR ModelDisplay 174
          date_field_ids = MegaBar::TmpField.where(model_id: date_model_id).pluck(:id) if date_model_id
          if date_field_ids&.include?(tmp.field_id) || tmp.model_display_id == 174
            is_date_related = true
            puts "*** PROCESSING DATE/174 FIELD DISPLAY: field_id=#{tmp.field_id}, model_display_id=#{tmp.model_display_id} (tmp_id: #{tmp.id}) ***"
          end
        elsif mc[:tmp_class] == MegaBar::TmpPage && tmp.path == '/mega-bar/dates'
          is_date_related = true
          puts "*** PROCESSING DATE PAGE: #{tmp.path} (tmp_id: #{tmp.id}) ***"
        elsif mc[:tmp_class] == MegaBar::TmpLayout
          # Check if this layout belongs to the Date page
          date_page = MegaBar::TmpPage.find_by(path: '/mega-bar/dates')
          if date_page && tmp.page_id == date_page.id
            is_date_related = true
            puts "*** PROCESSING DATE LAYOUT: #{tmp.name} (tmp_id: #{tmp.id}) ***"
          end
        end
        
        if is_date_related
          puts "  dupe_hash: #{dupe_hash.inspect}"
          puts "  find_or_initialize_by result - obj.id: #{obj.id}, obj.new_record?: #{obj.new_record?}"
          puts "  attributes to assign: #{attributes.inspect}"
        end
        
        # Add logging for field processing (only for fields > 185)
        if mc[:tmp_class] == MegaBar::TmpField && tmp.id > 185
          puts "Processing field: #{tmp.field} (tmp_id: #{tmp.id})"
          puts "  dupe_hash: #{dupe_hash.inspect}"
          puts "  find_or_initialize_by result - obj.id: #{obj.id}, obj.new_record?: #{obj.new_record?}"
          puts "  attributes to assign: #{attributes.inspect}"
        end
        
        obj.assign_attributes(attributes)
        
        # Date-specific logging after assign_attributes
        if is_date_related
          puts "  After assign_attributes - obj.id: #{obj.id}, obj.new_record?: #{obj.new_record?}"
          puts "  obj.attributes: #{obj.attributes.inspect}"
        end
        
        # Add more logging before save (only for fields > 185)
        if mc[:tmp_class] == MegaBar::TmpField && tmp.id > 185
          puts "  After assign_attributes - obj.id: #{obj.id}, obj.new_record?: #{obj.new_record?}"
          puts "  obj.attributes before save: #{obj.attributes.inspect}"
        end
        
        save_result = obj.save
        
        # Date-specific logging after save
        if is_date_related
          puts "  Save result: #{save_result}"
          puts "  After save - obj.id: #{obj.id}, tmp.id: #{tmp.id}"
          puts "  IDs match: #{obj.id == tmp.id}"
          if !save_result
            puts "  Save errors: #{obj.errors.full_messages}"
          end
          puts "  Final obj.attributes: #{obj.attributes.inspect}"
          puts "---"
        end
        
        # More logging after save (only for fields > 185)
        if mc[:tmp_class] == MegaBar::TmpField && tmp.id > 185
          puts "  Save result: #{save_result}"
          puts "  After save - obj.id: #{obj.id}, tmp.id: #{tmp.id}"
          puts "  IDs match: #{obj.id == tmp.id}"
          puts "  obj.attributes after save: #{obj.attributes.inspect}"
          if !save_result
            puts "  Save errors: #{obj.errors.full_messages}"
          end
          puts "---"
        end
        
        # Add logging for Options and FieldDisplays that reference high-ID fields
        if mc[:tmp_class] == MegaBar::TmpOption && tmp.field_id > 185
          puts "Processing Option: field_id=#{tmp.field_id}, value='#{tmp.value}' (tmp_id: #{tmp.id})"
          puts "  dupe_hash: #{dupe_hash.inspect}"
          puts "  find_or_initialize_by result - obj.id: #{obj.id}, obj.new_record?: #{obj.new_record?}"
        end
        
        if mc[:tmp_class] == MegaBar::TmpFieldDisplay && tmp.field_id > 185
          puts "Processing FieldDisplay: field_id=#{tmp.field_id}, model_display_id=#{tmp.model_display_id} (tmp_id: #{tmp.id})"
          puts "  dupe_hash: #{dupe_hash.inspect}"
          puts "  find_or_initialize_by result - obj.id: #{obj.id}, obj.new_record?: #{obj.new_record?}"
        end
        
        # Track ALL ID changes (conflicts AND auto-increment reassignments)
        if obj.id != tmp.id
          conflict = {tmp: tmp, perm: obj, mc: mc}
          if mc[:tmp_class] == MegaBar::TmpField
            puts "=== ID REASSIGNMENT DETECTED ==="
            puts "  TMP: model_id=#{conflict[:tmp].model_id}, field='#{conflict[:tmp].field}', id=#{conflict[:tmp].id}"
            puts "  PERM: model_id=#{conflict[:perm].model_id}, field='#{conflict[:perm].field}', id=#{conflict[:perm].id}"
            puts "  Calling resolver: #{mc[:resolver]}"
          end
          if is_date_related
            puts "=== DATE-RELATED ID REASSIGNMENT ==="
            puts "  TMP: #{tmp.attributes.inspect}"
            puts "  PERM: #{obj.attributes.inspect}"
            puts "  Calling resolver: #{mc[:resolver]}"
          end
          method(mc[:resolver]).call(conflict)
        end
      end
      puts 'finished ' + mc[:perm_class].to_s
    end
    # FIx The replacement of MegaBar::..Model with MegaBar::Tmp... done in seed dumping
    MegaBar::Model.update_all("position_parent = replace(position_parent,'MegaBar::Tmp','MegaBar::') ") #fix position parent from regex that happened with seed_dump
    MegaBar::ThemeJoin.update_all("themeable_type = replace(themeable_type,'MegaBar::Tmp','MegaBar::') ") #fix seed_dump
    MegaBar::SiteJoin.update_all("siteable_type = replace(siteable_type,'MegaBar::Tmp','MegaBar::') ") #fix  seed_dump

    MegaBar::Block.set_callback(       'save',   :after, :make_model_displays)
    MegaBar::Block.set_callback(       'save',   :after, :add_route)
    MegaBar::Field.set_callback(       'create', :after, :make_migration)
    MegaBar::Field.set_callback(       'save',   :after, :make_field_displays)
    MegaBar::FieldDisplay.set_callback('save',   :after, :make_data_display)
    MegaBar::Model.set_callback(       'create', :after, :make_all_files)
    MegaBar::Model.set_callback(       'create', :before, :standardize_modyule)
    MegaBar::Model.set_callback(       'create', :before, :standardize_classname)
    MegaBar::Model.set_callback(       'create', :before, :standardize_tablename)
    MegaBar::Model.set_callback(       'create', :after, :make_page_for_model)
    MegaBar::Model.set_callback(       'save',   :after, :make_position_field)

    MegaBar::ModelDisplay.set_callback('save',   :after, :make_field_displays)
    MegaBar::ModelDisplay.set_callback('save',   :after, :make_collection_settings)
    MegaBar::Page.set_callback(        'create', :after, :create_layout_for_page)
    MegaBar::Layout.set_callback(      'create', :after, :create_layable_sections)
    MegaBar::LayoutSection.set_callback(      'create', :after, :create_block_for_section)
    # end of main function for loading data
    # important sub functions are below
    puts "Loaded Data"
  end


  def higher_plus_one(a, b)
    c = a >= b ? a+1 : b+1
  end


  def fix_model(c)
    # puts 'Incoming model ' + c[:tmp].id.to_s + ' with class ' + c[:tmp].classname + ' had to be issued a new id ' + c[:perm].id.to_s + '.'
    ##### FIELDS

    # Update TMP tables (for records not yet processed)
    MegaBar::TmpModelDisplay.where(model_id: c[:tmp].id).update_all(model_id: c[:perm].id)
    MegaBar::TmpField.where(model_id: c[:tmp].id).each { |f| f.update(model_id: c[:perm].id) }
    MegaBar::TmpBlock.where(nest_level_1: c[:tmp].id).each { |f| f.update(nest_level_1: c[:perm].id) }
    MegaBar::TmpBlock.where(nest_level_2: c[:tmp].id).each { |f| f.update(nest_level_2: c[:perm].id) }
    MegaBar::TmpBlock.where(nest_level_3: c[:tmp].id).each { |f| f.update(nest_level_3: c[:perm].id) }
    MegaBar::TmpBlock.where(nest_level_4: c[:tmp].id).each { |f| f.update(nest_level_4: c[:perm].id) }
    MegaBar::TmpBlock.where(nest_level_5: c[:tmp].id).each { |f| f.update(nest_level_5: c[:perm].id) }
    MegaBar::TmpBlock.where(nest_level_6: c[:tmp].id).each { |f| f.update(nest_level_6: c[:perm].id) }
    
    # Update permanent tables (for records already processed FROM SEEDS ONLY)
    # Only update records that were created during this seed loading session
    # We identify these by finding records that reference the TMP model's classname
    seed_model_displays = MegaBar::ModelDisplay.joins(:model).where(
      model_id: c[:tmp].id, 
      mega_bar_models: { classname: c[:tmp].classname }
    )
    seed_model_displays.update_all(model_id: c[:perm].id)
    
    seed_fields = MegaBar::Field.joins(:model).where(
      model_id: c[:tmp].id,
      mega_bar_models: { classname: c[:tmp].classname }
    )
    seed_fields.update_all(model_id: c[:perm].id)
    
    # For blocks, we need to be more careful since they reference models in multiple ways
    MegaBar::Block.where(nest_level_1: c[:tmp].id).update_all(nest_level_1: c[:perm].id)
    MegaBar::Block.where(nest_level_2: c[:tmp].id).update_all(nest_level_2: c[:perm].id)
    MegaBar::Block.where(nest_level_3: c[:tmp].id).update_all(nest_level_3: c[:perm].id)
    MegaBar::Block.where(nest_level_4: c[:tmp].id).update_all(nest_level_4: c[:perm].id)
    MegaBar::Block.where(nest_level_5: c[:tmp].id).update_all(nest_level_5: c[:perm].id)
    MegaBar::Block.where(nest_level_6: c[:tmp].id).update_all(nest_level_6: c[:perm].id)
  end
  # end of model stuff

  def fix_fields(c)
    puts "=== FIX_FIELDS DEBUG ==="
    puts "  Field reassignment: tmp_id #{c[:tmp].id} (#{c[:tmp].field}) -> perm_id #{c[:perm].id} (#{c[:perm].field})"
    
    # Track the field ID mapping for later use during FieldDisplay processing
    @field_id_mapping[c[:tmp].id] = c[:perm].id
    puts "  Added to field mapping: #{c[:tmp].id} -> #{c[:perm].id}"
    puts "  Current field mappings: #{@field_id_mapping}"
    
    # Check what TmpFieldDisplays reference this field (for debugging only)
    tmp_field_displays = MegaBar::TmpFieldDisplay.where(field_id: c[:tmp].id)
    tmp_options = MegaBar::TmpOption.where(field_id: c[:tmp].id)
    
    puts "  TmpFieldDisplays that reference field #{c[:tmp].id}: #{tmp_field_displays.count}"
    tmp_field_displays.each do |fd|
      puts "    ID: #{fd.id}, model_display_id: #{fd.model_display_id}, header: '#{fd.header}', position: #{fd.position}"
    end
    
    puts "  TmpOptions to update: #{tmp_options.count}"
    tmp_options.each do |opt|
      puts "    ID: #{opt.id}, value: '#{opt.value}'"
    end
    
    # Only update TmpOptions (NOT TmpFieldDisplay)
    MegaBar::TmpOption.where(field_id: c[:tmp].id).update_all(field_id: c[:perm].id)
    
    puts "  TmpOptions updated, TmpFieldDisplay left unchanged"
    puts "=== END FIX_FIELDS DEBUG ==="
  end

  def fix_model_display_format(c)
  end

  def fix_options(c)
  end

  def fix_themes(c)
    # Update TMP tables (for records not yet processed)
    MegaBar::TmpPortfolio.where(theme_id: c[:tmp].id).update_all(theme_id: c[:perm].id)
    MegaBar::TmpSite.where(theme_id: c[:tmp].id).update_all(theme_id: c[:perm].id)
    MegaBar::TmpThemeJoin.where(theme_id: c[:tmp].id).update_all(theme_id: c[:perm].id)
    
    # Update permanent tables (for records already processed)
    MegaBar::Portfolio.where(theme_id: c[:tmp].id).update_all(theme_id: c[:perm].id)
    MegaBar::Site.where(theme_id: c[:tmp].id).update_all(theme_id: c[:perm].id)
    MegaBar::ThemeJoin.where(theme_id: c[:tmp].id).update_all(theme_id: c[:perm].id)
  end

  def fix_portfolios(c)
    # Update TMP tables (for records not yet processed)
    MegaBar::TmpSite.where(portfolio_id: c[:tmp].id).update_all(portfolio_id: c[:perm].id)
    
    # Update permanent tables (for records already processed)
    MegaBar::Site.where(portfolio_id: c[:tmp].id).update_all(portfolio_id: c[:perm].id)
  end

  def fix_sites(c)
    # Update TMP tables (for records not yet processed)
    MegaBar::TmpSiteJoin.where(site_id: c[:tmp].id).update_all(site_id: c[:perm].id)
    
    # Update permanent tables (for records already processed)
    MegaBar::SiteJoin.where(site_id: c[:tmp].id).update_all(site_id: c[:perm].id)
  end

  def fix_pages(c)
    puts "=== FIX_PAGES DEBUG ==="
    puts "  Page reassignment: tmp_id #{c[:tmp].id} -> perm_id #{c[:perm].id}"
    
    # Track the page_id mapping for later use during Layout processing
    @page_id_mapping[c[:tmp].id] = c[:perm].id
    puts "  Added to page mapping: #{c[:tmp].id} -> #{c[:perm].id}"
    puts "  Current page mappings: #{@page_id_mapping}"
    
    # DO NOT update layouts here - they will be handled during Layout processing
    puts "  Layouts will be updated during Layout processing using mapping"
    puts "=== END FIX_PAGES DEBUG ==="
  end

  def fix_layouts(c)
    puts "=== FIX_LAYOUTS DEBUG ==="
    puts "  Layout reassignment: tmp_id #{c[:tmp].id} -> perm_id #{c[:perm].id}"
    
    # Track the layout_id mapping for later use during Layable processing
    @layout_id_mapping[c[:tmp].id] = c[:perm].id
    puts "  Added to layout mapping: #{c[:tmp].id} -> #{c[:perm].id}"
    puts "  Current layout mappings: #{@layout_id_mapping}"
    
    # Update TMP tables (for records not yet processed)
    MegaBar::TmpLayable.where(layout_id: c[:tmp].id).update_all(layout_id: c[:perm].id)
    MegaBar::TmpThemeJoin.where(themeable_type: 'MegaBar::TmpLayout', themeable_id: c[:tmp].id).update_all(themeable_id: c[:perm].id)
    MegaBar::TmpSiteJoin.where(siteable_type: 'MegaBar::TmpLayout', siteable_id: c[:tmp].id).update_all(siteable_id: c[:perm].id)
    
    # Update permanent tables (for records already processed)
    MegaBar::Layable.where(layout_id: c[:tmp].id).update_all(layout_id: c[:perm].id)
    MegaBar::ThemeJoin.where(themeable_type: 'MegaBar::Layout', themeable_id: c[:tmp].id).update_all(themeable_id: c[:perm].id)
    MegaBar::SiteJoin.where(siteable_type: 'MegaBar::Layout', siteable_id: c[:tmp].id).update_all(siteable_id: c[:perm].id)
    
    puts "=== END FIX_LAYOUTS DEBUG ==="
  end

  def fix_layables(c)
    # MegaBar::TmpLayable.where(layout_id: c[:tmp].id).update_all(layout_id: c[:perm].id)
  end

  def fix_layout_sections(c)
    puts "=== FIX_LAYOUT_SECTIONS DEBUG ==="
    puts "  LayoutSection reassignment: tmp_id #{c[:tmp].id} -> perm_id #{c[:perm].id}"
    
    # Track the layout_section_id mapping for later use during Layable processing
    @layout_section_id_mapping[c[:tmp].id] = c[:perm].id
    puts "  Added to layout_section mapping: #{c[:tmp].id} -> #{c[:perm].id}"
    puts "  Current layout_section mappings: #{@layout_section_id_mapping}"
    
    # Update TMP tables (for records not yet processed)
    MegaBar::TmpLayable.where(layout_section_id: c[:tmp].id).update_all(layout_section_id: c[:perm].id)
    MegaBar::TmpBlock.where(layout_section_id: c[:tmp].id).update_all(layout_section_id: c[:perm].id)
    
    # Update permanent tables (for records already processed)
    MegaBar::Layable.where(layout_section_id: c[:tmp].id).update_all(layout_section_id: c[:perm].id)
    MegaBar::Block.where(layout_section_id: c[:tmp].id).update_all(layout_section_id: c[:perm].id)
    
    puts "=== END FIX_LAYOUT_SECTIONS DEBUG ==="
  end

  def fix_blocks(c)
    # byebug if MegaBar::TmpModelDisplay(c[:tmp].header == 'Edit Part 2'
    # Update TMP tables (for records not yet processed)
    MegaBar::TmpModelDisplay.where(block_id: c[:tmp].id).update_all(block_id: c[:perm].id)
    MegaBar::TmpThemeJoin.where(themeable_type: 'MegaBar::TmpBlock', themeable_id: c[:tmp].id).update_all(themeable_id: c[:perm].id)
    MegaBar::TmpSiteJoin.where(siteable_type: 'MegaBar::TmpBlock', siteable_id: c[:tmp].id).update_all(siteable_id: c[:perm].id)
    
    # Update permanent tables (for records already processed)
    MegaBar::ModelDisplay.where(block_id: c[:tmp].id).update_all(block_id: c[:perm].id)
    MegaBar::ThemeJoin.where(themeable_type: 'MegaBar::Block', themeable_id: c[:tmp].id).update_all(themeable_id: c[:perm].id)
    MegaBar::SiteJoin.where(siteable_type: 'MegaBar::Block', siteable_id: c[:tmp].id).update_all(siteable_id: c[:perm].id)
  end

  def fix_model_displays(c)
    puts "=== FIX_MODEL_DISPLAYS DEBUG ==="
    puts "  ModelDisplay reassignment: tmp_id #{c[:tmp].id} -> perm_id #{c[:perm].id}"
    
    # Track the model_display_id mapping for later use during FieldDisplay processing
    @model_display_id_mapping[c[:tmp].id] = c[:perm].id
    puts "  Added to model_display mapping: #{c[:tmp].id} -> #{c[:perm].id}"
    puts "  Current model_display mappings: #{@model_display_id_mapping}"
    
    # Update TMP tables (for records not yet processed)
    MegaBar::TmpFieldDisplay.where(model_display_id: c[:tmp].id).update_all(model_display_id: c[:perm].id)
    MegaBar::TmpModelDisplayCollection.where(model_display_id: c[:tmp].id).update_all(model_display_id: c[:perm].id)
    
    # Update permanent tables (for records already processed)
    MegaBar::FieldDisplay.where(model_display_id: c[:tmp].id).update_all(model_display_id: c[:perm].id)
    MegaBar::ModelDisplayCollection.where(model_display_id: c[:tmp].id).update_all(model_display_id: c[:perm].id)
    
    puts "=== END FIX_MODEL_DISPLAYS DEBUG ==="
    # pprex
  end

  def fix_field_displays(c)
    # Update TMP tables (for records not yet processed)
    MegaBar::TmpCheckbox.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    MegaBar::TmpPasswordField.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    MegaBar::TmpRadio.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    MegaBar::TmpSelect.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    MegaBar::TmpTextarea.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    MegaBar::TmpTextbox.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    MegaBar::TmpTextread.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    MegaBar::TmpDate.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    
    # Update permanent tables (for records already processed)
    MegaBar::Checkbox.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    MegaBar::PasswordField.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    MegaBar::Radio.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    MegaBar::Select.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    MegaBar::Textarea.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    MegaBar::Textbox.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    MegaBar::Textread.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
    MegaBar::Date.where(field_display_id: c[:tmp].id).update_all(field_display_id: c[:perm].id)
  end


  def fix_templates(c)
    # Update TMP tables (for records not yet processed)
    MegaBar::TmpTemplateSection.where(template_id: c[:tmp].id).update_all(template_id: c[:perm].id)
    
    # Update permanent tables (for records already processed)
    MegaBar::TemplateSection.where(template_id: c[:tmp].id).update_all(template_id: c[:perm].id)
  end

  def fix_model_display_collections(c)
    # purposefully blank
  end
  def fix_display_class(c)
    # purposefully blank
  end

  def fix_joins(c)
    # purposefully blank
  end

  def fix_template_sections(c)
    # purposefully blank
  end

  def fix_permission_levels(c)
    # purposefully blank
  end

  def get_mega_classes
    mega_classes = []
    mega_classes << {tmp_class: MegaBar::TmpModel, perm_class: MegaBar::Model, unique: [:classname], resolver: 'fix_model', condition: 'tmp.classname == perm.classname'}
    mega_classes << {tmp_class: MegaBar::TmpField, perm_class: MegaBar::Field, unique: [:model_id, :field], resolver: 'fix_fields', condition: 'tmp.model_id == perm.model_id && tmp.field == perm.field'}
    mega_classes << {tmp_class: MegaBar::TmpOption, perm_class: MegaBar::Option, unique: [:field_id, :value], resolver: 'fix_options', condition: 'tmp.field_id == perm.field_id && tmp.value == perm.value'}

    mega_classes << {tmp_class: MegaBar::TmpTheme, perm_class: MegaBar::Theme, unique: [:code_name], resolver: 'fix_themes', condition: 'tmp.code_name == perm.code_name'}
    mega_classes << {tmp_class: MegaBar::TmpSite, perm_class: MegaBar::Site, unique: [:code_name], resolver: 'fix_sites', condition: 'tmp.code_name == perm.code_name'}
    mega_classes << {tmp_class: MegaBar::TmpPortfolio, perm_class: MegaBar::Portfolio, unique: [:code_name], resolver: 'fix_portfolios', condition: 'tmp.code_name == perm.code_name'}

    mega_classes << {tmp_class: MegaBar::TmpTemplate, perm_class: MegaBar::Template, unique: [:code_name], resolver: 'fix_templates', condition: 'tmp.code_name == perm.code_name'}
    mega_classes << {tmp_class: MegaBar::TmpTemplateSection, perm_class: MegaBar::TemplateSection, unique: [:code_name, :template_id], resolver: 'fix_template_sections', condition: 'tmp.code_name == perm.code_name && tmp.template_id == perm.template_id'}

    mega_classes << {tmp_class: MegaBar::TmpPage, perm_class: MegaBar::Page, unique: [:path], resolver: 'fix_pages', condition: 'tmp.path == perm.path'}
    mega_classes << {tmp_class: MegaBar::TmpLayout, perm_class: MegaBar::Layout, unique: [:page_id, :name], resolver: 'fix_layouts', condition: 'tmp.page_id == perm.page_id && tmp.name == perm.name'}

    mega_classes << {tmp_class: MegaBar::TmpLayoutSection, perm_class: MegaBar::LayoutSection, unique: [:code_name], resolver: 'fix_layout_sections', condition: 'tmp.code_name == perm.code_name'}
    mega_classes << {tmp_class: MegaBar::TmpBlock, perm_class: MegaBar::Block, unique: [:layout_section_id, :name], resolver: 'fix_blocks', condition: 'tmp.layout_section_id == perm.layout_section_id && tmp.name == perm.name'}
    mega_classes << {tmp_class: MegaBar::TmpModelDisplay, perm_class: MegaBar::ModelDisplay, unique: [:block_id, :action, :series], resolver: 'fix_model_displays', condition: 'tmp.block_id == perm.block_id && tmp.action == perm.action'}
    mega_classes << {tmp_class: MegaBar::TmpModelDisplayCollection, perm_class: MegaBar::ModelDisplayCollection, unique: [:model_display_id], resolver: 'fix_model_display_collections', condition: 'tmp.model_display_id == perm.model_display_id'}
    mega_classes << {tmp_class: MegaBar::TmpFieldDisplay, perm_class: MegaBar::FieldDisplay, unique: [:model_display_id, :field_id], resolver: 'fix_field_displays', condition: 'tmp.model_display_id == perm.model_display_id && tmp.field_id == perm.field_id && tmp.format == perm.format'}

    mega_classes << {tmp_class: MegaBar::TmpCheckbox, perm_class: MegaBar::Checkbox, unique: [:field_display_id], resolver: 'fix_display_class', condition: 'tmp.field_display_id == perm.field_display_id'}
    mega_classes << {tmp_class: MegaBar::TmpPasswordField, perm_class: MegaBar::PasswordField, unique: [:field_display_id], resolver: 'fix_display_class', condition: 'tmp.field_display_id == perm.field_display_id'}
    mega_classes << {tmp_class: MegaBar::TmpRadio, perm_class: MegaBar::Radio, unique: [:field_display_id], resolver: 'fix_display_class', condition: 'tmp.field_display_id == perm.field_display_id'}
    mega_classes << {tmp_class: MegaBar::TmpSelect, perm_class: MegaBar::Select, unique: [:field_display_id], resolver: 'fix_display_class', condition: 'tmp.field_display_id == perm.field_display_id'}
    mega_classes << {tmp_class: MegaBar::TmpTextarea, perm_class: MegaBar::Textarea, unique: [:field_display_id], resolver: 'fix_display_class', condition: 'tmp.field_display_id == perm.field_display_id'}
    mega_classes << {tmp_class: MegaBar::TmpTextbox, perm_class: MegaBar::Textbox, unique: [:field_display_id], resolver: 'fix_display_class', condition: 'tmp.field_display_id == perm.field_display_id'}
    mega_classes << {tmp_class: MegaBar::TmpTextread, perm_class: MegaBar::Textread, unique: [:field_display_id], resolver: 'fix_display_class', condition: 'tmp.field_display_id == perm.field_display_id'}
    mega_classes << {tmp_class: MegaBar::TmpDate, perm_class: MegaBar::Date, unique: [:field_display_id], resolver: 'fix_display_class', condition: 'tmp.field_display_id == perm.field_display_id'}

    mega_classes << {tmp_class: MegaBar::TmpModelDisplayFormat, perm_class: MegaBar::ModelDisplayFormat, unique: [:name], resolver: 'fix_model_display_format', condition: 'tmp.name == perm.name'}

    mega_classes << {tmp_class: MegaBar::TmpLayable, perm_class: MegaBar::Layable, unique: [:layout_id, :layout_section_id], resolver: 'fix_joins', condition: 'tmp.layout_id == perm.layout_id && tmp.layout_section_id == perm.layout_section_id'}
    mega_classes << {tmp_class: MegaBar::TmpThemeJoin, perm_class: MegaBar::ThemeJoin, unique: [:theme_id, :themeable_type, :themeable_id], resolver: 'fix_joins', condition: 'tmp.theme_id == perm.theme_id && tmp.themeable_type == perm.themeable_type && tmp.themeable_id = perm.themeable_id'}
    mega_classes << {tmp_class: MegaBar::TmpSiteJoin, perm_class: MegaBar::SiteJoin, unique: [:site_id, :siteable_type, :siteable_id], resolver: 'fix_joins', condition: 'tmp.site_id == perm.site_id && tmp.siteable_type == perm.siteable_type && tmp.siteable_id = perm.siteable_id'}
    mega_classes << {tmp_class: MegaBar::TmpPermissionLevel, perm_class: MegaBar::PermissionLevel, unique: [:level_name], resolver: 'fix_permission_levels', condition: 'tmp.level_name == perm.level_name'}
    return mega_classes
  end


  task :dump_seeds, [:mega] => :environment do |t, args|
    # Set the file path once
    seed_file = 'db/mega_bar.seeds.rb'
    File.open(seed_file, 'w') {|file| file.truncate(0) }

    if args[:mega].present?
      mega_bar_model_ids = MegaBar::Model.where(modyule: 'MegaBar').order(:id).pluck(:id)
      mega_bar_page_ids = MegaBar::Page.where(mega_page: 'mega').order(:id).pluck(:id)
    else
      mega_bar_model_ids = MegaBar::Model.all.order(:id).pluck(:id)
      mega_bar_page_ids = MegaBar::Page.all.order(:id).pluck(:id) 
    end
    mega_bar_theme_ids =  MegaBar::Theme.all.order(:id).pluck(:id) #tbd.
    
    mega_bar_template_ids = MegaBar::Template.all.order(:id).pluck(:id)
    mega_bar_fields =  MegaBar::Field.where(model_id: mega_bar_model_ids).order(:id).pluck(:id)
    mega_bar_layout_ids = MegaBar::Layout.where(page_id: mega_bar_page_ids).order(:id).pluck(:id)
    mega_bar_layable_ids = MegaBar::Layable.where(layout_id: mega_bar_layout_ids).order(:id).pluck(:id)
    mega_bar_layout_section_ids = MegaBar::LayoutSection.where(id: MegaBar::Layable.where(layout_section_id: mega_bar_layable_ids).order(:id).pluck(:id)).order(:id).pluck(:id)
    
    mega_bar_block_ids = MegaBar::Block.where(layout_section_id: mega_bar_layout_section_ids).order(:id).pluck(:id)
    mega_bar_model_display_ids = MegaBar::ModelDisplay.where(block_id: mega_bar_block_ids).order(:id).pluck(:id)
    mega_bar_model_display_collection_ids =  MegaBar::ModelDisplayCollection.where(model_display_id: mega_bar_model_display_ids).order(:id).pluck(:id)
    mega_bar_field_display_ids =  MegaBar::FieldDisplay.where(model_display_id: mega_bar_model_display_ids).order(:id).pluck(:id)


    # First get all the records
    themes = MegaBar::Theme.where(id: mega_bar_theme_ids).order(:id)
    portfolios = MegaBar::Portfolio.where(theme_id: mega_bar_theme_ids).order(:id)
    sites = MegaBar::Site.where(theme_id: mega_bar_theme_ids).order(:id)

    templates = MegaBar::Template.where(id: mega_bar_template_ids).order(:id)
    template_sections = MegaBar::TemplateSection.where(template_id: mega_bar_template_ids).order(:id)

    models = MegaBar::Model.where(id: mega_bar_model_ids).order(:id)
    fields = MegaBar::Field.where(model_id: mega_bar_model_ids).order(:id)
    options = MegaBar::Option.where(field_id: mega_bar_fields).order(:id)
    model_display_formats = MegaBar::ModelDisplayFormat.all.order(:id)

    pages = MegaBar::Page.where(id: mega_bar_page_ids).order(:id)
    layouts = MegaBar::Layout.where(id: mega_bar_layout_ids).order(:id)
    layout_sections = MegaBar::LayoutSection.where(id: mega_bar_layout_section_ids).order(:id)

    blocks = MegaBar::Block.where(id: mega_bar_block_ids).order(:id)
    model_displays = MegaBar::ModelDisplay.where(id: mega_bar_model_display_ids).order(:id)
    model_display_collections = MegaBar::ModelDisplayCollection.where(id: mega_bar_model_display_collection_ids).order(:id)
    field_displays = MegaBar::FieldDisplay.where(id: mega_bar_field_display_ids).order(:id)

    checkboxes = MegaBar::Checkbox.where(field_display_id: mega_bar_field_display_ids).order(:id)
    password_fields = MegaBar::PasswordField.where(field_display_id: mega_bar_field_display_ids).order(:id)
    radios = MegaBar::Radio.where(field_display_id: mega_bar_field_display_ids).order(:id)
    selects = MegaBar::Select.where(field_display_id: mega_bar_field_display_ids).order(:id)
    textareas = MegaBar::Textarea.where(field_display_id: mega_bar_field_display_ids).order(:id)
    textboxes = MegaBar::Textbox.where(field_display_id: mega_bar_field_display_ids).order(:id)
    textreads = MegaBar::Textread.where(field_display_id: mega_bar_field_display_ids).order(:id)
    dates = MegaBar::Date.where(field_display_id: mega_bar_field_display_ids).order(:id)

    layables = MegaBar::Layable.where(id: mega_bar_layable_ids).order(:id)
    theme_joins = theme_joins(mega_bar_block_ids, mega_bar_layout_ids).order(:id)
    site_joins = site_joins(mega_bar_block_ids, mega_bar_layout_ids).order(:id)
    permission_levels = MegaBar::PermissionLevel.all.order(:id)

    # Then do all the dumps
    SeedDump.dump(themes, {file: seed_file, append: true})
    SeedDump.dump(portfolios, {file: seed_file, append: true})
    SeedDump.dump(sites, {file: seed_file, append: true})
    SeedDump.dump(templates, {file: seed_file, append: true})
    SeedDump.dump(template_sections, {file: seed_file, append: true})

    SeedDump.dump(models, {file: seed_file, append: true})
    SeedDump.dump(fields, {file: seed_file, append: true})
    SeedDump.dump(options, {file: seed_file, append: true})
    SeedDump.dump(model_display_formats, {file: seed_file, append: true})

    SeedDump.dump(pages, {file: seed_file, append: true})
    SeedDump.dump(layouts, {file: seed_file, append: true})
    SeedDump.dump(layout_sections, {file: seed_file, append: true})

    SeedDump.dump(blocks, {file: seed_file, append: true})
    SeedDump.dump(model_displays, {file: seed_file, append: true})
    SeedDump.dump(model_display_collections, {file: seed_file, append: true})
    SeedDump.dump(field_displays, {file: seed_file, append: true})

    SeedDump.dump(checkboxes, {file: seed_file, append: true})
    SeedDump.dump(password_fields, {file: seed_file, append: true})
    SeedDump.dump(radios, {file: seed_file, append: true})
    SeedDump.dump(selects, {file: seed_file, append: true})
    SeedDump.dump(textareas, {file: seed_file, append: true})
    SeedDump.dump(textboxes, {file: seed_file, append: true})
    SeedDump.dump(textreads, {file: seed_file, append: true})
    SeedDump.dump(dates, {file: seed_file, append: true})

    SeedDump.dump(layables, {file: seed_file, append: true})
    SeedDump.dump(theme_joins, {file: seed_file, append: true})
    SeedDump.dump(site_joins, {file: seed_file, append: true})
    SeedDump.dump(permission_levels, {file: seed_file, append: true})

    File.open(Rails.root.join('db', 'mega_bar.seeds.rb'), "r+") do |file|
      #note, this will change your data! If you wanted to store a string like MegaBar::Whatever in the db, it'll be changed here and you have to fix that in the data_load.
      text = File.read(file)
      regex = 'MegaBar::'
      replace = 'MegaBar::Tmp'
      text = text.gsub(regex, replace)
      File.open(file, "w") {|file| file.puts text }
    end

    puts "dumped seeds"
  end


  task :test_temps => :environment do
    MegaBar::Model.new  ([
      {id: 1, classname: "Model", schema: "sqlite", tablename: "models", name: "Model", default_sort_field: "id", created_at: "2014-05-05 17:27:28", updated_at: "2014-12-26 00:58:09"},
      {id: 2, classname: "Attribute", schema: "sqlite", tablename: "fields", name: "Fields", default_sort_field: "id", created_at: "2014-05-05 17:28:21", updated_at: "2014-05-21 22:21:20"},
      {id: 3, classname: "ModelDisplay", schema: "sqlite", tablename: "model_displays", name: "Model Displayyyyy", default_sort_field: "model_id", created_at: "2014-05-05 18:12:24", updated_at: "2014-05-21 18:35:52"},
      {id: 4, classname: "FieldDisplay", schema: "sqlite", tablename: "field_displays", name: "Field Displays", default_sort_field: "id", created_at: "2014-05-05 19:20:12", updated_at: "2014-05-21 22:33:58"},
      {id: 5, classname: "RecordsFormat", schema: "sqlite", tablename: "recordsformats", name: "Records Format", default_sort_field: "name", created_at: "2014-05-05 19:34:38", updated_at: "2014-12-24 07:19:00"},
      {id: 6, classname: "Textbox", schema: "another", tablename: "textboxes", name: "Text Boxes", default_sort_field: "id", created_at: "2014-05-12 17:43:13", updated_at: "2014-05-21 21:51:02"},
      {id: 7, classname: "Textread", schema: "oyyyy", tablename: "textreads", name: "Text Display", default_sort_field: "id", created_at: "2014-05-12 22:59:05", updated_at: "2014-05-23 16:30:59"},
      {id: 8, classname: "Select", schema: "odfdfd", tablename: "selects", name: "Select Menus", default_sort_field: "id", created_at: "2014-05-12 23:02:23", updated_at: "2014-05-23 16:31:23"},
      {id: 9, classname: "Date", schema: "odfdfd", tablename: "dates", name: "Dates", default_sort_field: "id", created_at: "2014-05-12 23:02:23", updated_at: "2014-05-23 16:31:23"}
    ])
  end

  task :truncate_all_test_data_again => :environment do
    truncate_etc
  end

  task :truncate_all_test_data_once => :environment do
    truncate_etc
  end
  task :oink => :environment do
    mega_bar_theme_ids =  MegaBar::Theme.all.pluck(:id) #tbd.
    mega_bar_page_ids = MegaBar::Page.where(mega_page: 'mega')
    # mega_bar_pages = MegaBar::Page.where(id: mega_bar_page_ids).pluck(:id, :path)
    mega_bar_layout_ids = MegaBar::Layout.where(page_id: mega_bar_page_ids).pluck(:id)
    mega_bar_block_ids = MegaBar::Block.where(layout_id: mega_bar_layout_ids).pluck(:id)
    theme_join = theme_joins(mega_bar_block_ids, mega_bar_layout_ids)
    site_join = site_joins(mega_bar_block_ids, mega_bar_layout_ids)

    puts  "theme join size:  #{theme_join.size}"

    puts  "site join size: #{site_join.size}"

  end
  def theme_joins(blocks, layouts)
    MegaBar::ThemeJoin.where("( themeable_type = 'MegaBar::Block' and themeable_id in (" + blocks.join(",") + ") ) or (themeable_type = 'MegaBar::Layout' and themeable_id in (" + layouts.join(",") + ") )")
  end

  def site_joins(blocks, layouts)
    MegaBar::SiteJoin.where("( siteable_type = 'MegaBar::Block' and siteable_id in (" + blocks.join(",") + ") ) or (siteable_type = 'MegaBar::Layout' and siteable_id in (" + layouts.join(",") + ") )")
  end

  def truncate_etc
    get_mega_classes.each do |mc|
      puts "delete from #{mc[:perm_class].table_name}"
      ActiveRecord::Base.connection.execute("delete from #{mc[:perm_class].table_name}")
      ActiveRecord::Base.connection.execute("DELETE FROM SQLITE_SEQUENCE WHERE name='#{mc[:perm_class].table_name}'")
      ActiveRecord::Base.connection.execute("delete from #{mc[:tmp_class].table_name}")
      ActiveRecord::Base.connection.execute("DELETE FROM SQLITE_SEQUENCE WHERE name='#{mc[:tmp_class].table_name}'")
    end
  end

  def prompt(conflict, callback)
    begin
      STDOUT.puts conflict[:text]
      STDOUT.puts "Are you sure you want to proceed with issuing new ids? (y/n)"
      input = STDIN.gets.strip.downcase
    end until %w(y n).include?(input)
    if input == 'y'
      callback.call(conflict)
    else
      # We know at this point that they've explicitly said no,
      # rather than fumble the keyboard
      STDOUT.puts "Ok we won't do anything with that"
      return
    end
  end
  task :ok => :environment do
    MegaBar::Layout.all.each do |layout|
      layout_section = MegaBar::LayoutSection.create(code_name: layout.name.parameterize.underscore + '_full_top')
      layable = MegaBar::Layable.create(layout_id: layout.id, layout_section_id: layout_section.id, template_section_id: 1)
      layout_section = MegaBar::LayoutSection.create(code_name: layout.name.parameterize.underscore + '_main')
      layable = MegaBar::Layable.create(layout_id: layout.id, layout_section_id: layout_section.id, template_section_id: 2)
      layout.blocks.each do | block |
        block.layout_section_id = layout_section.id
        block.save
      end
      layout_section = MegaBar::LayoutSection.create(code_name: layout.name.parameterize.underscore + '_full_bottom')
      layable = MegaBar::Layable.create(layout_id: layout.id, layout_section_id: layout_section.id, template_section_id: 3)

    end
  end

  task path: :environment do
    require "utils/routes_formatter"
    require 'action_dispatch/routing/inspector'
    all_routes = Rails.application.routes.routes
    inspector = ActionDispatch::Routing::RoutesInspector.new(all_routes)
    puts inspector.format(ActionDispatch::Routing::MarkdownFormatter.new(ENV['path']), ENV['CONTROLLER'])
  end
  task all: :environment do
    puts inspector.format(ActionDispatch::Routing::MarkdownFormatter.new, ENV['CONTROLLER'])
  end

end
