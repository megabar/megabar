# desc "This is the file that you don't really want to know about! "
# Its a file that handles the complexities of loading lots of configuration data into new and existing installations,
#  as well as dumping configuration to be committed back to megabar master. "
# if ever new core tables are added to megabar, you need to carefully add it in the right places in this file
# That's a little tricky to do. A free six pack of your favorite micro brew if you can add one properly!

# task :mega_bar do
#   # Task goes here
# end

namespace :mega_bar do
  desc 'engine_init' # just for testing
  task engine_init: :environment do
    # TODO see if it already was run.
    line = 'Rails.application.routes.draw do'
    text = File.read('config/routes.rb')

    new_contents = text.gsub( /(#{Regexp.escape(line)})/mi, "#{line}\n\n  MegaRoute.load(['/mega-bar']).each do |route|\n    match route[:path] => \"\#{route[:controller]}\#\#{route[:action]}\", via: route[:method], as: route[:as]\n  end \n  ##### MEGABAR BEGIN #####\n  mount MegaBar::Engine, at: '/mega-bar'\n  ##### MEGABAR END #####\n")
    File.open('config/routes.rb', "w") {|file| file.puts new_contents }

    File.open('app/assets/javascripts/application.js', 'a') { |f|
      f.puts "//= require mega_bar/application.js "
    }
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
    route_classes = [MegaBar::Page, MegaBar::Layout, MegaBar::Block, MegaBar::ModelDisplay, MegaBar::Model]
    mega_classes.delete_if { |x| not route_classes.include? x[:perm_class] } if args[:model_set] == 'routes'

    all_conflicts = []
    # display_classes = [[MegaBar::TmpTextbox, MegaBar::Textbox, 'TextBox'],[MegaBar::TmpTextread, MegaBar::Textread, 'TextRead']]
    mega_ids = []

    mega_classes.each do |mc|
      mc[:tmp_class].delete_all # delete everything that is in the tmp_tables
      mega_ids << mc[:id]
    end
    file = args[:file] || "../../db/mega_bar.seeds.rb"
    require_relative file #LOADS SEEDS INTO TMP TABLES
    # done resetting tmp tables.
    # start conflict detection
    mega_classes.each do |mc|
      mc[:tmp_class].all.each do |tmp|
        perm = mc[:perm_class].find_by_id(tmp.id)
        next unless perm.present?
        unless eval(mc[:condition])
          all_conflicts << {tmp: tmp, perm: perm, mc: mc}
        end
      end
    end
    # start conflict resolution
    all_conflicts.each do |c|
      method(c[:mc][:resolver]).call(c)
    end
    # start loading tmp table data into real tables.
    MegaBar::Block.skip_callback(       'save',   :after, :make_model_displays)
    MegaBar::Field.skip_callback(       'create', :after, :make_migration)
    MegaBar::Field.skip_callback(       'save',   :after, :make_field_displays)
    MegaBar::FieldDisplay.skip_callback('save',   :after, :make_data_display)
    MegaBar::Model.skip_callback(       'create', :after, :make_all_files)
    MegaBar::Model.skip_callback(       'create', :before, :standardize_modyule)
    MegaBar::Model.skip_callback(       'create', :before, :standardize_classname)
    MegaBar::Model.skip_callback(       'create', :before, :standardize_tablename)
    MegaBar::Model.skip_callback(       'create', :after, :make_page_for_model)
    MegaBar::ModelDisplay.skip_callback('save',   :after, :make_field_displays)
    MegaBar::Page.skip_callback(        'create', :after, :create_layout_for_page)
    MegaBar::Layout.skip_callback(      'create', :after, :create_block_for_layout)

    mega_classes.each do |mc|
      mc[:tmp_class].all.each do |tmp|
        # puts tmp.inspect #good debug point!
        perm = mc[:perm_class].find_or_initialize_by(id: tmp.id)
        tmp.attributes.each do |attr|
          perm[attr[0].to_sym] = attr[1] unless attr[0] == 'id'
        end
        perm.save # written 141231
      end
      puts 'loaded ' + mc[:perm_class].to_s
    end
    MegaBar::Block.set_callback(       'save',   :after, :make_model_displays)
    MegaBar::Field.set_callback(       'create', :after, :make_migration)
    MegaBar::Field.set_callback(       'save',   :after, :make_field_displays)
    # MegaBar::FieldDisplay.set_callback('save',   :after, :make_data_display)
    MegaBar::Model.set_callback(       'create', :after, :make_all_files)
    MegaBar::Model.set_callback(       'create', :before, :standardize_modyule)
    MegaBar::Model.set_callback(       'create', :before, :standardize_classname)
    MegaBar::Model.set_callback(       'create', :before, :standardize_tablename)
    MegaBar::Model.set_callback(       'create', :after, :make_page_for_model)
    MegaBar::ModelDisplay.set_callback('save',   :after, :make_field_displays)
    MegaBar::Page.set_callback(        'create', :after, :create_layout_for_page)
    MegaBar::Layout.set_callback(      'create', :after, :create_block_for_layout)

    # end of main function for loading data
    # important sub functions are below
    puts "Loaded Data"
  end


  def higher_plus_one(a, b)
    c = a >= b ? a+1 : b+1
  end

  def make_new_perm(c)
    new_obj = c[:perm].class.new
    c[:tmp].attributes.each { |attr| new_obj[attr[0].to_sym] = attr[1] unless attr[0] == 'id' }
    new_obj.id = higher_plus_one(c[:tmp].class.maximum(:id), c[:perm].class.maximum(:id))
    new_obj.save # now we have a new model record in the real db
    c[:tmp].class.find(c[:tmp].id).update(id: new_obj.id) # so take the tmp one. #and give it the new one's id.
    return new_obj
  end
  def fix_model(c)
    new_obj = make_new_perm(c)
    puts 'Incoming model ' + c[:tmp].id + ' with class ' + c[:tmp].classname + ' had to be issued a new id ' + new_obj.id + '.'
    ##### FIELDS
    MegaBar::TmpModelDisplay.where(model_id: c[:tmp].id).update_all(model_id: new_obj.id)
    MegaBar::TmpField.where(model_id: c[:tmp].id).each { |f| f.update(model_id: new_obj.id) }
    MegaBar::TmpBlock.where(nest_level_1: c[:tmp].id).each { |f| f.update(nest_level_1: new_obj.id) }
    MegaBar::TmpBlock.where(nest_level_2: c[:tmp].id).each { |f| f.update(nest_level_2: new_obj.id) }
  end
  # end of model stuff

  def fix_fields(c)
    new_obj = make_new_perm(c)
    MegaBar::TmpFieldDisplay.where(field_id: c[:tmp].id).update_all(field_id: new_obj.id)
    MegaBar::TmpOption.where(field_id: c[:tmp].id).update_all(field_id: new_obj.id)
  end

  def fix_model_display_format(c)
    new_obj = make_new_perm(c)
  end

  def fix_options(c)
    new_obj = make_new_perm(c)
  end

  def fix_pages(c)
    new_obj = make_new_perm(c)
    MegaBar::Layout.where(page_id: c[:tmp].id).update_all(page_id: new_obj.id)
  end

  def fix_layouts(c)
     new_obj = make_new_perm(c)
     MegaBar::TmpBlock.where(layout_id: c[:tmp].id).update_all(layout_id: new_obj.id)
  end

  def fix_blocks(c)
     new_obj = make_new_perm(c)
     MegaBar::TmpModelDisplay.where(block_id: c[:tmp].id).update_all(block_id: new_obj.id)
  end

  def fix_model_displays(c)
    new_obj = make_new_perm(c)
    MegaBar::TmpFieldDisplay.where(model_display_id: c[:tmp].id).update_all(model_display_id: new_obj.id)
  end

  def fix_field_displays(c)
    new_obj = make_new_perm(c)
    update_data_displays_with_new_field_display_id(c[:tmp].id, new_obj.id)
    MegaBar::TmpTextbox.where(field_display_id: c[:tmp].id).each do |tb|
      tb.update(field_display_id: new_obj.id)
    end
    MegaBar::TmpTextread.where(field_display_id: c[:tmp].id).each do |tb|
      tb.update(field_display_id: new_obj.id)
    end
    MegaBar::TmpSelect.where(field_display_id: c[:tmp].id).each do |tb|
      tb.update(field_display_id: new_obj.id)
    end
  end


  def get_mega_classes
    mega_classes = []
    mega_classes << {id: 1, tmp_class: MegaBar::TmpModel, perm_class: MegaBar::Model, unique: [:classname], resolver: 'fix_model', condition: 'tmp.classname == perm.classname'}
    mega_classes << {id: 2, tmp_class: MegaBar::TmpField, perm_class: MegaBar::Field, unique: [:model_id, :field], resolver: 'fix_fields', condition: 'tmp.model_id == perm.model_id && tmp.field == perm.field'}
    mega_classes << {id: 17, tmp_class: MegaBar::TmpOption, perm_class: MegaBar::Option, unique: [:field_id, :value], resolver: 'fix_options', condition: 'tmp.field_id == perm.field_id && tmp.value == perm.value'}

    mega_classes << {id: 18, tmp_class: MegaBar::TmpPage, perm_class: MegaBar::Page, unique: [:path], resolver: 'fix_pages', condition: 'tmp.path == perm.path'}
    mega_classes << {id: 20, tmp_class: MegaBar::TmpLayout, perm_class: MegaBar::Layout, unique: [:page_id, :name], resolver: 'fix_layouts', condition: 'tmp.page_id == perm.page_id && tmp.name == perm.name'}
    mega_classes << {id: 21, tmp_class: MegaBar::TmpBlock, perm_class: MegaBar::Block, unique: [:layout_id, :name], resolver: 'fix_blocks', condition: 'tmp.layout_id == perm.layout_id && tmp.name == perm.name'}
    mega_classes << {id: 3, tmp_class: MegaBar::TmpModelDisplay, perm_class: MegaBar::ModelDisplay, unique: [:block_id, :action], resolver: 'fix_model_displays', condition: 'tmp.block_id == perm.block_id && tmp.action == perm.action'}
    mega_classes << {id: 4, tmp_class: MegaBar::TmpFieldDisplay, perm_class: MegaBar::FieldDisplay, unique: [:model_display_id, :field_id, :format], resolver: 'fix_field_displays', condition: 'tmp.model_display_id == perm.model_display_id && tmp.field_id == perm.field_id && tmp.format == perm.format'}

    mega_classes << {id: 6, tmp_class: MegaBar::TmpTextbox, perm_class: MegaBar::Textbox, unique: [:field_display_id], resolver: 'fix_display_class', condition: 'tmp.field_display_id == perm.field_display_id'}
    mega_classes << {id: 7, tmp_class: MegaBar::TmpTextread, perm_class: MegaBar::Textread, unique: [:field_display_id], resolver: 'fix_display_class', condition: 'tmp.field_display_id == perm.field_display_id'}
    mega_classes << {id: 14, tmp_class: MegaBar::TmpSelect, perm_class: MegaBar::Select, unique: [:field_display_id], resolver: 'fix_display_class', condition: 'tmp.field_display_id == perm.field_display_id'}

    mega_classes << {id: 15, tmp_class: MegaBar::TmpModelDisplayFormat, perm_class: MegaBar::ModelDisplayFormat, unique: [:name], resolver: 'fix_model_display_format', condition: 'tmp.name == perm.name'}

    return mega_classes
  end


  task :dump_seeds => :environment do
    mega_bar_model_ids = [1,2,3,4,6,7,14,15,17,18,20,21]
    mega_bar_classes = MegaBar::Model.where(id: mega_bar_model_ids).pluck(:classname)
    mega_bar_fields =  MegaBar::Field.where(model_id: mega_bar_model_ids).pluck(:id)
    SeedDump.dump(MegaBar::Model.where(id: mega_bar_model_ids), file: 'db/mega_bar.seeds.rb', exclude: [])
    SeedDump.dump(MegaBar::Field.where(model_id: mega_bar_model_ids), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    SeedDump.dump(MegaBar::Option.where(field_id: mega_bar_fields), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    SeedDump.dump(MegaBar::ModelDisplayFormat, file: 'db/mega_bar.seeds.rb', exclude: [], append: true)

    mega_bar_page_ids = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]
    # mega_bar_pages = MegaBar::Page.where(id: mega_bar_page_ids).pluck(:id, :path)
    mega_bar_layout_ids = MegaBar::Layout.where(page_id: mega_bar_page_ids).pluck(:id)
    mega_bar_block_ids = MegaBar::Block.where(layout_id: mega_bar_layout_ids).pluck(:id)
    mega_bar_model_display_ids = MegaBar::ModelDisplay.where(block_id: mega_bar_block_ids).pluck(:id)
    mega_bar_field_display_ids =  MegaBar::FieldDisplay.where(model_display_id: mega_bar_model_display_ids).pluck(:id)
    SeedDump.dump(MegaBar::Page.where(id: mega_bar_page_ids), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    SeedDump.dump(MegaBar::Layout.where(id: mega_bar_layout_ids), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    SeedDump.dump(MegaBar::Block.where(id: mega_bar_block_ids), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    SeedDump.dump(MegaBar::ModelDisplay.where(id: mega_bar_model_display_ids), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    SeedDump.dump(MegaBar::FieldDisplay.where(id: mega_bar_field_display_ids), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    SeedDump.dump(MegaBar::Select.where(field_display_id: mega_bar_field_display_ids), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    SeedDump.dump(MegaBar::Textbox.where(field_display_id: mega_bar_field_display_ids), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    SeedDump.dump(MegaBar::Textread.where(field_display_id: mega_bar_field_display_ids), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)


    File.open(Rails.root.join('db', 'mega_bar.seeds.rb'), "r+") do |file|
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
      {id: 8, classname: "Select", schema: "odfdfd", tablename: "selects", name: "Select Menus", default_sort_field: "id", created_at: "2014-05-12 23:02:23", updated_at: "2014-05-23 16:31:23"}
    ])
  end

  task :truncate_all_test_data => :environment do
    get_mega_classes.each do |mc|
      puts "delete from #{mc[:perm_class].table_name}"
      ActiveRecord::Base.connection.execute("delete from #{mc[:perm_class].table_name}")
      ActiveRecord::Base.connection.execute("DELETE FROM SQLITE_SEQUENCE WHERE name='#{mc[:perm_class].table_name}'")
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

end
