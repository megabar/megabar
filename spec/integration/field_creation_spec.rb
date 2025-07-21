require 'spec_helper'

RSpec.describe "Field Creation Integration", type: :integration do
  # This tests the Field creation workflow that auto-creates FieldDisplays
  # Based on the field creation form showing the model_display_ids multi-select
  
  before(:each) do
    # Clean up any existing test data
    [
      MegaBar::FieldDisplay,
      MegaBar::ModelDisplay,
      MegaBar::Block,
      MegaBar::Layable,
      MegaBar::LayoutSection,
      MegaBar::Layout,
      MegaBar::Page,
      MegaBar::Field,
      MegaBar::Model,
      MegaBar::TemplateSection,
      MegaBar::Template
    ].each(&:destroy_all)

    # Skip database migration callbacks that require real DB connections
    MegaBar::Field.skip_callback("create", :after, :make_migration) rescue nil
  end

  after(:each) do
    # Re-enable callbacks for other tests
    MegaBar::Field.set_callback("create", :after, :make_migration) rescue nil
  end

  let(:test_template) do
    template = MegaBar::Template.create!(
      name: 'No Columns Template',
      code_name: 'no_columns'
    )
    MegaBar::TemplateSection.create!(
      template: template,
      name: 'Main Section',
      code_name: 'main',
      position: 1
    )
    template
  end

  let(:test_model) do
    # Create a model with a page and model displays (using our working model creation workflow)
    MegaBar::Model.create!(
      name: "Bestie",
      classname: "Bestie", 
      tablename: "besties",
      schema: "sqlite",
      mega_model: "regular",
      modyule: "",
      make_page: test_template.id,
      default_sort_field: "id",
      default_sort_order: "desc"
    )
  end

  let(:existing_model_displays) do
    # Get the model displays that were auto-created during model creation
    expected_path = "/#{test_model.classname.underscore.pluralize}"
    page = MegaBar::Page.find_by(path: expected_path)
    layout = MegaBar::Layout.find_by(page: page)
    main_section = layout.layout_sections.find { |ls| ls.code_name.include?('main') }
    main_block = main_section.blocks.first
    main_block.model_displays
  end

  describe "Field Creation with Model Display Selection" do
    it "creates a field with field displays for selected model displays" do
      puts "\n🧪 TESTING: Field Creation with model_display_ids (like the form shows)"
      puts "-" * 60

      # Ensure model with displays exists
      model = test_model
      model_displays = existing_model_displays
      puts "🏗️ Using Model #{model.id}: '#{model.name}' with #{model_displays.count} model displays"

      model_displays.each do |md|
        puts "  📊 ModelDisplay #{md.id}: #{md.action} (format: #{md.format})"
      end

      # Select some model displays for the field (simulate form multi-select)
      selected_display_ids = model_displays.pluck(:id).take(2)  # Select first 2 displays
      puts "📝 Selected model_display_ids: #{selected_display_ids}"

      # Simulate field creation form submission exactly as shown in HTML
      field_params = {
        model_id: model.id,
        schema: "sqlite",
        tablename: model.tablename,
        field: "name",                           # field[field]
        default_value: "",                       # field[default_value]
        default_data_format: "textread",         # field[default_data_format] - for show/index
        default_data_format_edit: "textbox",     # field[default_data_format_edit] - for edit/new
        accessor: false,                         # field[accessor] checkbox
        data_type: "string",                     # field[data_type]
        option_borrow: "",                       # field[option_borrow]
        model_display_ids: selected_display_ids, # field[model_display_ids][] - THE KEY FEATURE
        filter_type: "contains",                 # field[filter_type]
        tool_tip: "Enter the person's name",    # field[tool_tip]
        instructions: "Full name required",     # field[instructions]
        default_show_wrapper: "div",            # field[default_show_wrapper]
        default_index_wrapper: "div"            # field[default_index_wrapper]
      }

      puts "📝 Field params: #{field_params.except(:model_display_ids)}"
      puts "📝 Model display IDs: #{field_params[:model_display_ids]}"

      # Create field exactly as the form would
      field = MegaBar::Field.create!(field_params)

      puts "🏗️ Created Field #{field.id}: '#{field.field}' (#{field.data_type})"
      puts "   Model: #{field.model_id}"
      puts "   Table: #{field.tablename}"
      puts "   Default format (show/index): #{field.default_data_format}"
      puts "   Default format (edit/new): #{field.default_data_format_edit}"

      # Verify field displays were auto-created for selected model displays
      field_displays = MegaBar::FieldDisplay.where(field_id: field.id)
      puts "📊 Field displays auto-created: #{field_displays.count}"

      expect(field_displays.count).to eq(selected_display_ids.count)

      # Verify each selected model display got a field display
      selected_display_ids.each do |model_display_id|
        field_display = field_displays.find { |fd| fd.model_display_id == model_display_id }
        expect(field_display).to be_present

        model_display = MegaBar::ModelDisplay.find(model_display_id)
        
        # Verify the format was set correctly based on the action
        expected_format = if ['edit', 'new'].include?(model_display.action)
                           field.default_data_format_edit
                         else
                           field.default_data_format
                         end

        expect(field_display.format).to eq(expected_format)
        puts "  ✅ #{model_display.action.capitalize} display: format '#{field_display.format}' (expected: #{expected_format})"
      end

      puts "✅ Field creation with model display selection successful!"
    end

    it "creates a field without field displays when no model displays are selected" do
      puts "\n🧪 TESTING: Field Creation without model_display_ids"
      puts "-" * 60

      model = test_model
      puts "🏗️ Using Model #{model.id}: '#{model.name}'"

      # Create field without selecting any model displays
      field = MegaBar::Field.create!(
        model_id: model.id,
        schema: "sqlite",
        tablename: model.tablename,
        field: "description",
        default_data_format: "textarea",
        default_data_format_edit: "textarea", 
        data_type: "text",
        model_display_ids: []  # No model displays selected
      )

      puts "🏗️ Created Field #{field.id}: '#{field.field}'"

      # Should NOT create any field displays
      field_displays = MegaBar::FieldDisplay.where(field_id: field.id)
      expect(field_displays.count).to eq(0)
      puts "✅ No field displays auto-created (correct behavior)"
    end

    it "handles different data formats correctly for different actions" do
      puts "\n🧪 TESTING: Data Format Assignment by Action Type"
      puts "-" * 60

      model = test_model
      model_displays = existing_model_displays
      puts "🏗️ Testing format assignment for #{model_displays.count} model displays"

      # Create field with all model displays selected
      field = MegaBar::Field.create!(
        model_id: model.id,
        schema: "sqlite", 
        tablename: model.tablename,
        field: "email",
        default_data_format: "textread",      # For show/index actions
        default_data_format_edit: "textbox",  # For edit/new actions
        data_type: "string",
        model_display_ids: model_displays.pluck(:id)
      )

      puts "🏗️ Created Field #{field.id}: '#{field.field}'"
      puts "   Show/Index format: #{field.default_data_format}"
      puts "   Edit/New format: #{field.default_data_format_edit}"

      # Check each field display has correct format based on action
      field_displays = MegaBar::FieldDisplay.where(field_id: field.id)
      
      field_displays.each do |field_display|
        model_display = MegaBar::ModelDisplay.find(field_display.model_display_id)
        
        expected_format = if ['edit', 'new'].include?(model_display.action)
                           field.default_data_format_edit  # 'textbox'
                         else
                           field.default_data_format       # 'textread'
                         end

        expect(field_display.format).to eq(expected_format)
        puts "  📊 #{model_display.action.capitalize}: #{field_display.format} (✅ correct)"
      end

      puts "✅ Data format assignment working correctly!"
    end
  end

  describe "Real Form Simulation" do
    it "simulates the exact field creation form submission" do
      puts "\n🧪 TESTING: Exact Field Form Submission Simulation"
      puts "-" * 60

      # Set up model with displays first
      model = test_model
      model_displays = existing_model_displays
      puts "📋 Model: #{model.name} (#{model.classname})"
      puts "📋 Available model displays: #{model_displays.count}"

      # Simulate selecting 3 out of 4 model displays (typical user behavior)
      selected_displays = model_displays.take(3)
      selected_ids = selected_displays.pluck(:id)

      puts "📝 Simulating form with #{selected_displays.count} selected displays:"
      selected_displays.each do |md|
        puts "  📊 #{md.action.capitalize} (ID: #{md.id})"
      end

      # Simulate exact form parameters from the HTML form
      form_params = {
        model_id: model.id,                       # Hidden/calculated from URL
        schema: "sqlite",                         # field[schema]  
        tablename: model.tablename,               # field[tablename] - select
        field: "full_name",                       # field[field] - text input
        default_value: "",                        # field[default_value]
        default_data_format: "textread",          # field[default_data_format] - select
        default_data_format_edit: "textbox",      # field[default_data_format_edit] - select
        accessor: false,                          # field[accessor] - checkbox
        data_type: "string",                      # field[data_type] - select
        option_borrow: "",                        # field[option_borrow]
        model_display_ids: selected_ids,          # field[model_display_ids][] - multi-select ⭐
        filter_type: "contains",                  # field[filter_type] - select
        tool_tip: "Enter the full name of the person", # field[tool_tip] - textarea
        instructions: "First and last name",     # field[instructions] - text
        default_show_wrapper: "div",             # field[default_show_wrapper] - select
        default_index_wrapper: "div"             # field[default_index_wrapper] - select
      }

      puts "📝 Form params (excluding model_display_ids): #{form_params.except(:model_display_ids)}"

      # Create field exactly as the form would
      field = MegaBar::Field.create!(form_params)

      puts "🏗️ Field created from form simulation: #{field.id}"
      puts "   Field name: #{field.field}"
      puts "   Data type: #{field.data_type}" 
      puts "   Model: #{field.model_id}"
      puts "   Tablename: #{field.tablename}"

      # Verify the complete workflow worked
      field_displays = MegaBar::FieldDisplay.where(field_id: field.id)
      expect(field_displays.count).to eq(selected_ids.count)
      puts "📊 Field displays created: #{field_displays.count}"

      # Verify each field display is correctly configured
      field_displays.each do |fd|
        model_display = MegaBar::ModelDisplay.find(fd.model_display_id)
        
        # Check format assignment
        expected_format = if ['edit', 'new'].include?(model_display.action)
                           field.default_data_format_edit
                         else  
                           field.default_data_format
                         end

        expect(fd.format).to eq(expected_format)
        expect(fd.header).to eq(field.field.humanize)  # Should be "Full name"
        
        puts "  📋 #{model_display.action.capitalize}: format='#{fd.format}', header='#{fd.header}'"
      end

      puts "✅ Complete field form simulation successful!"
    end

    it "handles complex field types and options" do
      puts "\n🧪 TESTING: Complex Field Types and Options"
      puts "-" * 60

      model = test_model  
      model_displays = existing_model_displays

      # Test boolean field with checkbox format
      boolean_field = MegaBar::Field.create!(
        model_id: model.id,
        schema: "sqlite",
        tablename: model.tablename,
        field: "is_active",
        default_data_format: "textread",      # Show as text on display
        default_data_format_edit: "checkbox", # Edit with checkbox
        data_type: "boolean",
        model_display_ids: model_displays.pluck(:id),
        tool_tip: "Check if the record is active",
        default_value: "false"
      )

      puts "🔧 Created boolean field: #{boolean_field.field}"

      # Test select field with options
      select_field = MegaBar::Field.create!(
        model_id: model.id,
        schema: "sqlite", 
        tablename: model.tablename,
        field: "status",
        default_data_format: "textread",
        default_data_format_edit: "select",
        data_type: "string",
        model_display_ids: model_displays.pluck(:id),
        option_borrow: "status_options",  # References option set
        filter_type: "exact"
      )

      puts "🔧 Created select field: #{select_field.field}"

      # Test accessor field (not a real database column)
      accessor_field = MegaBar::Field.create!(
        model_id: model.id,
        schema: "sqlite",
        tablename: "accessor",  # Special tablename for accessors
        field: "full_display_name",
        default_data_format: "textread",
        default_data_format_edit: "textread",  # Read-only in forms too
        data_type: "string",
        accessor: true,  # This is an accessor field
        model_display_ids: [model_displays.find { |md| md.action == 'show' }.id]  # Only on show page
      )

      puts "🔧 Created accessor field: #{accessor_field.field}"

      # Verify all field displays were created correctly
      total_displays = MegaBar::FieldDisplay.where(
        field_id: [boolean_field.id, select_field.id, accessor_field.id]
      )

      expected_count = (model_displays.count * 2) + 1  # 2 full sets + 1 show-only
      expect(total_displays.count).to eq(expected_count)

      puts "📊 Total field displays created: #{total_displays.count} (expected: #{expected_count})"

      # Check specific format assignments
      boolean_edit_display = MegaBar::FieldDisplay.joins(:model_display)
                               .where(field_id: boolean_field.id)
                               .where(mega_bar_model_displays: { action: 'edit' })
                               .first

      expect(boolean_edit_display.format).to eq('checkbox')
      puts "  ✅ Boolean edit field uses checkbox format"

      select_edit_display = MegaBar::FieldDisplay.joins(:model_display)
                               .where(field_id: select_field.id) 
                               .where(mega_bar_model_displays: { action: 'edit' })
                               .first

      expect(select_edit_display.format).to eq('select')
      puts "  ✅ Select edit field uses select format"

      puts "✅ Complex field types handled correctly!"
    end
  end

  describe "Field Display Auto-Creation Logic" do
    it "respects the make_field_displays callback workflow" do
      puts "\n🧪 TESTING: Field Display Auto-Creation Workflow"
      puts "-" * 60

      model = test_model
      model_displays = existing_model_displays
      puts "🔧 Testing auto-creation logic with #{model_displays.count} model displays"

      # Create field and track the auto-creation process
      field = MegaBar::Field.new(
        model_id: model.id,
        schema: "sqlite",
        tablename: model.tablename,
        field: "auto_test_field",
        default_data_format: "textread",
        default_data_format_edit: "textbox",
        data_type: "string",
        model_display_ids: model_displays.pluck(:id)
      )

      puts "📝 Field prepared with model_display_ids: #{field.model_display_ids}"

      # Save the field (this triggers the make_field_displays callback)
      field.save!

      puts "💾 Field saved, triggering make_field_displays callback"

      # Verify the callback worked
      field_displays = MegaBar::FieldDisplay.where(field_id: field.id)
      expect(field_displays.count).to eq(model_displays.count)

      puts "📊 Field displays auto-created: #{field_displays.count}"

      # Verify each display is linked to the correct model display
      model_displays.each do |model_display|
        matching_field_display = field_displays.find { |fd| fd.model_display_id == model_display.id }
        expect(matching_field_display).to be_present
        puts "  🔗 #{model_display.action.capitalize} → FieldDisplay #{matching_field_display.id}"
      end

      puts "✅ Auto-creation workflow working correctly!"
    end

    it "handles field creation without model_display_ids gracefully" do
      puts "\n🧪 TESTING: Field Creation Without model_display_ids"
      puts "-" * 60

      model = test_model

      # Create field without model_display_ids (edge case)
      field = MegaBar::Field.create!(
        model_id: model.id,
        schema: "sqlite",
        tablename: model.tablename,
        field: "standalone_field",
        default_data_format: "textread",
        default_data_format_edit: "textbox",
        data_type: "string"
        # Note: no model_display_ids provided
      )

      puts "🏗️ Created standalone field: #{field.field}"

      # Should not create any field displays
      field_displays = MegaBar::FieldDisplay.where(field_id: field.id)
      expect(field_displays.count).to eq(0)

      puts "✅ No field displays created (correct for standalone field)"
    end
  end
end 