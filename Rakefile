require 'rake/clean'
require 'cucumber'
require 'cucumber/rake/task'

# Getting a weird warning about CLEAN...
#CLEAN = FileList['features/logs/*']

# Rake stuff needs to be non-interactive. So we'll set the things that will make it non-interactive.
def set_env_defaults
  ENV['KAIKI_NETID'] = "kfs-test-sec1" if ENV['KAIKI_NETID'].nil?
  ENV['KAIKI_ENV']   = "dev"           if ENV['KAIKI_ENV'].nil?
end


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

Cucumber::Rake::Task.new(:features) do |t|
  set_env_defaults
  t.cucumber_opts = "--format pretty --tags ~@cucumber_example --tags ~@incomplete --tags ~@not_a_test"
end


Cucumber::Rake::Task.new(:ci_features) do |t|
  set_env_defaults
  t.cucumber_opts = "--format progress --tags ~@cucumber_example --tags ~@incomplete --tags ~@not_a_test"
end


task :feature, :name do |t, args|
  set_env_defaults
  feature = `find features ! -path "*/example_syntax/*" -name "*#{args[:name]}*.feature"`
  break if feature.empty?
  feature = feature.split(/\n/).first

  Cucumber::Rake::Task.new(:cuke_feature, "Run a single feature") do |t|
    t.cucumber_opts = "--format pretty #{feature} -s -r features"
  end

  Rake::Task["cuke_feature"].invoke
end


task :scenario, :name, :line do |t, args|
  set_env_defaults
  feature = `find features ! -path "*/example_syntax/*" -name "*#{args[:name]}*.feature"`
  break if feature.empty?
  feature = feature.split(/\n/).first
  line = args[:line]

  Cucumber::Rake::Task.new(:cuke_feature, "Run a single scenario") do |t|
    t.cucumber_opts = "--format pretty #{feature}:#{line} -s -r features"
  end

  Rake::Task["cuke_feature"].invoke
end

