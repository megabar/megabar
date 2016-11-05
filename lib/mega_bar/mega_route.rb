class MegaRoute
  def self.controller_from_block(context, block)
    md = MegaBar::ModelDisplay.by_block(block.id).first
    m = MegaBar::Model.find(md.model_id)
    modu = m.modyule.empty? ? '' : m.modyule + '::'
    # modu == 'MegaBar::' ?  'mega-bar/' + m.classname.tableize
    # puts md.model_id.to_s + " .... " + m.id.to_s + " = " + m.classname.tableize
    m.classname.tableize
  end

  def self.load(context)
    # puts 'context: ' + context.inspect
    routes = []
    ases = []
    MegaBar::Page.all.each do |pg|
      # puts 'new page '
      MegaBar::Layout.by_page(pg.id).each do |llayout|
        # puts 'new layout'
        llayout.layout_sections.each do | layout_section | 
          MegaBar::Block.by_layout_section(layout_section.id).each do | block |
            # byebug if pg.id  == 18 || pg.id == 33
            p = block.path_base? ? block.path_base : pg.path
            if context.kind_of?(Array)
              exclude = false
              context.each do |c|
                exclude = true if p.starts_with? c
              end
              next if exclude
            else
              if p.starts_with? context
                p = p[context.size..-1]
              else
                next
              end
            end
            path = ''
            p1 = p.split('/')
            p1.each do | seg |
              next if (seg.empty? || seg.starts_with?(':'))
              path += seg.singularize + '_'
            end
            path = path.chomp('_').pluralize
            # puts "new block: " + block.id.to_s
            # byebug if  block.id == 74
            # puts "path: " + path
            # byebug if pg.id > 29 || pg.id == 13 || pg.id == 10
            if block.html?
              p = block.path_base? ? block.path_base : pg.path
              routes << {path: p, method: 'get', controller: 'flats', action: 'index', as: 'flats_' + block.id.to_s}
              # puts 'block html path. ' + p.to_s
            else
              if MegaBar::ModelDisplay.by_block(block.id).size > 0
               # byebug if pg.id ==10
                # byebug if MegaBar::ModelDisplay.by_block(block.id).first.model_id == 3
                controller = MegaRoute.controller_from_block(context, block)
                # puts "controller ---- " + controller + ", path: " + p
                MegaBar::ModelDisplay.by_block(block.id).order(collection_or_member: :asc, action: :asc).each do | md | #order here becomes important todo
                  # puts "mid #{block.name}" + md.action.to_s
                  modle = MegaBar::Model.find(md.model_id)
                  pf = ''
                  as = nil
                  concerns = nil
                  case md.action
                  when 'show'
                    pf = p + '/:id'
                    as = path.singularize
                    meth = 'get'
                  when 'index'
                    pf = p
                    as = path
                    # byebug if as == 'templates'
                    concerns = 'paginatable'
                    meth = [:get]
                  when 'new'
                    pf = p + '/new'
                    as = 'new_' + path
                    meth = 'get'
                  when 'edit'
                    pf = p + '/:id/edit'
                    as = 'edit_' + path
                    meth = 'get'
                  else
                    pf = p.to_s + "/" + md.action.to_s
                    if md.collection_or_member == 'collection'
                      concerns = 'paginatable' 
                      meth =  [:get, :post]
                    end
                    # puts 'custom action: ' + pf
                    # db should track whether custom model_display actions are on member or collection and if they have a special 'as' or anything.
                  end
                  route = {path: pf, method: meth, action: md.action, controller: controller}
                  route = route.merge({as: as}) if as
                  # byebug if as == 'templates'
                  route = route.merge({concerns: concerns}) if concerns
                  # route = route.merge({on: x}) if x
                  routes << route
                  routes << {path: pf + '/filter', method: [:get, :post], action: md.action, controller: controller} if md.collection_or_member == 'collection' 
                  # if md.collection_or_member == 'collection' 
                  #   c_route = route
                  #   c_route[:method] = 'post'
                  #   routes << c_route
                  # end

                end
                routes << {path: p + '/move/:id', method: 'get', action: 'move', controller: controller } 
                routes << {path: p + '/:id', method: 'patch', action: 'update', controller: controller}
                routes << {path: p, method: 'post', action: 'create', controller: controller}
                routes << {path: p + '/:id', method: 'delete', action: 'destroy', controller: controller}
              end
            end
          end  #blocks each
        end ###layout sections each
      end
    end #pages each
    routes.uniq
  rescue ActiveRecord::StatementInvalid # you can also add this
    []
  end

  def self.reload
    ComingSoon::Application.routes_reloader.reload!
  end
  def self.boop
    abort('booop')
  end
end
