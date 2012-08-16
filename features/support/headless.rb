if ! ENV['BUILD_NUMBER'].nil?
  require 'headless'

  #headless = Headless.new(:display => SERVER_PORT)
  headless = Headless.new(:display => 99)
  headless.start

  at_exit do
    headless.destroy
  end

  Before do
    headless.video.start_capture
  end

  After do |scenario|
    if scenario.failed?
      puts "Failed i guess"
      headless.video.stop_and_save(video_path(scenario))
    else
      puts "Succeeded maybe"
      headless.video.stop_and_discard
    end
  end

  def video_path(scenario)
    puts "#{scenario.name.split.join("_")}.mov"
    "#{scenario.name.split.join("_")}.mov"
  end
end
