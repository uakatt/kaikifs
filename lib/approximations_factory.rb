class ApproximationsFactory
  def self.build(base, *combinations)
    raise ArgumentError unless combinations.is_a? Array

    if combinations.size == 1
      # Something like ['Sam']
      # Something like ['Hello', 'Sam']
      return [base % combinations] if combinations[0].is_a? String
    end


  end
end
