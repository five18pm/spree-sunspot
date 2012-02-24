require 'spree/core/search/base'
require 'spree/sunspot/filter/filter'

module Spree::Sunspot
  class Search < Spree::Core::Search::Base
    def query
      @filter_query
    end

    def retrieve_products(*args)
      base_scope = get_base_scope
      if args
        args.each do |additional_scope|
          base_scope = base_scope.send(additional_scope.to_sym)
        end
      end
      @products_scope = @product_group.apply_on(base_scope)
      curr_page = manage_pagination && keywords ? 1 : page

      @products = @products_scope.includes([:images, :master]).page(curr_page).per(per_page)
    end

    def similar_products(product, *field_names)
      products_search = Sunspot.more_like_this(product) do
        fields *field_names
        boost_by_relevance true
        paginate :per_page => total_similar_products * 4, :page => 1
      end

      # get active, in-stock products only.
      base_scope = get_common_base_scope
      hits = []
      if products_search.total > 0
        hits = products_search.hits.collect{|hit| hit.primary_key.to_i}
        base_scope = base_scope.where ["#{Spree::Product.table_name}.id in (?)", hits]
      else
        base_scope = base_scope.where ["#{Spree::Product.table_name}.id = -1"]
      end
      products_scope = @product_group.apply_on(base_scope)
      products_results = products_scope.includes([:images, :master]).page(1)

      # return top N most-relevant products (i.e. in the same order returned by more_like_this)
      @similar_products = products_results.sort_by{ |p| hits.find_index(p.id) }.shift(total_similar_products)
    end

    protected
    def get_base_scope
      base_scope = get_common_base_scope
      base_scope = base_scope.in_taxon(taxon) unless taxon.blank?
      base_scope = get_products_conditions_for(base_scope, keywords) unless filters.empty?

      base_scope = base_scope.ascend_by_master_price
      base_scope
    end

    def get_products_conditions_for(base_scope, query)
      @search = Sunspot.new_search(Spree::Product) do |q|
        q.keywords(query) unless query.blank?
        # There is no option to say don't paginate.
        q.paginate(:page => 1, :per_page => 1000000)
      end

      @filter_query = Spree::Sunspot::Filter::Query.new(@properties[:filters])
      @search = @filter_query.build_search(@search)
      @search.execute
      if @search.total > 0
        hits = @search.hits.collect{|hit| hit.primary_key.to_i}
        base_scope = base_scope.where ["#{Spree::Product.table_name}.id in (?)", hits]
      else
        base_scope = base_scope.where ["#{Spree::Product.table_name}.id = -1"]
      end
      base_scope
    end

    def prepare(params)
      super
      @properties[:filters] = params[:s] || params['s'] || []
      @properties[:total_similar_products] = params[:total_similar_products].to_i > 0 ? params[:total_similar_products].to_i : Spree::Config[:total_similar_products]
    end

    private
    def get_common_base_scope
      base_scope = @cached_product_group ? @cached_product_group.products.active : Spree::Product.active
      base_scope = base_scope.on_hand unless Spree::Config[:show_zero_stock_products]
      base_scope = base_scope.group_by_products_id if @product_group.product_scopes.size > 1
      base_scope
    end

  end
end
