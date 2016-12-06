module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(filtering_params)
      results = self.where(nil)

      filtering_params.each do |key, value|
        results = results.public_send(key, value) if value.present? and results.respond_to?(key)
      end

      results
    end

    def scope_multiselect attribute, value
      value = value.to_s
      where(attribute.to_sym => value.split(','))
    end
  end
end
