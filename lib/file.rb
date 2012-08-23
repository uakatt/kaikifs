class File
  def self.change_extension(file_name, new_extension)
    if file_name =~ /^(.+)\.(.+)$/
      "#{$1}.#{new_extension}"
    else
      "#{file_name}.#{new_extension}"
    end
  end
end
