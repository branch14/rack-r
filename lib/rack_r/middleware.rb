require 'ostruct'
require 'yaml'
require 'erb'

require 'csv'

module RackR
  class Middleware < Struct.new :app, :options

    def call(env)
      @env = env
      return call_app unless config.enabled
      if get? and md = match_path
        key = md.to_a.last
        return [200, {}, ['RackR OK.']] if key.empty?
        process key
      else
        extract
      end
    end

    def call_app
      app.call(@env)
    end

    def extract
      status, headers, response = call_app
      if headers["Content-Type"] =~ /text\/html|application\/xhtml\+xml/
        # TODO if contains <script type="text/r">
        body = ""
        response.each { |part| body << part }
        while md = body.match(node_regex)
          tempdir = temp_dir
          key = File.basename(tempdir)
          r_script = ERB.new(config.r_header).result(binding) + md.to_a.last
          write_file(File.join(tempdir, config.r_file), r_script)
          body.sub!(node_regex, ajaxer(key))
        end
        headers["Content-Length"] = body.length.to_s
        response = [ body ]
      end
      [ status, headers, response ]
    end

    def process(key)
      path = temp_dir(key)
      return call_app unless File.directory?(path) # TODO render error msg
      time = exec_r_script(config.r_file, path)
      files = Dir.entries(path).sort
      # build body
      body = [ config.html.prefix ]
      files.each do |file|
        config.templates.each do |template|
          if file =~ Regexp.new(template['pattern'], Regexp::IGNORECASE)
            src = File.join(path, file)
            eval(template['process']) unless template['process'].nil?
            body << ERB.new(template['template']).result(binding)
          end
        end
      end
      # TODO remove temp dir
      body << config.html.suffix
      [ 200, { "Content-Type" => "text/html" }, body ]
    end

    # return true if request method is GET
    def get?
      @env["REQUEST_METHOD"] == "GET"
    end

    def path_regex
      Regexp.new "^#{config.url_scope}/(.*)"
    end

    def node_regex
      opts = Regexp::IGNORECASE + Regexp::MULTILINE
      Regexp.new config.node_regex, opts
    end

    def path_info
      @env["PATH_INFO"]
    end

    def match_path
      path_info.match(path_regex)
    end

    def exec_r_script(file, path=nil)
      cmd = path.nil? ? "R CMD BATCH #{file}" :
        "(cd #{path} && R CMD BATCH #{file})"
      %x[#{cmd}]
    end

    def temp_dir(key=nil)
      return Dir.mktmpdir(config.temp.prefix, config.temp.dir) if key.nil?
      File.join config.temp.dir, key
    end

    def write_file(path, content)
      ::File.open(path, 'w') { |f| f.puts content }
    end

    def public_path
      config.public_path.tap do |path|
        FileUtils.mkdir_p(path) unless File.directory?(path)
      end
    end

    def ajaxer(key)
      ERB.new(config.ajaxer).result(binding)
    end

    def default_config
      ::File.read(__FILE__).gsub(/.*__END__\n/m, '')
    end

    def config_path
      options[:config].tap do |path|
        raise "no config path given" unless path
      end
    end

    def config
      return @config unless @config.nil?
      write_file(config_path, default_config) unless ::File.exist?(config_path)
      @config = deep_ostruct(::File.open(config_path) { |yf| YAML::load(yf) })
    end

    private

    def deep_ostruct(hash)
      OpenStruct.new(hash).tap do |ostruct|
        hash.keys.each do |key|
          if ostruct.send(key).is_a?(Hash)
            ostruct.send("#{key}=", deep_ostruct(hash[key]))
          end
        end
      end
    end

  end
end

__END__
# RackR -- process R on the fly
# RackR depends on jQuery >= 1.4.4
#
# changes to this file will not be picked up
# without a restart of your app
#
enabled:     true
url_scope:   /rack-r
public_path: public/system/rack-r
public_url:  /system/rack-r
temp:
  dir:       /tmp
  prefix:    rr_
r_file:      script.R
r_header: |
  # modify this header in rack-r config file
  library('yaml')
  dbconf <- yaml.load_file('<%= Rails.root %>/config/database.yml')
  dbname <- dbconf$production$database
  # TODO connect to database with rodbc or dbi
  # db <- rodbc.connect(dbname)
ajaxer: |
  <div class='rack_r' id='<%= key %>'>Processing R...</div>
  <script type='text/javascript'>
    var url = '<%= config.url_scope %>/<%= key %>';
    $.ajax(url, { success: function(data) { $('#<%= key %>').html(data); } });
  </script>
html:
  prefix:    <div class='rack_r_out'>
  suffix:    </div>
templates:
  - pattern: .svg$
    process: |
      svg = File.read(src)
    template: |
      <%= svg %>
  - pattern: .(jpg|jpeg|png)$
    process: |
      # TODO build dst with key, otherwise may lead to undesired results
      dst = File.join(public_path, file)
      FileUtils.cp(src, dst)
      url = "#{config.public_url}/#{file}"
    template: |
      <img src='<%= url %>' />
  - pattern: .csv$
    process: |
      table = CSV.read(src)
      # TODO build dst with key, otherwise may lead to undesired results
      dst = File.join(public_path, file)
      FileUtils.cp(src, dst)
      url = "#{config.public_url}/#{file}"
    template: |
      <a href='<%= url %>'><%= file %></a>
      <table>
        <% table.each do |row| %>
          <tr>
            <% row.each do |col| %>
              <td><%= col %></td>
            <% end %>
          </tr>
        <% end %>
      </table>
  - pattern: .Rout$
    process: |
      rout = File.read(src)
    template: |
      <pre><%= rout %></pre>
node_regex:  <script\s+type=['"]text/r['"]\s*>(.*?)</script>
#
# uncomment the following two lines, if your project
# doesn't use jquery already
# javascripts:
#   - http://code.jquery.com/jquery-1.5.1.min.js
# or this line if you want to ship it yourself
#   - /javascripts/jquery-1.5.1.min.js
# uncomment the following line, in case your project uses prototype
# jquery_noconflict: true
