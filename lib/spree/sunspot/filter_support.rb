require 'spree/sunspot/search'

module Spree
  module Sunspot
    module FilterSupport
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def filter_support(options = {})
          additional_params = options[:additional_params_method]
          class_eval <<-EOV
            include Spree::Sunspot::FilterSupport::InstanceMethods
            cattr_accessor :additional_filter_params

            @@additional_filter_params = (additional_params.nil? : nil : additional_params)

            helper_method :render_filter
          EOV
        end
      end

      module InstanceMethods
        def render_filter
          filter_params = Spree::Sunspot::Setup.filters.collect{|filter| filter.parse(params)}
          render :partial => 'spree/shared/filter', :locals => { :filters => filter_params }
        end

        def filter
          params.merge(self.send(@@additional_filter_params)) unless @@additional_filter_params.nil?
          @searcher = Spree::Config.searcher_class.new(params)
          @products = @searcher.retrieve_products
          respond_with(@products)
        end
      end
    end
  end
end

ActionController::Base.include(Spree::Sunspot::FilterSupport)
