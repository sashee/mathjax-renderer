module Mathjax_Renderer
  class Renderer
    require 'capybara'
    require 'capybara/dsl'
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

      url = server.add_content(@mathml, @options[:extra_style], @options[:padding])

			require 'phantomjs/poltergeist'
			require 'phantomjs'
			Capybara.register_driver :poltergeist do |app|
				Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
			end
			Capybara.default_driver = :poltergeist
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

				image = ChunkyPNG::Image.from_file(image_path)

				location = page.driver.evaluate_script <<-EOS
					function() {
						var ele  = document.querySelector('.MathJax .math');
						var rect = ele.getBoundingClientRect();
						return [rect.left, rect.top];
					}();
				EOS

				size = page.driver.evaluate_script <<-EOS
					function() {
						var ele  = document.querySelector('.MathJax .math');
						var rect = ele.getBoundingClientRect();
						return [rect.width, rect.height];
					}();
				EOS

				correction = [(@options[:min_width] -(size[0] + 2 * @options[:padding])) / 2,0].max

				x = location[0] + 1 - @options[:padding]-correction
				y = location[1] + 1 - @options[:padding]
				width = [size[0].ceil + 2 * @options[:padding],@options[:min_width]].max
				height = size[1]+ 2 * @options[:padding]

				image.crop!(x, y, width, height)
				image.save(image_path)
			end
			result = Nokogiri::HTML(page.html).css('.MathJax .math')[0]

			put_cache!(params_hash,result)

			@html = result
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

    def add_content(content, extra_style = '', padding = 0)
      digest = Digest::SHA1.hexdigest(content)
      path = "/#{digest}.html"
      server.mount_proc path do |_, res|
        res.body = response(content, extra_style, padding)
      end

      path
    end

    def port
      server.config[:Port]
    end

    def response(content, extra_style, padding)
      "
        <html><head>
      <script type='text/x-mathjax_renderer-config'>
          MathJax.Hub.Config({
            messageStyle: 'none',
            showMathMenu:false
          });
      </script>
      <script type='text/javascript'
            src='https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML'></script>
<style>body{display: flex;justify-content: center;}
#{extra_style}
.MathJax{
	left: #{padding}px;
	top: #{padding}px;
}</style>
</head><body>#{content}</body></html>"
    end

    def ensure_started!
      if start!
        Thread.start do
          require 'webrick'

          self.server = WEBrick::HTTPServer.new(
            :Port => 0,
            :AccessLog => [],
            :Logger => WEBrick::Log::new('/dev/null', 7)
          )

          server.mount_proc "/index.html" do |_, res|
            res.body = "OK"
          end

          begin
            server.start
          ensure
            server.shutdown
          end
        end
      end
      def server_started?
        require 'net/http'
        uri = URI("http://localhost:#{port}/index.html")

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
