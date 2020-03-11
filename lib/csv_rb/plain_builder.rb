require 'csv_rb/stream_builder'

module CSVRb
  class PlainBuilder < StreamBuilder
    def initialize(*)
      super("#{}", false)
    end

    def value
      y
    end

    def set(complete_value)
      @enumerator = complete_value || "#{}"
    end

    def close
      to_s
    end

    def to_str
      to_s
    end

    def to_s
      value
    end
  end
end
