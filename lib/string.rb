class String
  def file_safe
    downcase.gsub(/\//, '_').gsub(/[^a-z0-9_.]/i, '-')
  end
end
