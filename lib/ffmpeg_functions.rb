module FFMpegFunctions
  def self.transcode(file_name, new_file_name, options='')
    `ffmpeg -i #{file_name} #{options} #{new_file_name}`  # qscale:v 1, etc ???
  end

  def self.concatenate(new_file_name, *file_names)
    `cat #{file_names.join(' ')} > #{new_file_name}`
  end
end
