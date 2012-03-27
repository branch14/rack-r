require File.expand_path('../helper', __FILE__)
require 'rack/mock'

class TestRackR < Test::Unit::TestCase

  CONFIGFILE = '/tmp/test_rack_r'
  File.unlink(CONFIGFILE) if File.exist?(CONFIGFILE)

  EXPECTED_CODE = /class='rack_r'/

  context "Util" do
    should "create proper temp dir" do
      td = app.temp_dir
      assert File.directory?(td)

      base = File.basename(td)
      assert_equal td, app.temp_dir(base)

      assert FileUtils.rm_rf(td)
      assert !File.exist?(td)
    end
  end

  context "Proper regexs" do
    should "detect r code if present" do
      assert_match app.node_regex, HTML_POSITIVE
    end

    should "not detect r code if none is present" do
      assert_no_match app.node_regex, HTML_NEGATIVE
    end
  end

  context "Embedding payload" do
    should "place the payload in body of an HTML request" do
      assert_match EXPECTED_CODE, request.body
    end

    should "place the payload in body of an XHTML request" do
      response = request(:content_type => 'application/xhtml+xml')
      assert_match EXPECTED_CODE, response.body
    end
  
    should "not place the payload in a non HTML request" do
      response = request(:content_type => 'application/xml', :body => [XML])
      assert_no_match EXPECTED_CODE, response.body
    end
    
    should "not place the playload in a document not containing r code" do
      response = request(:body => HTML_NEGATIVE)
      assert_no_match EXPECTED_CODE, response.body
    end
  end

  context "Processing R" do
    should 'detect get request' do
      request(:path => "/rack-r/rr-some-random-key")
      assert @app.get?
    end

    should 'detect path' do
      request(:path => "/rack-r/rr-some-random-key")
      assert @app.match_path
    end

    should 'properly respond to rack_r request' do
      key = 'rr-some-key'
      path = app.temp_dir(key)
      FileUtils.rm_rf(path) if File.exist?(path)
      Dir.mkdir(path)
      src = File.expand_path('../example.r', __FILE__)
      dst = File.join(path, app.config.r_file)
      FileUtils.cp(src, dst)
      response = request(:path => "/rack-r/#{key}")
      assert Dir.entries(path).include?('insurance.png')
      regex = Regexp.new("src='#{@app.config.public_url}/insurance.png'")
      assert_match regex, response.body
      FileUtils.rm_rf(path)
    end
  end

  # context "Deliver payload" do
  #   setup do
  #     @expected_file = File.expand_path(File.join(%w(.. .. public) << PAYLOAD), __FILE__)
  #     @response = request({}, "/#{PAYLOAD}")
  #   end
  # 
  #   should "deliver #{PAYLOAD}" do
  #     expected = File.read(@expected_file)
  #     assert expected, @response.body
  #   end
  # 
  #   should "set the content-type correctly" do
  #     assert 'text/javascript', @response.body
  #   end
  # end

  private

  HTML_POSITIVE = <<-EOHTML
   <html>
     <head>
       <title>Sample Page</title>
     </head>
     <body>
       <h2>Here goes some R</h2>
       <script type='text/r'>
         some invalid r code
       </script>
     </body>
   </html>
  EOHTML

  HTML_NEGATIVE = <<-EOHTML
   <html>
     <head>
       <title>Sample page with no matching node</title>
     </head>
     <body>
       <p>Empty page.</p>
     </body>
   </html>
  EOHTML

  XML = <<-EOXML
   <?xml version="1.0" encoding="ISO-8859-1"?>
   <user>
     <name>Some Name</name>
     <age>Some Age</age>
   </user>
  EOXML
  
  def request(options={})
    path = options.delete(:path) || '/'
    @app = app(options)
    request = Rack::MockRequest.new(@app).get(path)
    yield(@app, request) if block_given?
    request
  end
  
  def app(options={})
    options = options.clone
    options[:content_type] ||= "text/html"
    options[:body]         ||= [ HTML_POSITIVE ]
    rack_app = lambda do |env|
      [ 200,
        { 'Content-Type' => options.delete(:content_type) },
        options.delete(:body) ]
    end
    RackR::Middleware.new(rack_app, :config => CONFIGFILE)
  end

end
