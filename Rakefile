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

# This sets up the 'features' task. Use as:
#
#     rake features
#
# This will run all feature files in the features/ directory, according to the
# tag rules: anything that is NOT a cucumber_example, and NOT incomplete, and
# NOT not_a_test.
Cucumber::Rake::Task.new(:features) do |t|
  set_env_defaults
  t.cucumber_opts = "--format pretty --tags ~@cucumber_example --tags ~@incomplete --tags ~@not_a_test"
end


# This sets up the 'ci_features' task. Use as:
#
#     rake ci_features
#
# This will run all feature files in the features/ directory, according to the
# tag rules: anything that is NOT a cucumber_example, and NOT incomplete, and
# NOT not_a_test. It uses `--format progress` so that it looks better in
# Jenkins.
Cucumber::Rake::Task.new(:ci_features) do |t|
  set_env_defaults
  t.cucumber_opts = "--format progress --tags ~@cucumber_example --tags ~@incomplete --tags ~@not_a_test"
end


# This sets up the 'feature' task. Use as:
#
#     rake feature[KFSI-1021]
#
# This will run a single feature that matches the substring supplied. To test
# what features will match, you can run:
#
#     find features ! -path "*/example_syntax/*" ! -path "*/ceremonies/*" -name "*KFSI-1021*.feature"
task :feature, :name do |t, args|
  set_env_defaults
  feature = `find features ! -path "*/example_syntax/*" ! -path "*/ceremonies/*" -name "*#{args[:name]}*.feature"`
  break if feature.empty?
  feature = feature.split(/\n/).first

  Cucumber::Rake::Task.new(:cuke_feature, "Run a single feature") do |t|
    t.cucumber_opts = "--format pretty #{feature} -s -r features"
  end

  Rake::Task["cuke_feature"].invoke
end


# This sets up the 'scenario' task. Use as:
#
#     rake scenario[KFSI-1021,7]
#
# This will run a single scenario that matches the substring and line number
# supplied. To test what features will match, you can run:
#
#     find features ! -path "*/example_syntax/*" ! -path "*/ceremonies/*" -name "*KFSI-1021*.feature"
task :scenario, :name, :line do |t, args|
  set_env_defaults
  feature = `find features ! -path "*/example_syntax/*" ! -path "*/ceremonies/*" -name "*#{args[:name]}*.feature"`
  break if feature.empty?
  feature = feature.split(/\n/).first
  line = args[:line]

  Cucumber::Rake::Task.new(:cuke_feature, "Run a single scenario") do |t|
    t.cucumber_opts = "--format pretty #{feature}:#{line} -s -r features"
  end

  Rake::Task["cuke_feature"].invoke
end

# same as scenario, but only looking in ceremonies folder
task :ceremony, :name, :line do |t, args|
  set_env_defaults
  feature = `find features/ceremonies -name "*#{args[:name]}*.feature"`
  break if feature.empty?
  feature = feature.split(/\n/).first
  line = args[:line]

  Cucumber::Rake::Task.new(:cuke_feature, "Run a single scenario") do |t|
    t.cucumber_opts = "--format pretty #{feature}:#{line} -s -r features"
  end

  Rake::Task["cuke_feature"].invoke
end

# This sets up the 'vet_feature' task. Use as:
#
#     rake vet_feature[KFSI-1021]
#
# This will run a single feature that matches the substring supplied, ten
# times. To test what features will match, you can run:
#
#     find features ! -path "*/example_syntax/*" ! -path "*/ceremonies/*" -name "*KFSI-1021*.feature"
task :vet_feature, :name do |t, args|
  set_env_defaults
  feature = `find features ! -path "*/example_syntax/*" -name "*#{args[:name]}*.feature"`
  break if feature.empty?
  feature = feature.split(/\n/).first

  Cucumber::Rake::Task.new(:cuke_feature, "Run a single feature") do |t|
    t.cucumber_opts = "--format pretty #{feature} -s -r features"
  end

  10.times do
    Rake::Task["cuke_feature"].reenable
    Rake::Task["cuke_feature"].invoke
  end
end


# This sets up the 'vet' task. Use as:
#
#     rake vet[KFSI-1021,7]
#
# This will run a single scenario that matches the substring and line number
# supplied, ten times. To test what features will match, you can run:
#
#     find features ! -path "*/example_syntax/*" ! -path "*/ceremonies/*" -name "*KFSI-1021*.feature"
task :vet, :name, :line do |t, args|
  set_env_defaults
  feature = `find features ! -path "*/example_syntax/*" -name "*#{args[:name]}*.feature"`
  break if feature.empty?
  feature = feature.split(/\n/).first
  line = args[:line]

  Cucumber::Rake::Task.new(:cuke_scenario, "Run a single scenario") do |t|
    t.cucumber_opts = "--format pretty #{feature}:#{line} -s -r features"
  end

  10.times do
    Rake::Task["cuke_scenario"].reenable
    Rake::Task["cuke_scenario"].invoke
  end
end
