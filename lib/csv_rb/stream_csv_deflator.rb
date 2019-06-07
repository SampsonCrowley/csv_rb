module CSVRb
  class StreamCSVDeflator
    def initialize(enum, with_compression = true)
      @enum = enum
      @with_compression = with_compression
      @deflator = Zlib::Deflate.new
    end

    def y
      @enum
    end

    def set(value)
      y << compress(value)
    end

    def stream(row)
      y << compress(
        CSV.generate_line(row, force_quotes: true, encoding: 'utf-8')
      )
    end

    def <<(row)
      stream(row)
    end

    def close
      y << @deflator.flush(Zlib::FINISH) if @with_compression
    end

    private
      def compress(value)
        @with_compression \
          ? @deflator.deflate(value, Zlib::SYNC_FLUSH) \
          : value
      end

  end
end
