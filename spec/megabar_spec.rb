require 'spec_helper'

RSpec.describe MegaBar do
  it "is a module" do
    expect(MegaBar).to be_a(Module)
  end

  it "has a version" do
    expect(MegaBar::VERSION).to be_a(String)
  end

  describe "Engine" do
    it "can be instantiated" do
      expect(MegaBar::Engine).to be_a(Class)
    end

    it "inherits from Rails::Engine" do
      expect(MegaBar::Engine.superclass).to eq(Rails::Engine)
    end
  end

  describe "Models" do
    it "has a Page model" do
      expect(MegaBar::Page).to be_a(Class)
    end

    it "has a Model model" do
      expect(MegaBar::Model).to be_a(Class)
    end

    it "has a Template model" do
      expect(MegaBar::Template).to be_a(Class)
    end
  end

  describe "Controllers" do
    it "has an ApplicationController" do
      expect(MegaBar::ApplicationController).to be_a(Class)
    end

    it "has a PagesController" do
      expect(MegaBar::PagesController).to be_a(Class)
    end

    it "has a ModelsController" do
      expect(MegaBar::ModelsController).to be_a(Class)
    end
  end
end
