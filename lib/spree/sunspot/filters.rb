module Spree
  class Sunspot::Filters
    attr_accessor :filters

    def initialize
      @filters = []
    end

    def add(&blk)
      filter = Spree::Sunspot::Filter::Filter.new
      yield filter
      filter.finalize!
      filters << filter
    end

    def filter_for(display_name)
      @filters.select{|f| f.display_name == display_name }.first
    end
  end
end
