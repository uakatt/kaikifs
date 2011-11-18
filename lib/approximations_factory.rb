class ApproximationsFactory
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

  def self.transpose_build(base, *combinations)
    if combinations[0].is_a? Array and combinations[0][0].is_a? Array
      combinations = combinations[0]
    end

    build(base, combinations.transpose.map(&:compact))
  end

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
