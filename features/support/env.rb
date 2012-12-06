require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'kaikifs')
#require File.join(File.dirname(__FILE__), 'english_numbers')
require 'rspec'
require 'highline/import'
require 'active_support/inflector'
require 'yaml'

class KaikiFSWorld
  username   = ENV['KAIKI_NETID']
  password   = ENV['KAIKI_PASSWORD']
  env        = ENV['KAIKI_ENV']
  env.split(',') if env
  #if File.exist? SHARED_PASSWORDS_FILE
  #  shared_passwords = File.open(SHARED_PASSWORDS_FILE) { |h| YAML::load_file(h) }
  #  #puts shared_passwords
  #  if password.nil? and username and shared_passwords.keys.any? { |user| username[user] }
  #    user_group = shared_passwords.keys.select { |user| username[user] }[0]
  #    password = shared_passwords[user_group]
  #  end
  #end
  if password.nil? && username
    password = KaikiFS::CapybaraDriver::Base.shared_password_for username  if password.nil? && username
  end
  username ||=       ask("NetID:  ")           { |q| q.echo = true }
  password ||=       ask("Password:  ")        { |q| q.echo = "*" }
  env      ||= [] << ask("Environment/URL:  ") { |q| q.echo = true; q.default='dev' }

  is_headless = true
  if ENV['KAIKI_IS_HEADLESS']
    is_headless = ENV['KAIKI_IS_HEADLESS'] =~ /1|true|yes/i
  end

  firefox_profile = ENV['KAIKI_FIREFOX_PROFILE']
  firefox_path    = ENV['KAIKI_FIREFOX_PATH']
  @@kaikifs = KaikiFS::CapybaraDriver::KFS.new(username, password, :envs => env, :is_headless => is_headless, :firefox_profile => firefox_profile, :firefox_path => firefox_path)
  @@kaikifs.mk_screenshot_dir(File.join(Dir::pwd, 'features', 'screenshots'))
  @@kaikifs.start_session
  @@kaikifs.maximize_ish
  @@kaikifs.login_via_webauth

  @@kaikifs.record[:document_number] = ENV['KAIKI_DOC_NUMBER']  if ENV['KAIKI_DOC_NUMBER']
  @@kaikifs.record[:document_numbers] = ENV['KAIKI_DOC_NUMBERS'].split(',')  if ENV['KAIKI_DOC_NUMBERS']

  at_exit do
    # This quit has been commented out, because Capybara does it itself, in an at_exit:
    # /home/sam/.rvm/gems/ruby-1.9.3-p125/gems/capybara-1.1.2/lib/capybara/selenium/driver.rb:21
    # This is an open bug, unrelated to [#763](https://github.com/jnicklas/capybara/issues/763).
    #@@kaikifs.quit
    @@kaikifs.headless.destroy if is_headless
  end

  def kaikifs; @@kaikifs; end
end

World do
  KaikiFSWorld.new
end

After do |scenario|
  if scenario.failed?
    kaikifs.screenshot(scenario.file_colon_line.file_safe + '_' + Time.now.strftime("%Y%m%d%H%M%S"))
  end
end

Before do
  kaikifs.headless.video.start_capture if kaikifs.is_headless
end

After do |scenario|
#  if scenario.failed?
    kaikifs.headless.video.stop_and_save(video_path(scenario)) if kaikifs.is_headless
#  else
#    headless.video.stop_and_discard
#  end
end

def video_path(scenario)
  #f=File.new('tmp.txt', 'w')
  #f.puts scenario.instance_variables.sort
  #f.puts scenario.methods.sort
  #f.puts scenario.file_colon_line
  #f.close
  #"features/videos/#{scenario.file_colon_line.split(':')[0]}.mov"
  #basename = File.basename(scenario.file_colon_line.split(':')[0])
  basename = File.basename(scenario.file_colon_line)
  if basename =~ /^(.+):(\d+)$/
    basename = "#{$1}__%04d" % $2.to_i
  end
  File.join(Dir::pwd, 'features', 'videos', basename+".mov")
end
