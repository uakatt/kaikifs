require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'kaikifs')
#require File.join(File.dirname(__FILE__), 'english_numbers')
require 'rspec'
require 'highline/import'
require 'active_support/inflector'
require 'yaml'

class KaikiFSWorld
  SHARED_PASSWORDS_FILE = "shared_passwords.yaml"
  username   = ENV['KAIKI_NETID']
  password   = ENV['KAIKI_PASSWORD']
  env        = ENV['KAIKI_ENV']
  env.split(',') if env
  if File.exist? SHARED_PASSWORDS_FILE
    shared_passwords = File.open(SHARED_PASSWORDS_FILE) { |h| YAML::load_file(h) }
    puts shared_passwords
    if password.nil? and username and shared_passwords.keys.any? { |user| username[user] }
      user_group = shared_passwords.keys.select { |user| username[user] }[0]
      password = shared_passwords[user_group]
    end
  end
  username ||= ask("NetID:  ")    { |q| q.echo = true }
  password ||= ask("Password:  ") { |q| q.echo = "*" }
  env ||= [] << ask("Environment/URL:  ") { |q| q.echo = true; q.default='dev' }

  is_headless = true
  if ENV['KAIKI_IS_HEADLESS']
    is_headless = ENV['KAIKI_IS_HEADLESS'] =~ /1|true|yes/i
  end

  firefox_profile = ENV['KAIKI_FIREFOX_PROFILE']
  firefox_path    = ENV['KAIKI_FIREFOX_PATH']
  @@kaikifs = KaikiFS::WebDriver::KFS.new(username, password, :envs => env, :is_headless => is_headless, :firefox_profile => firefox_profile, :firefox_path => firefox_path)
  @@kaikifs.mk_screenshot_dir(File.join(Dir::pwd, 'features', 'screenshots'))
  @@kaikifs.start_session
  @@kaikifs.maximize_ish
  @@kaikifs.login_via_webauth

  @@kaikifs.record[:document_number] = ENV['KAIKI_DOC_NUMBER']  if ENV['KAIKI_DOC_NUMBER']
  @@kaikifs.record[:document_numbers] = ENV['KAIKI_DOC_NUMBERS'].split(',')  if ENV['KAIKI_DOC_NUMBERS']

  at_exit do
    @@kaikifs.quit
    @@kaikifs.headless.destroy if is_headless
  end

  def kaikifs; @@kaikifs; end
end

World do
  KaikiFSWorld.new
end

After do |scenario|
  #puts scenario.instance_variables.sort
  #puts scenario.methods.sort
  #puts scenario.file_colon_line
  if scenario.failed?
    kaikifs.screenshot(scenario.file_colon_line.file_safe + '_' + Time.now.strftime("%Y%m%d%H%M%S"))
  end
end
