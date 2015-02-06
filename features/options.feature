Feature: Padding, min width and additional styles can be set for image generation

  Scenario: If a padding is set, then the generated image is bigger
    When an image is generated with 10px padding
    Then it's size increases by 20px in every dimension

  Scenario: If min width is set, then no image will be smaller than that
    When an image is generated with 300px min width for
    """
    \(ax^2 + bx + c = 0\)
    """
    Then it's width is 300px

  Scenario: If additional styles are supplied, they will be applied to the image
    Given an image is generated for the formulae
    """
    \(ax^2 + bx + c = 0\)
    """
      And the additional styles are
    """
      body{background-color:blue;}
    """
    Then the generated image is mostly blue