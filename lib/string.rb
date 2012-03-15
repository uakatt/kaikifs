class String
  # Do the following in order to make this String safe to use as a filename:
  #
  # * downcase it
  # * change all forward slashes into underscores
  # * change all nonalphanumeriunderscoreperiodic characters to hyphens (`/[^a-z0-9_.]/`)
  def file_safe
    downcase.gsub(/\//, '_').gsub(/[^a-z0-9_.]/i, '-')
  end
end
