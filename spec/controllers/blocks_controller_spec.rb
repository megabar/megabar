
module MegaBar 

  puts "Did you remember to copy the migration over to the megabar db/migrate directory?"
  require 'spec_helper'
 
  RSpec.describe MegaBar::BlocksController, :type => :controller do

    let(:valid_attributes) {
      v = build(:block)
      { id: v[:id] } # add other fields
    }

    let(:invalid_attributes) {
      # all tests using invalid_attributes marked as pending until you define this.
      i = build(:block)
      { id: i[:id] } #add other required fields as nil
    }

    let(:valid_session) { {} }


    context 'with callbacks disabled' do 
      before(:each) do
        MegaBar::Field.skip_callback("save",:after,:make_field_displays) 
        MegaBar::Field.skip_callback("create",:after,:make_field_displays)
        MegaBar::Field.skip_callback("create",:after,:make_migration)
        MegaBar::Model.skip_callback("create",:after,:make_all_files)
        MegaBar::Model.skip_callback("create",:after,:make_model_displays)
      end
      after(:each) do
        MegaBar::Field.set_callback("save",:after,:make_field_displays) 
        MegaBar::Field.set_callback("create",:after,:make_field_displays)
        MegaBar::Field.set_callback("create",:after,:make_migration)
        MegaBar::Model.set_callback("create",:after,:make_all_files)
        MegaBar::Model.set_callback("create",:after,:make_model_displays)
      end
      context "with a model " do
        before(:each) do
          create(:model)
        end
        after(:each) do
          MegaBar::Model.find(1).destroy
        end
        describe "GET index" do
          it "assigns all mega_bar_blocks as @mega_instance" do
            block = Block.create! valid_attributes
            get :index, {use_route: MegaBar,  model_id: 1}, valid_session
            expect(assigns(:mega_instance)).to eq([block])
          end
        end

        describe "GET show" do
          it "assigns the requested block as @mega_instance" do
            block = Block.create! valid_attributes
            get :show, {use_route: MegaBar,  model_id: 1, :id => block.to_param}, valid_session
            expect(assigns(:mega_instance)).to eq([block])
          end
        end
        describe "GET new" do
          it "assigns a new block as @mega_instance" do
            get :new, {use_route: MegaBar,  model_id: 1}, valid_session
            expect(assigns(:mega_instance)).to be_a_new(Block)
          end
        end

        describe "GET edit" do
          it "assigns the requested block as @mega_instance" do
            block = Block.create! valid_attributes
            get :edit, {use_route: MegaBar,  model_id: 1, :id => block.to_param}, valid_session
            expect(assigns(:mega_instance)).to eq(block)
          end
        end
      end
      context 'with a model  and fields for block' do
        before(:each) do
          create(:model, classname: 'Block', name: 'Block', tablename: 'mega_bar_blocks')
          create(:field, tablename: 'mega_bar_blocks', field: 'id')
          # add additional (required) fields
        end
        after(:each) do
          MegaBar::Model.find(1).destroy
          MegaBar::Field.destroy_all
        end
        describe "POST create" do
          describe "with valid params" do
            it "creates a new block" do
              expect {
                post :create, {use_route: MegaBar,  model_id: 1, :block=> valid_attributes}, valid_session
              }.to change(Block, :count).by(1)
            end

            it "assigns a newly created block as @mega_instance" do
              post :create, {use_route: MegaBar,  model_id: 1, :block => valid_attributes}, valid_session
              expect(assigns(:mega_instance)).to be_a(Block)
              expect(assigns(:mega_instance)).to be_persisted
            end

            it "redirects to the created block"  do
              post :create, {use_route: MegaBar,  model_id: 1, :block => valid_attributes}, valid_session
              expect(response).to redirect_to(Block.last)
            end
          end

          describe "with invalid params" do
            it "assigns a newly created but unsaved block as @mega_instance" do
              skip('define invalid_attributes above')
              post :create, {use_route: MegaBar,  model_id: 1, :block => invalid_attributes}, valid_session
              expect(assigns(:mega_instance)).to be_a_new(Block)
            end

            it "re-renders the 'new' template"  do
              skip('define invalid_attributes above')
              post :create, {use_route: MegaBar,  model_id: 1, :block => invalid_attributes}, valid_session
              expect(response).to render_template('mega_bar.html.erb')
            end
          end
        end

        describe "PUT update" do
          describe "with valid params" do
            let(:new_attributes) { # marked as pending until params added here.
              md = build(:block)
              { }
            }

            it "updates the requested block" do
              skip('define new_attributes')
              block = Block.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => block.to_param, :block => new_attributes}, valid_session
              block.reload
              expect(block.attributes).to include( { 'id' => "5" } )
            end

            it "assigns the requested block as @mega_instance" do
              block = Block.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => block.to_param, :block => valid_attributes}, valid_session
              expect(assigns(:mega_instance)).to eq(block)
            end

            it "redirects to the block" do
              block = Block.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => block.to_param, :block => valid_attributes}, valid_session
              expect(response).to redirect_to(block)
            end
          end

          describe "with invalid params" do
            it "assigns the block as @mega_instance" do
              skip('define invalid_attributes above')
              block = Block.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => block.to_param, :block => invalid_attributes}, valid_session
              expect(assigns(:mega_instance)).to eq(block)
            end

            it "re-renders the 'edit' template" do
              skip('define invalid_attributes above')
              block = Block.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => block.to_param, :block => invalid_attributes}, valid_session
              expect(response).to render_template("mega_bar.html.erb")
            end
          end
        end
      end

      describe "DELETE destroy" do
        it "destroys the requested block" do
          block = Block.create! valid_attributes
          expect {
            delete :destroy, {use_route: MegaBar,  :id => block.to_param}, valid_session
          }.to change(Block, :count).by(-1)
        end

        it "redirects to the block list" do
          block = Block.create! valid_attributes
          delete :destroy, {use_route: MegaBar,  :id => block.to_param}, valid_session
          expect(response).to redirect_to("/mega-bar/blocks")
        end
      end
    end
  end  

end 
