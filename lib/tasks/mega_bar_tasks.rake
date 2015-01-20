# desc "Explaining what the task does"
# task :mega_bar do
#   # Task goes here
# end

namespace :mega_bar do
  desc 'engine_init' # just for testing
  task engine_init: :environment do
    # TODO see if it already was run.
    line = 'Rails.application.routes.draw do'
    text = File.read('config/routes.rb')
    new_contents = text.gsub( /(#{Regexp.escape(line)})/mi, "#{line}\n\n  ##### MEGABAR BEGIN #####\n  mount MegaBar::Engine, at: '/mega-bar'\n  ##### MEGABAR END #####\n")
    File.open('config/routes.rb', "w") {|file| file.puts new_contents }
    puts "mounted the engine in the routes file."
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
  task :data_load, [:file]  => :environment do |t, args|   
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
    puts "Loading Data..."
    MegaBar::Field.skip_callback("create",:after,:make_field_displays)
    MegaBar::Field.skip_callback("create",:after,:make_migration)
    MegaBar::Model.skip_callback("create",:after,:make_all_files)
    MegaBar::Model.skip_callback("create",:after,:make_model_displays)
      
    mega_classes = get_mega_classes
    all_conflicts = [] 
    # display_classes = [[MegaBar::TmpTextbox, MegaBar::Textbox, 'TextBox'],[MegaBar::TmpTextread, MegaBar::Textread, 'TextRead']] 
    mega_ids = []

    mega_classes.each do |mc|
      mc[:tmp_class].delete_all # delete everything that is in the tmp_tables
      mega_ids << mc[:id]
    end
    file = args[:file] || "../../db/mega_bar.seeds.rb"
    require_relative file
    
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
    mega_classes.each do |mc|
      mc[:tmp_class].all.each do |tmp|
        perm = mc[:perm_class].find_or_initialize_by(id: tmp.id) 
        tmp.attributes.each do |attr| 
          perm[attr[0].to_sym] = attr[1] unless attr[0] == 'id' 
        end
        perm.save # written 141231
      end
    end
    # end of main function for loading data
    # important sub functions are below
    puts "Loaded Data"
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

  def fix_model_displays(c) 
    new_obj = make_new_perm(c)
  end
  def fix_records_format(c)
    new_obj = make_new_perm(c)
    MegaBar::TmpFieldDisplay.where(format: c[:tmp].format).update(format: new_obj.id)

  end
  def fix_fields(c)
    new_obj = make_new_perm(c)
    MegaBar::TmpFieldDisplay.where(field_id: c[:tmp].id).update_all(field_id: new_obj.id)
  end

  def fix_field_displays(c) 
    new_obj = make_new_perm(c)
    MegaBar::TmpTextbox.where(field_display_id: c[:tmp].id).each do |tb|
      tb.update(field_display_id: new_obj.id)
    end
  end


  def update_tmp_fields(new_obj, c)
    MegaBar::TmpField.where(model_id: c[:tmp].id).each { |f| f.update(model_id: new_obj.id) }   
  end

  def fix_display_class(c) 
    new_obj = make_new_perm(c)
  end



  def fix_model(c)
    new_obj = make_new_perm(c)
    puts 'Incoming model ' + c[:tmp].id + ' with class ' + c[:tmp].classname + ' had to be issued a new id ' + new_obj.id + '.  Make sure the associated class files point to the right thing. '
     ##### MODEL DISPLAY. Update any related model_displays with the new model_id.
    MegaBar::TmpModelDisplay.where(model_id: c[:tmp].id).update_all(model_id: new_obj.id)
    ##### FIELDS
    update_tmp_fields(new_obj, c)
  end



  def get_mega_classes
    mega_classes = []
    mega_classes << {id: 1, tmp_class: MegaBar::TmpModel, perm_class: MegaBar::Model, unique: [:classname], resolver: 'fix_model', condition: 'tmp.classname == perm.classname'}
    mega_classes << {id: 2, tmp_class: MegaBar::TmpField, perm_class: MegaBar::Field, unique: [:model_id, :field], resolver: 'fix_fields', condition: 'tmp.model_id == perm.model_id && tmp.field == perm.field'}
    mega_classes << {id: 3, tmp_class: MegaBar::TmpModelDisplay, perm_class: MegaBar::ModelDisplay, unique: [:model_id, :action], resolver: 'fix_model_displays', condition: 'tmp.model_id == perm.model_id && tmp.action == perm.action'}
    mega_classes << {id: 4, tmp_class: MegaBar::TmpFieldDisplay, perm_class: MegaBar::FieldDisplay, unique: [:field_id, :action], resolver: 'fix_field_displays', condition: 'tmp.field_id == perm.field_id && tmp.action == perm.action'} 
    mega_classes << {id: 5, tmp_class: MegaBar::TmpRecordsFormat, perm_class: MegaBar::RecordsFormat, unique: [:name], resolver: 'fix_records_format', condition: 'tmp.name == perm.name'}
    mega_classes << {id: 6, tmp_class: MegaBar::TmpTextbox, perm_class: MegaBar::Textbox, unique: [:field_display_id], resolver: 'fix_display_class', condition: 'tmp.field_display_id == perm.field_display_id'}
    mega_classes << {id: 7, tmp_class: MegaBar::TmpTextread, perm_class: MegaBar::Textread, unique: [:field_display_id], resolver: 'fix_display_class', condition: 'tmp.field_display_id == perm.field_display_id'} 
    return mega_classes
  end




  def associated_from_models(tmp, model_ids) 
    field_class = tmp ? MegaBar::TmpField : MegaBar::Field
    field_display_class = tmp ? MegaBar::TmpFieldDisplay : MegaBar::FieldDisplay
    fields =  field_class.where(model_id: model_ids).pluck(:id)
    field_disp =  field_display_class.where(field_id: fields).pluck(:id)
    return {fields: fields, field_displays: field_disp}
    #model_disp = MegaBar::
  end


  def keep_going
     #deprecated
    binding.pry
    mega_bar_model_ids = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]


    mega_bar_fields =  MegaBar::Field.where(model_id: mega_ids).pluck(:id)
    mega_bar_field_disp =  MegaBar::FieldDisplay.where(field_id: mega_bar_fields).pluck(:id)
    mega_bar_classes = MegaBar::Model.where(id: mega_ids).pluck(:classname)
  
    MegaBar::Model.where(id: mega_ids).delete_all
    MegaBar::Field.where(id: mega_bar_fields).delete_all
    MegaBar::ModelDisplay.where(model_id: mega_ids).delete_all
    MegaBar::FieldDisplay.where(field_id: mega_bar_fields).delete_all
    MegaBar::Textbox.where(field_display_id: mega_bar_field_disp).delete_all
    MegaBar::Textread.where(field_display_id: mega_bar_field_disp).delete_all
    MegaBar::RecordsFormat.delete_all
 
     
    # MegaBar::Select.where(attributedisplayid: mega_bar_field_disp).delete_all
    # MegaBar::Textarea.where(attibutedisplayid: mega_bar_field_disp).delete_all
    
    # run the load: 
    puts "Loaded Data"
  end

  task :dump_seeds => :environment do
    mega_bar_model_ids = [1,2,3,4,5,6,7,8,9,10,11,12,13]
    mega_bar_classes = MegaBar::Model.where(id: mega_bar_model_ids).pluck(:classname)
    mega_bar_fields =  MegaBar::Field.where(model_id: mega_bar_model_ids).pluck(:id)
    mega_bar_field_disp =  MegaBar::FieldDisplay.where(field_id: mega_bar_fields).pluck(:id)
    SeedDump.dump(MegaBar::Model.where(id: mega_bar_model_ids), file: 'db/mega_bar.seeds.rb', exclude: [])
    SeedDump.dump(MegaBar::ModelDisplay.where(model_id: mega_bar_model_ids), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    SeedDump.dump(MegaBar::Field.where(model_id: mega_bar_model_ids), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    SeedDump.dump(MegaBar::FieldDisplay.where(field_id: mega_bar_fields), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    SeedDump.dump(MegaBar::RecordsFormat, file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    # SeedDump.dump(MegaBar::Select.where(field_display_id: mega_bar_field_disp), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    SeedDump.dump(MegaBar::Textbox.where(field_display_id: mega_bar_field_disp), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
    SeedDump.dump(MegaBar::Textread.where(field_display_id: mega_bar_field_disp), file: 'db/mega_bar.seeds.rb', exclude: [], append: true)
   
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
    binding.pry
    MegaBar::Model.new  ([
      {id: 1, classname: "Model", schema: "sqlite", tablename: "models", name: "Model", default_sort_field: "id", created_at: "2014-05-05 17:27:28", updated_at: "2014-12-26 00:58:09"},
      {id: 2, classname: "Attribute", schema: "sqlite", tablename: "fields", name: "Fields", default_sort_field: "id", created_at: "2014-05-05 17:28:21", updated_at: "2014-05-21 22:21:20"},
      {id: 3, classname: "ModelDisplay", schema: "sqlite", tablename: "model_displays", name: "Model Displayyyyy", default_sort_field: "model_id", created_at: "2014-05-05 18:12:24", updated_at: "2014-05-21 18:35:52"},
      {id: 4, classname: "AttributeDisplay", schema: "sqlite", tablename: "field_displays", name: "Field Displays", default_sort_field: "id", created_at: "2014-05-05 19:20:12", updated_at: "2014-05-21 22:33:58"},
      {id: 5, classname: "RecordsFormat", schema: "sqlite", tablename: "recordsformats", name: "Records Format", default_sort_field: "name", created_at: "2014-05-05 19:34:38", updated_at: "2014-12-24 07:19:00"},
      {id: 6, classname: "Textbox", schema: "another", tablename: "textboxes", name: "Text Boxes", default_sort_field: "id", created_at: "2014-05-12 17:43:13", updated_at: "2014-05-21 21:51:02"},
      {id: 7, classname: "Textread", schema: "oyyyy", tablename: "textreads", name: "Text Display", default_sort_field: "id", created_at: "2014-05-12 22:59:05", updated_at: "2014-05-23 16:30:59"},
      {id: 8, classname: "Select", schema: "odfdfd", tablename: "selects", name: "Select Menus", default_sort_field: "id", created_at: "2014-05-12 23:02:23", updated_at: "2014-05-23 16:31:23"}
    ])
  end

  task simple_load: :environment do
    # TODO - add prompt to be sure.
    ENV['mega_bar_data_loading'] = 'yes'
    # TODO: figure out how to really disable the before filters.
    model_ids = [1,2,3,4,5,6,7]
    fields =  MegaBar::Field.where(model_id: model_ids).pluck(:id)
    field_disp =  MegaBar::FieldDisplay.where(field_id: fields).pluck(:id)
    classes = MegaBar::Model.where(id: model_ids).pluck(:classname)
  
    # MegaBar::Model.where(id: model_ids).delete_all
    # MegaBar::Field.where(id: fields).delete_all
    # MegaBar::ModelDisplay.where(model_id: model_ids).delete_all
    # MegaBar::FieldDisplay.where(field_id: fields).delete_all
    # MegaBar::Textbox.where(field_display_id: field_disp).delete_all
    # MegaBar::Textread.where(field_display_id: field_disp).delete_all
    # MegaBar::RecordsFormat.delete_all

    MegaBar::Model.delete_all
    MegaBar::Field.delete_all
    MegaBar::ModelDisplay.delete_all
    MegaBar::FieldDisplay.delete_all
    MegaBar::Textbox.delete_all
    MegaBar::Textread.delete_all
    MegaBar::RecordsFormat.delete_all
   
    # MegaBar::Select.where(attributedisplayid: mega_bar_field_disp).delete_all
    # MegaBar::Textarea.where(attibutedisplayid: mega_bar_field_disp).delete_all
    
    # run the load: 
    require Rails.root.join('db', 'mega_bar.seeds.rb')
    puts "Loaded Data"

  end

end