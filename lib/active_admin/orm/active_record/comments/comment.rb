module ActiveAdmin
  class Comment < ActiveRecord::Base

    self.table_name = "#{table_name_prefix}active_admin_comments#{table_name_suffix}"

    belongs_to :resource, polymorphic: true
    belongs_to :author,   polymorphic: true

    validates_presence_of :body, :namespace, :resource

    before_create :set_resource_type

    # @return [String] The name of the record to use for the polymorphic relationship
    def self.resource_type(resource)
      ResourceController::Decorators.undecorate(resource).class.base_class.name.to_s
    end

    def self.build_name_path(name)
      names = Array(name).map { |n| n == true || n == false || n.nil? ? n : n.to_sym }
      default_namespace = ActiveAdmin.application.default_namespace
      [:root, false, nil].include?(default_namespace) || [:root, default_namespace].include?(names.first) ? names : [default_namespace] + names
    end

    def self.find_for_resource_in_namespace(resource, name)
      where(
        resource_type: resource_type(resource),
        resource_id:   resource,
        namespace:     name.to_s
      ).order(ActiveAdmin.application.namespaces[build_name_path(name)].comments_order)
    end

    def set_resource_type
      self.resource_type = self.class.resource_type(resource)
    end

  end
end
