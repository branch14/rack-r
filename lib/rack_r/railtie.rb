require 'rack_r/middleware'

module RackR
  
  case Rails.version.to_i
  when 2
    Rails.configuration.middleware.use RackR::Middleware,
      :config => File.expand_path('config/rack-r.yml', RAILS_ROOT)

  when 3
    class Railtie < Rails::Railtie
      initializer "rack_r.insert_middleware" do |app|
        app.config.middleware.use "RackR::Middleware",
          :config => File.expand_path('config/rack-r.yml', Rails.root)
      end
    end

  else
    raise "Unknown Rails version"
  end

end

