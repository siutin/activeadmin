require 'spec_helper'

RSpec.describe "jruby bug", type: :request do

  # Creates a ruby module to namespace all the classes in if required
  def register_module(module_name)
    # dynamically create nested modules
    module_names = module_name.split("::").inject([]) { |n, c| n << (n.empty? ? [c] : [n.last] + [c]).flatten }
    module_names.each do |module_name_array|
      *prefix, parent, child = module_name_array
      if child
        full_path_child_module_name = module_name_array.join("::")
        if Object.const_defined?(full_path_child_module_name)
          puts "full_path_child_module_name: #{full_path_child_module_name} -> is defined"
        else
          puts "full_path_child_module_name: #{full_path_child_module_name} -> not defined yet"
          parent_module = find_or_register_module(parent, prefix)
          parent_module.const_set child, Module.new
        end
      else
        find_or_register_module(parent, prefix) # register parent_module
      end
    end
  end

  def find_or_register_module(name, prefix)
    full_path_module_name = (prefix + [name]).join("::")
    if Object.const_defined? full_path_module_name
      Object.const_get full_path_module_name
    else
      if prefix.empty?
        Object.const_set name, Module.new
      else
        full_path_prefix = prefix.join("::")
        prefix_module = Object.const_get(full_path_prefix)
        prefix_module.const_set name, Module.new
      end
    end
  end

  context '1' do
    let(:module_name) { "Abc123::Foo::Bar" }
    before do
      register_module("Bar")
      register_module(module_name)
    end
    it { expect(Object.const_get(module_name)&.to_s).to match(module_name) }
  end
end