require 'active_support/core_ext/object/with_options'

module HydraAttribute
  class HydraAttribute < ActiveRecord::Base
    self.table_name = 'hydra_attributes'

    attr_accessible :name, :backend_type, :default_value

    with_options presence: true do |klass|
      klass.validates :entity_type,  inclusion: { in: lambda { |attr| [(attr.entity_type.constantize.name rescue nil)] } }
      klass.validates :name,         uniqueness: { scope: :entity_type }
      klass.validates :backend_type, inclusion: SUPPORT_TYPES
    end

    before_destroy :delete_dependent_values
    after_commit   :reload_entity_attributes

    private

    def delete_dependent_values
      value_class = AssociationBuilder.class_name(entity_type.constantize, backend_type).constantize
      value_class.delete_all(hydra_attribute_id: id)
    end

    def reload_entity_attributes
      entity_type.constantize.reset_hydra_attribute_methods
    end
  end
end