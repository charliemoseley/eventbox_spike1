module GCalendar
  module Validations
    # See what happens if/when i make these private
    # private
    def validate_presence_of(*symbols)
      symbols.each do |sym|
        unless has_key_and_is_not_empty? self, sym
          raise "Missing required parameter: #{sym}"
        end
      end
    end

    def has_key_and_is_not_empty?(hash, key)
      return false if hash[key].nil?
      return false if hash[key].respond_to?(:empty?) && hash[key].empty?
      return true
    end
  end
end