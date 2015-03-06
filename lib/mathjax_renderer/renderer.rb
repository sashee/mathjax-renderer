module Mathjax_Renderer
  class Renderer
    require 'capybara'
    require 'capybara/dsl'
    require 'headless'
    require 'timeout'

    include Capybara::DSL

    def initialize(mathml, image_base_url = nil, options = {})
      @mathml = mathml
      @image_base_url = image_base_url
      @options = {min_width: 0, extra_style:'', padding:0}.merge options
    end

    def image_name
      raise ArgumentError if @image_base_url.nil?
      render! unless File.exist?(image_path)
      _image_name
    end

    def render!
      server = RendererServer.new
      server.ensure_started!

      url = server.add_content(@mathml, @options[:extra_style])

      Headless.ly do

        Capybara.register_driver :chrome do |app|
          Capybara::Selenium::Driver.new(app, :browser => :chrome, :args => ['no-sandbox','no-default-browser-check','no-first-run','disable-default-apps'])
        end

        Capybara.default_driver = :chrome
        Capybara.app_host = "http://localhost:#{server.port}"

        visit url

        def mathjax_ready?(page)
          html = Nokogiri::HTML(page.html)
          !html.css('.MathJax').empty? &&
            html.css('.MathJax_Processing').empty? &&
            html.css('.MathJax_Processed').empty?
        end

        Timeout.timeout(5) do
          sleep 0.1 until mathjax_ready?(page)
        end

        unless @image_base_url.nil?
          require 'chunky_png'
          driver = page.driver

          require 'fileutils'
          FileUtils.mkpath @image_base_url

          driver.save_screenshot(image_path)

          el= page.find('.MathJax .math').native

          image = ChunkyPNG::Image.from_file(image_path)

          correction = [(@options[:min_width] -(el.size.width + 2 * @options[:padding])) / 2,0].max

          x = el.location.x + 1 - @options[:padding]-correction
          y = el.location.y + 1 - @options[:padding]
          width = [el.size.width + 2 * @options[:padding],@options[:min_width]].max
          height = el.size.height+ 2 * @options[:padding]

          image.crop!(x, y, width, height)
          image.save(image_path)
        end
        result = Nokogiri::HTML(page.html).css('.MathJax')[0]

        put_cache!(params_hash,result)

        page.driver.quit

        @html = result
      end
    end

    def html
      return cached(params_hash) if cached? params_hash

      render! if @html.nil?

      @html
    end

    private

    def params_hash
      Digest::SHA1.hexdigest(@mathml+@options.to_s)
    end

    def image_path
      "#{@image_base_url}/#{_image_name}"
    end

    def _image_name
      "#{params_hash}.png"
    end

    @@cache={}

    def cache
      @@cache
    end

    def cached?(mathml)
      cache.has_key?(mathml)
    end

    def cached(mathml)
      cache[mathml]
    end

    def put_cache!(mathml,result)
      cache[mathml]=result
    end
  end

  class RendererServer
    require 'concurrent/atomic/atomic_boolean'
    require 'digest'

    def add_content(content, extra_style = '')
      digest = Digest::SHA1.hexdigest(content)
      path = "/#{digest}.html"
      server.mount_proc path do |_, res|
        res.body = response(content, extra_style)
      end

      path
    end

    def port
      server.config[:Port]
    end

    def response(content, extra_style)
      "
        <html><head>
      <script type='text/x-mathjax_renderer-config'>
          MathJax.Hub.Config({
            messageStyle: 'none',
            showMathMenu:false
          });
      </script>
      <script type='text/javascript'
            src='javascripts/MathJax/MathJax.js?config=TeX-AMS-MML_HTMLorMML'></script>
<style>body{display: flex;justify-content: center;}
#{extra_style}</style>
</head><body>#{content}</body></html>"
    end

    def ensure_started!
      if start!
        Thread.start do
          require 'webrick'
          mathjax_dir = Gem::Specification.find_by_name("rails-assets-MathJax").gem_dir

          self.server = WEBrick::HTTPServer.new(
            :Port => 0,
            :DocumentRoot => "#{mathjax_dir}/app/assets",
            :AccessLog => [],
            :Logger => WEBrick::Log::new('/dev/null', 7)
          )

          server.mount '/javascripts/MathJax/fonts',
                       WEBrick::HTTPServlet::FileHandler,
                       "#{mathjax_dir}/app/assets/fonts/MathJax/fonts"

          begin
            server.start
          ensure
            server.shutdown
          end
        end
      end
      def server_started?
        require 'net/http'
        uri = URI("http://localhost:#{port}/javascripts/MathJax/MathJax.js")

        req = Net::HTTP::Get.new(uri)
        res = Net::HTTP.start(uri.hostname, uri.port) {|http|
          http.read_timeout = 1
          http.request(req)
        }

        res.is_a?(Net::HTTPSuccess)
      rescue
        false
      end

      Timeout.timeout(5) do
        sleep 0.1 until server_started?
      end

    end

    private

    def server
      @@server
    end

    def server=(server)
      @@server = server
    end

    @@started=Concurrent::AtomicBoolean.new

    def start!
      @@started.make_true
    end

  end
end