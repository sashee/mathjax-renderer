Feature: The renderer can generate the HTML content that displays the mathml

  Scenario: The renderer generates the HTML from MathML
    When the renderer is invoked with
      """
      <math xmlns="http://www.w3.org/1998/Math/MathML">
        <mi>a</mi><msup><mi>x</mi><mn>2</mn></msup>
        <mo>+</mo> <mi>b</mi><mi>x</mi>
        <mo>+</mo> <mi>c</mi> <mo>=</mo> <mn>0</mn>
      </math>
      """
    Then the result text is "ax2+bx+c=0"
      And the contains more than 10 HTML tags

  Scenario: The renderer generates HTML from TeX
    When the renderer is invoked with
    """
      \(ax^2 + bx + c = 0\)
    """
    Then the result text is "ax2+bx+c=0"
      And the contains more than 10 HTML tags