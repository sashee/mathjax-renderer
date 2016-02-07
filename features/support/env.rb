require 'mathjax_renderer/renderer'
require 'chunky_png'

Around do |scenario, block|
  Dir.mktmpdir{|tmpdir|
    $tmpdir = tmpdir
    block.call
  }
end
