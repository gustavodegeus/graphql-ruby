# frozen_string_literal: true
module GraphQL
  module Types
    # This scalar takes `DateTime`s and transmits them as strings,
    # using ISO 8601 format.
    #
    # Use it for fields or arguments as follows:
    #
    #     field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    #
    #     argument :deliver_at, GraphQL::Types::ISO8601DateTime, null: false
    #
    # Alternatively, use this built-in scalar as inspiration for your
    # own DateTime type.
    class ISO8601DateTime < GraphQL::Schema::Scalar
      description "An ISO 8601-encoded datetime"

      # It's not compatible with Rails' default,
      # i.e. ActiveSupport::JSON::Encoder.time_precision (3 by default)
      DEFAULT_TIME_PRECISION = 0

      # @return [Integer]
      def self.time_precision
        @time_precision || DEFAULT_TIME_PRECISION
      end

      # @param [Integer] value
      def self.time_precision=(value)
        @time_precision = value
      end

      # @param value [Date,DateTime,String]
      # @return [String]
      def self.coerce_result(value, _ctx)\
        case value
        when DateTime
          return value.iso8601(time_precision)
        when Date
          return DateTime.parse(value.to_s).iso8601(time_precision)
        when ::String
          return DateTime.parse(value).iso8601(time_precision)
        else
          # In case some other API-compliant thing is given: 
          return value.iso8601(time_precision)
        end 
      rescue StandardError => error
        raise GraphQL::Error, "An incompatible object (#{value.class}) was given to #{self}. Make sure that only Dates, DateTimes, and well-formatted Strings are used with this type. (#{error.message})"
      end

      # @param str_value [String]
      # @return [DateTime]
      def self.coerce_input(str_value, _ctx)
        DateTime.iso8601(str_value)
      rescue ArgumentError
        # Invalid input
        nil
      end
    end
  end
end
