When(/^the renderer is invoked with$/) do |string|
  @renderer = Mathjax_Renderer::Renderer.new(string)
end

Then(/^the result text is "(.*?)"$/) do |arg1|
  expect(@renderer.html.inner_text).to eq arg1
end

Then(/^the contains more than (\d+) HTML tags$/) do |arg1|
  expect(@renderer.html.xpath('.//*').size).to be >= arg1.to_i
end
