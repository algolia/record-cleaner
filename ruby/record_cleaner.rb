class RecordCleaner
  def self.ignore_value(val, options)
    return false if val.is_a?(Numeric) || val.is_a?(TrueClass) || val.is_a?(FalseClass)
    val.nil? || val.empty? || (val.is_a?(Array) && val.all?{ |v| v.nil? || v.empty? }) ||
        (val.is_a?(Hash) && clean(val, options).empty?)
  end

  DEFAULT_OPTIONS = {
      float_decimals: 3
  }

  def self.clean(record, options = {})
    options = DEFAULT_OPTIONS.merge(options)

    record.delete_if { |_, val| ignore_value(val, options) }
    record.keys.each do |attr|
      case record[attr]
        when Array
          record[attr] = record[attr].compact.uniq.delete_if { |val| ignore_value(val, options)}
        when Hash
          record[attr] = clean(record[attr], options)
        when Float
          record[attr] = record[attr].round(options[:float_decimals])
        else
          # ignore
      end
    end

    record
  end
end
