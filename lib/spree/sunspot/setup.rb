module Spree
  class Sunspot::Setup
    @@filters = nil
    IGNORE_MAX = 1000000000

    @@configuration = nil
    def self.configure(&blk)
      @@configuration = blk
    end
  
    def self.configuration
      @@configuration
    end

    def self.filters(&blk)
      @@filters ||= Spree::Sunspot::Filters.new
      yield @@filters if block_given?
      @@filters
    end
  end
end
