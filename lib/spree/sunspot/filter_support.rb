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
            include Spree::Sunspot::FilterSupport::Helpers
            helper_method :render_filter
          EOV
        end
      end

      module InstanceMethods
        def filter
          if params[:id]
            taxon = Spree::Taxon.find_by_linkname(params[:id])
            if taxon
              params.merge!(:taxon => taxon)
            end
          end
          if params[:s].empty?
            redirect_to params[:source_url]
            return
          end
          @searcher = Spree::Config.searcher_class.new(params)
          @products = @searcher.retrieve_products
          respond_with(@products)
        end

        def filter_url_options
          object = instance_variable_get('@'+controller_name.singularize)
          if object
            case controller_name
            when "products"
              hash_for_product_path(object)
            when "taxons"
              hash_for_taxon_short_path(object)
            end
          else
            {}
          end
        end
      end

      module Helpers
        def render_filter
          filter_params = Spree::Sunspot::Setup.filters.filters
          render :partial => 'spree/shared/filter', :locals => { :filter_params => filter_params }
        end
      end
    end
  end
end
