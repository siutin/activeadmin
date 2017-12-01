def register_module(module_name)
  module_names = module_name.split("::").inject([]) { |n, c| n << (n.empty? ? [c] : [n.last] + [c]).flatten }
  module_names.each do |module_name_array|
    eval "module ::#{module_name_array.join("::")}; end"
  end
end
