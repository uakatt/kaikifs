require 'rake/clean'
CLEAN = FileList['features/logs/*']

# Experimental... not sure we'll use this...
task :merge_videos do
  Dir.glob("features/videos/*__*.mov").group_by {|n| n =~ /^(.+)__(\d+)\.mov/; $1 }.each do |prefix,videos|
    final_merged_file = prefix+".mov"
    next if File.exist? final_merged_file

    new_videos = []
    videos.sort.each do |mov|
      new_video = File.change_extension(mov, 'mpg')
      FFMpegFunctions.transcode(mov, new_video, '-qscale 1')
      new_videos << new_video
    end
    FFMpegFunctions.concatenate(prefix+".mpg", new_videos)
    FFMpegFunctions.transcode(  prefix+".mpg", final_merged_file, '-qscale 2')
  end
end
