class Spree::Sunspot::Filter::Filter
  attr_accessor :search_param
  attr_accessor :display_name
  attr_accessor :values
  attr_accessor :param_type

  def initialize
    @values = []
  end

  def values(&blk)
    @values = yield if block_given?
    @values
  end

  def display?
    !values.empty?
  end

  def search_param
    @search_param.to_sym
  end

  def finalize!
    raise ArgumentError.new("search_param is nil") if search_param.nil?
    raise ArgumentError.new("display_name is nil") if display_name.nil?
    @param_type ||= values[0].class unless values.empty?
  end
end

class Spree::Sunspot::Filter::Query
  attr_accessor :params

  def initialize(query)
    unless query.nil?
      qparams = query.split('&')
      @params = qparams.map do |qp|
        display_name, values = qp.split('=')
        source = Spree::Sunspot::Setup.filters.filter_for(display_name)
        new Param(source, values) unless values.nil?
      end
    end
  end

  def build_search(search)
    @params.each{|p| p.build_search_query(search) }
    search
  end

  def build_url
    @params.collect{|p| p.to_param}.join('&')
  end
end

class Spree::Sunspot::Filter::Param
  attr_accessor :source
  attr_accessor :conditions

  def initialize(source, pcondition)
    @source = source

    pconditions = pcondition.split('|')
    this = self
    @conditions = pconditions.map{|p| new Condition(this, p)}
  end

  def build_search_query(search)
    search.build do |query|
      if @conditions.size > 0
        query.any_of do |query|
          @conditions.each do |condition|
            condition.build_query(query)
          end
        end
      else
        conditions[0].build_query(query)
      end
    end
    search
  end

  def to_param
    value = @conditions.collect{|condition| condition.to_param}.join('|')
    "#{display_name}=value"
  end

  def method_missing(method, *args)
    if source.respond_to?(method)
      source.send(method, args)
    else
      super
    end
  end
end

class Spree::Sunspot::Filter::Condition
  attr_accessor :value
  attr_accessor :condition_type
  attr_accessor :source

  GREATER_THAN = 1
  BETWEEN = 2
  EQUAL = 3

  def multiple?
    value.kindof?(Array)
  end

  def initialize(source, pcondition)
    @source = source
    range = pcondition.split(',')
    if range.size > 1
      if range[1] == '*'
        @value = range[0].to_f
        @condition_type = GREATER_THAN
      else
        @value = Range.new(range[0].to_f, range[1].to_f)
        @condition_type = BETWEEN
      end
    else
      @value = pcondition
      @condition_type = EQUAL
    end
  end

  def to_param
    case condition_type
    when GREATER_THAN
      "#{value.to_s},*"
    when BETWEEN
      "#{value.min.to_s},#{value.max.to_s}"
    when EQUAL
      value.to_s
    end
  end

  def build_search_query(query)
    case condition_type
    when GREATER_THAN
      query.with(source.search_param).greater_than(value)
    when BETWEEN
      query.with(source.search_param).between(value)
    when EQUAL
      query.with(source.search_param, value)
    end
    query
  end
end
