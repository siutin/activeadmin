module ActiveAdmin
  class Comment < ActiveRecord::Base

    self.table_name = 'active_admin_comments'

    belongs_to :resource, polymorphic: true
    belongs_to :author,   polymorphic: true

    if defined? ProtectedAttributes
      attr_accessible :resource, :resource_id, :resource_type, :body, :namespace
    end

    validates_presence_of :body, :namespace, :resource

    before_create :set_resource_type

    # @return [String] The name of the record to use for the polymorphic relationship
    def self.resource_type(resource)
      ResourceController::Decorators.undecorate(resource).class.base_class.name.to_s
    end

    def self.find_for_resource_in_namespace(resource, namespace)
      _namespace =
          (namespace && namespace.is_a?(Array) && ActiveAdmin.application.default_namespace != :root) ?
              namespace.drop(1) :
              namespace.to_sym
      where(
          resource_type: resource_type(resource),
          resource_id: resource,
          namespace: _namespace.to_s
      ).order(ActiveAdmin.application.namespaces[_namespace].comments_order)
    end

    def set_resource_type
      self.resource_type = self.class.resource_type(resource)
    end

  end
end
