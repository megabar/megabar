require 'spec_helper'

describe EntriesController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
     # expect(post: '/entries').to route_to('entries#create')
     assert_generates '/mega_bar/models', {controller: 'mega_bar/models', action: 'index'}
    end
  end
end
