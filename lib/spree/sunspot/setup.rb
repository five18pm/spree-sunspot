require 'sunspot_rails'

module Spree
  class Sunspot::Setup
    IGNORE_MAX = 1000000000
    @@filters = nil

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
