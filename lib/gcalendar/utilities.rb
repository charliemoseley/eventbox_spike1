module GCalendar
  module Utilities
    def camelize_keys(value)
      case value
        when Array
          value.map { |v| camelize_keys(v) }
        when Hash
          Hash[value.map { |k, v| [camelize_key(k), camelize_keys(v)] }]
        else
          value
      end
    end

    def camelize_key(sym)
      sym.to_s.camelize(:lower).to_sym
    end
  end
end