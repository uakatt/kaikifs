class ApproximationsFactory
  # Build a list of "approximations" (an Array of Strings) based on the two arguments, the
  # `base`, and the `combinations`. Building the approximations uses `base` as a format string.
  # Really it keys in on the presence of `%s` in `base`. It will format the base repeatedly
  # using the different combinations. Let's just look at some examples:
  #
  # So a single String in `combinations`, or a single 1-element Array in `combinations` will
  # result in one approximation:
  #
  #     ApproximationsFactory.build('My name is %s.', 'Sam')
  #       #=> ['My name is Sam.']
  #
  #     ApproximationsFactory.build('My name is %s.', ['Sam'])
  #       #=> ['My name is Sam.']
  #
  # Boring enough. Let's do a simple example with two elements in `combinations`:
  #
  #     ApproximationsFactory.build('%s there. My name is %s.', 'Hello', 'Sam')
  #       #=> ['Hello there. My name is Sam.']
  #
  # Still boring, but you see where this is going...
  #
  #     ApproximationsFactory.build('My name is %s', ['Sam', 'Bjorn'])
  #       #=> ['My name is Sam.', 'My name is Bjorn.']
  #
  # Oh! Now I see how this is going to be useful!
  #
  #     ApproximationsFactory.build('%s there. My name is %s.', ['Hi', 'Hello'], ['Sam', 'Bjorn'])
  #       #=> ['Hi there. My name is Sam.',
  #       #    'Hi there. My name is Bjorn.',
  #       #    'Hello there. My name is Sam.',
  #       #    'Hello there. My name is Bjorn.']
  #
  #     ApproximationsFactory.build('%s there. My name is %s.', [['Hi', 'Hello'], ['Sam', 'Bjorn']])
  #       #=> ['Hi there. My name is Sam.',
  #       #    'Hi there. My name is Bjorn.',
  #       #    'Hello there. My name is Sam.',
  #       #    'Hello there. My name is Bjorn.']
  #
  # The difference between those two examples is that you can pass in `combinations` as a
  # list of arguments, or as an Array object, whichever fits your needs.
  #
  # Now the final, giant example using XPaths, that inspired this library:
  #
  #     ApproximationsFactory.build(
  #         "//%s[contains(text()%s, '%s')]/../following-sibling::td/%s",
  #         ['th/label', 'th/div'],
  #         ['', '[1]', '[2]'],
  #         ['Group Id'],
  #         ['select[1]', 'input[1]'])
  #       #=> ["//th/label[contains(text(), 'Group Id')]/../following-sibling::td/select[1]",
  #       #    "//th/label[contains(text(), 'Group Id')]/../following-sibling::td/input[1]",
  #       #    "//th/label[contains(text()[1], 'Group Id')]/../following-sibling::td/select[1]",
  #       #    "//th/label[contains(text()[1], 'Group Id')]/../following-sibling::td/input[1]",
  #       #    "//th/label[contains(text()[2], 'Group Id')]/../following-sibling::td/select[1]",
  #       #    "//th/label[contains(text()[2], 'Group Id')]/../following-sibling::td/input[1]",
  #       #    "//th/div[contains(text(), 'Group Id')]/../following-sibling::td/select[1]",
  #       #    "//th/div[contains(text(), 'Group Id')]/../following-sibling::td/input[1]",
  #       #    "//th/div[contains(text()[1], 'Group Id')]/../following-sibling::td/select[1]",
  #       #    "//th/div[contains(text()[1], 'Group Id')]/../following-sibling::td/input[1]",
  #       #    "//th/div[contains(text()[2], 'Group Id')]/../following-sibling::td/select[1]",
  #       #    "//th/div[contains(text()[2], 'Group Id')]/../following-sibling::td/input[1]"]
  def self.build(base, *combinations)
    if combinations.all? {|c| c.is_a? String }
      # Something like AF.build base, 'Sam'
      #             or AF.build base, 'Hello', 'Sam'
      # so no combinations, just interpolate
      return [base % combinations]
    end

    if combinations[0].is_a? Array and combinations[0][0].is_a? Array
      # Something like AF.build '%s there. My name is %s.',
      #                         [['Hi', 'Hello'],
      #                          ['Sam', 'Greatest']]
      combinations = combinations[0]
    end

    results = [base]
    combinations.each do |choices|
      new_results = []

      results.each do |b|
        new_results += interpolate_each(b, choices)
      end

      results = new_results
    end

    return results
  end

  # Allow for a more aesthetic list of combinations. This allows you to write
  #
  #     ApproximationsFactory.build(
  #         "//%s[contains(text()%s, 'Group Id')]/../following-sibling::td/%s",
  #         ['th/label', 'th/div'],
  #         ['', '[1]', '[2]', '[3]'],
  #         ['select[1]', 'input[1]'])
  #
  # which I find jarring, and I can't immediately see the combinations, as
  #
  #     ApproximationsFactory.transpose_build(
  #         "//%s[contains(text()%s, 'Group Id')]/../following-sibling::td/%s",
  #         ['th/label',   '',      'select[1]'],
  #         ['th/div',     '[1]',   'input[1]'],
  #         [nil,          '[2]',   nil],
  #         [nil,          '[3]',   nil])
  #
  # So now we are allowed to pass in our combinations as a visual list of _columns_, rather
  # than as a visual list of _rows_. In order to position things correctly, we need to fill
  # empty cells with `nils`.
  def self.transpose_build(base, *combinations)
    if combinations[0].is_a? Array and combinations[0][0].is_a? Array
      combinations = combinations[0]
    end

    build(base, combinations.transpose.map(&:compact))
  end

  private
  def self.interpolate_each(base, choices)
    replaceables = base.scan(/%s/).size
    results = []
    choices.each do |choice|
      choice = [choice] + ['%s'] * (replaceables-1)
      results << base % choice
    end

    #puts "interpolate_each(#{base}, #{choices}) returning #{results}"
    return results
  end
end
