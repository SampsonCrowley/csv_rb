# frozen_string_literal: true

require 'action_controller'
require 'csv_rb/stream_csv_deflator'
unless Mime[:csv]
  Mime::Type.register 'text/csv', :csv
end

ActionController::Renderers.add :csv do |filename, options|
  #
  # You can always specify a template:
  #
  #  def called_action
  #    render csv: 'filename', template: 'controller/diff_action'
  #  end
  #
  # And the normal use case works:
  #
  #  def called_action
  #    render 'diff_action'
  #    # or
  #    render 'controller/diff_action'
  #  end
  #
  options[:template] = filename.gsub(/^.*\//,'') if options[:template] == action_name
  options[:template] = "#{options[:template]}.csv.csvrb" unless options[:template] =~ /\.csvrb/
  options[:layout] = false
  options[:locals] ||= {}
  file_name = "#{options.delete(:filename) || filename.gsub(/^.*\//,'')}#{options.delete(:with_time) ? "-#{Time.zone.now.to_s}" : ''}.csv".sub(/(\.csv)+$/, '.csv')

  response.headers["Content-Type"] = "text/csv; charset=utf-8"

  unless options.delete(:allow_cache)
    with_compression = !options.delete(:skip_compression)

    expires_now
    response.headers["X-Accel-Buffering"] = 'no'
    response.headers["Content-Type"] = "text/csv; charset=utf-8"
    response.headers["Content-Encoding"] = 'deflate' if with_compression
    response.headers["Content-Disposition"] = %(attachment; filename="#{file_name}")


    return self.response_body = Enumerator.new do |y|
      csv = CSVRb::StreamCSVDeflator.new(y, with_compression)
      view_context.instance_eval lookup_context.find_template(options[:template], options[:prefixes], options[:partial], options.dup.merge(formats: [:csv])).source
      csv.close
    end
  else
    disposition = options.delete(:disposition) || 'attachment'

    send_data render_to_string(options), filename: file_name, type: Mime[:csv], disposition: disposition
  end
end

# For respond_to default
begin
  ActionController::Responder
rescue
else
  class ActionController::Responder
    def to_csv
      @_action_has_layout = false
      if @default_response
        @default_response.call(options)
      else
        controller.render({csv: controller.action_name}.merge(options))
      end
    end
  end
end
