Given(/^the image path is set$/) do
  @img_path = $tmpdir
end

When(/^the renderer is invoked with a valid expression$/) do
  @renderer = Mathjax_Renderer::Renderer.new('\(ax^2 + bx + c = 0\)', @img_path)
end

Then(/^the image is generated in the directory$/) do
  img_name = @renderer.image_name
  expect(File.exists? @img_path + '/' +img_name).to be
end

Given(/^the image path is not set$/) do
  @img_path = nil
end

Then(/^an Exception occurs$/) do
  expect(@exception).to be
end

When(/^getting the image path$/) do
  begin
    @renderer.image_name
    rescue => @exception
  end
end

Given(/^an image is generated for the formulae$/) do |string|
  @expression = string
  renderer = Mathjax_Renderer::Renderer.new(@expression, $tmpdir)
  @image = ChunkyPNG::Image.from_file("#{$tmpdir}/#{renderer.image_name}")
end

Then(/^it's width is at least (\d+)px$/) do |arg1|
  expect(@image.width).to be >= arg1.to_i
end

Then(/^it's height is at least (\d+)px$/) do |arg1|
  expect(@image.height).to be >= arg1.to_i
end

When(/^an image is generated with (\d+)px padding$/) do |arg1|
  original_renderer = Mathjax_Renderer::Renderer.new('\(ax^2 + bx + c = 0\)', $tmpdir)
  padded_renderer = Mathjax_Renderer::Renderer.new('\(ax^2 + bx + c = 0\)', $tmpdir, padding: arg1.to_i)
  @original_image = ChunkyPNG::Image.from_file("#{$tmpdir}/#{original_renderer.image_name}")
  @padded_image = ChunkyPNG::Image.from_file("#{$tmpdir}/#{padded_renderer.image_name}")
end

Then(/^it's size increases by (\d+)px in every dimension$/) do |arg1|
  expect(@padded_image.width).to eq @original_image.width + arg1.to_i
  expect(@padded_image.height).to eq @original_image.height + arg1.to_i
end

When(/^an image is generated with (\d+)px min width for$/) do |arg1, string|
  renderer = Mathjax_Renderer::Renderer.new(string, $tmpdir, min_width:arg1.to_i)
  @image = ChunkyPNG::Image.from_file("#{$tmpdir}/#{renderer.image_name}")
end

Then(/^it's width is (\d+)px$/) do |arg1|
  expect(@image.width).to eq arg1.to_i
end

Given(/^the additional styles are$/) do |string|
  renderer = Mathjax_Renderer::Renderer.new(@expression, $tmpdir, extra_style:string)
  @image = ChunkyPNG::Image.from_file("#{$tmpdir}/#{renderer.image_name}")
end

Then(/^the generated image is mostly blue$/) do
  blue = 0
  @image.width.times do |x|
    @image.height.times do |y|
			b = ChunkyPNG::Color.b(@image[x,y])
			g = ChunkyPNG::Color.g(@image[x,y])
			r = ChunkyPNG::Color.r(@image[x,y])
       blue += 1 if b == 255 && g == 0 && r == 0
    end
  end

  all_pixels = @image.width * @image.height

  expect(blue).to be >= all_pixels / 2
end
