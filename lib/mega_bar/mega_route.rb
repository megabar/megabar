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
    puts 'context: ' + context.inspect
    routes = []
    MegaBar::Page.all.each do |pg|
      # puts 'new page '
      MegaBar::Layout.by_page(pg.id).each do |llayout| 
        # puts 'new layout'
        MegaBar::Block.by_layout(llayout.id).each do | block |
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
          # puts "new block: " + block.id.to_s
          # puts "p2: " + p
          if block.html?
            # p = block.path_base? ? block.path_base : pg.path
            # routes << {path: p, method: 'get', controller: 'flats', action: 'index'}
          else 
            if MegaBar::ModelDisplay.by_block(block.id).size > 0
              # byebug if MegaBar::ModelDisplay.by_block(block.id).first.model_id == 3
              controller = MegaRoute.controller_from_block(context, block)
              # puts "controller ---- " + controller + ", path: " + p
              routes << {path: p + '/:id', method: 'patch', action: 'update', controller: controller} 
              routes << {path: p, method: 'post', action: 'create', controller: controller}
              routes << {path: p.singularize, method: 'delete', action: 'destroy', controller: controller} 
              MegaBar::ModelDisplay.by_block(block.id).each do | md | 
                # puts "mid" + md.model_id.to_s
                pf = ''
                # byebug if md.model_id == 3
                case md.action
                when 'show' 
                  pf = p + '/:id'
                  x = 'member'
                when 'index'
                  x = 'collection'
                  pf = p
                when 'new'
                  pf = p + '/new'
                when 'edit'
                  pf = p + '/:id/edit'
                  x = 'member'
                end
                # byebug if md.model_id == 3
                routes << {path: pf, method: 'get', action: md.action, controller: controller}
                # get "#{p}"
                # puts pf + ": " + controller + " -- " + md.action
              end
            end
          end
        end
      end
    end #pages each
    routes.uniq
  end

  def self.reload
    ComingSoon::Application.routes_reloader.reload!
  end
  def self.boop
    abort('booop')
  end
end
