# frozen_string_literal: true

require 'action_view'
require 'stringio'

module ActionView
  class Template
    module Handlers
      class CSVRbBuilder

        def default_format
          Mime[:csv]
        end

        def call(template, source = nil)
          builder = StringIO.new
          builder << "# encoding: utf-8\n"
          builder << "require 'csv';"
          builder << "require 'csv_rb/plain_builder';"
          builder << "csv ||= CSVRb::PlainBuilder.new;"
          builder << (source || template.source)
          builder << ";csv = csv.to_str if csv.is_a?(CSVRb::PlainBuilder); csv;"
          builder.string
        end

        def handles_encoding?
          true
        end
      end
    end
  end
end
