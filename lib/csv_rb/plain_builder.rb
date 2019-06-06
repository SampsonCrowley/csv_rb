module CSVRb
  class PlainBuilder
    def value
      @value ||= "#{}"
    end

    def stream(row)
      value << CSV.generate_line(row, force_quotes: true, encoding: 'utf-8')
    end

    def <<(row)
      stream(row)
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
