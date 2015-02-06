Feature: The renderer can render PNG images from math

  Scenario: When an image path is supplied, the generated image is put there
    Given the image path is set
    When the renderer is invoked with a valid expression
    Then the image is generated in the directory

  Scenario: When there is no image path supplied, then an image is not generated
    Given the image path is not set
    When getting the image path
    Then an Exception occurs

  Scenario: The generated image contains the expression
    Given an image is generated for the formulae
    """
    \(ax^2 + bx + c = 0\)
    """
    Then it's width is at least 120px
      And it's height is at least 10px