# Mathjax::Renderer

This gem is to pre-render MathJax expressions or export them as images. Since MathJax uses client-side
Javascript and styles to convert MathML (along with other formats) to HTML, this is not compatible
with article readers like Pocket as they do not run scripts. mathjax-renderer solves this by
generating images from MathJax expressions which can be inserted to the site instead of the MathML
expression, thus making them visible to readers. Also, there is an option to generate the HTML,
so you can remove the client-side scripts.

You can find some background in this blog post: https://advancedweb.hu/2015/03/17/mathjax-processing-on-the-server-side/

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mathjax-renderer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mathjax-renderer

## Usage

mathjax-renderer can generate the HTML from running the MathJax scripts, and it can be used to directly
generate an image from the result. It uses a global cache, so it is fast for the second time for the
same input.

### Generating the HTML

To generated the HTML, just call:

```ruby
Mathjax_Renderer::Renderer.new(mathml_string).html
```

Then, the resulting HTML can be directly inserted to the page. This also needs the MathJax fonts, so
don't forget to include them as well:

```
@font-face {font-family: MathJax_Main; src: url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/woff/MathJax_Main-Regular.woff?rev=2.5.0') format('woff'), url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/otf/MathJax_Main-Regular.otf?rev=2.5.0') format('opentype')}
@font-face {font-family: MathJax_Main-bold; src: url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/woff/MathJax_Main-Bold.woff?rev=2.5.0') format('woff'), url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/otf/MathJax_Main-Bold.otf?rev=2.5.0') format('opentype')}
@font-face {font-family: MathJax_Main-italic; src: url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/woff/MathJax_Main-Italic.woff?rev=2.5.0') format('woff'), url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/otf/MathJax_Main-Italic.otf?rev=2.5.0') format('opentype')}
@font-face {font-family: MathJax_Math-italic; src: url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/woff/MathJax_Math-Italic.woff?rev=2.5.0') format('woff'), url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/otf/MathJax_Math-Italic.otf?rev=2.5.0') format('opentype')}
@font-face {font-family: MathJax_Caligraphic; src: url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/woff/MathJax_Caligraphic-Regular.woff?rev=2.5.0') format('woff'), url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/otf/MathJax_Caligraphic-Regular.otf?rev=2.5.0') format('opentype')}
@font-face {font-family: MathJax_Size1; src: url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/woff/MathJax_Size1-Regular.woff?rev=2.5.0') format('woff'), url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/otf/MathJax_Size1-Regular.otf?rev=2.5.0') format('opentype')}
@font-face {font-family: MathJax_Size2; src: url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/woff/MathJax_Size2-Regular.woff?rev=2.5.0') format('woff'), url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/otf/MathJax_Size2-Regular.otf?rev=2.5.0') format('opentype')}
@font-face {font-family: MathJax_Size3; src: url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/woff/MathJax_Size3-Regular.woff?rev=2.5.0') format('woff'), url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/otf/MathJax_Size3-Regular.otf?rev=2.5.0') format('opentype')}
@font-face {font-family: MathJax_Size4; src: url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/woff/MathJax_Size4-Regular.woff?rev=2.5.0') format('woff'), url('http://cdn.mathjax.org/mathjax/latest/fonts/HTML-CSS/TeX/otf/MathJax_Size4-Regular.otf?rev=2.5.0') format('opentype')}
```

_Note:_ don't forget that you already have these as a transitive dependency to rails-assets-MathJax.
Be nice and use those instead.

### Generating image

To generate the image as well, just supply a base folder to store the images:

```ruby
Mathjax_Renderer::Renderer.new(mathml_string, image_directory).image_name
```

This generates the image and gets back the name in the target directory.

There are a few configurations possible:

* *min_width:* The resulting image will be at least wide in pixels. Pocket enlarges images that are too small,
making them a bit bigger disables this behaviour
* *extra_style:* These will be appended to a style element. Use it to set text color, background color,
or any other styles that would have been applied to the HTML in your site.
* *padding:* A padding in pixels will be added to both dimensions.

## Caveats

mathjax-renderer internally uses a WEBrick server to generate the results in a random free port. It is
started when the renderer is first called, and remains running.

## Contributing

1. Fork it ( https://github.com/sashee/mathjax-renderer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
