module Spree::Sunspot
  class Search < Spree::Core::Search::Base
    protected
    def get_products_conditions_for(base_scope, query)
      @search = Sunspot.new_search(Spree::Product) do |q|
        q.keywords(query) unless query.blank?
        # There is no option to say don't paginate.
        q.paginate(:page => 1, :per_page => 1000000)
      end

      filter_query = Spree::Sunspot::Filter::Query.new(@properties[:filters])
      @search = filter_query.build_search(@search)
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
    end
  end
end