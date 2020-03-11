module CSVRb
  class StreamBuilder
    def initialize(enumerator, with_compression = true)
      @enumerator = enumerator
      @with_compression = with_compression
      @deflator = Zlib::Deflate.new if @with_compression
    end

    def y
      @enumerator
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
