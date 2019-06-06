# frozen_string_literal: true

module CSVRb
  class Railtie < Rails::Railtie
    initializer 'csv_rb.initialization' do
      ActiveSupport.on_load(:action_view) do
        require 'csv_rb/template_handler'
        ActionView::Template.register_template_handler :csvrb, ActionView::Template::Handlers::CSVRbBuilder.new
      end

      ActiveSupport.on_load(:action_controller) do
        require 'csv_rb/action_controller'
      end
    end
  end
end
