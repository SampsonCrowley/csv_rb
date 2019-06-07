module CSVRb
  class StreamCSVDeflator
    def initialize(enum)
      @enum = enum
      @deflator = Zlib::Deflate.new
    end

    def y
      @enum
    end

    def set(value)
      y << value
    end

    def stream(row)
      v = CSV.generate_line(row, force_quotes: true, encoding: 'utf-8')
      y << @deflator.deflate(v, Zlib::SYNC_FLUSH)
    end

    def <<(row)
      stream(row)
    end

    def close
      y << @deflator.flush(Zlib::FINISH)
    end
  end
end
