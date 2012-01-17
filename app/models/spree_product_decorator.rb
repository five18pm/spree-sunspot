Spree::Product.class_eval do
  def get_option_values(option_name)
    sql = <<-eos
      SELECT DISTINCT ov.id, ov.presentation
      FROM option_values AS ov
      LEFT JOIN option_types AS ot ON (ov.option_type_id = ot.id)
      LEFT JOIN option_values_variants AS ovv ON (ovv.option_value_id = ov.id)
      LEFT JOIN variants AS v ON (ovv.variant_id = v.id)
      LEFT JOIN products AS p ON (v.product_id = p.id)
      WHERE (ot.name = '#{option_name}' AND p.id = #{self.id});
    eos
    OptionValue.find_by_sql(sql).map(&:presentation)
  end
end

unless Spree::Sunspot::Setup.configuration.nil?
  Spree::Product.class_eval &Spree::Sunspot::Setup.configuration
end

