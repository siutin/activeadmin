require 'spec_helper'
require './lib/my_module'
RSpec.describe do
  context do
    let(:module_name) { "Abc123::Foo::Bar" }
    before do
      register_module("Bar")
      register_module(module_name)
    end
    it { expect(Object.const_get(module_name)&.to_s).to match(module_name) }
  end
end