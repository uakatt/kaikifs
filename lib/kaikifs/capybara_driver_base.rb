require 'base64'
require 'capybara'
require 'capybara/dsl'
require 'json'
require 'log4r'
begin
    require 'chunky_png'
rescue
end
require 'selenium-webdriver'
require 'uri'

module KaikiFS; end

module KaikiFS::CapybaraDriver
end

# For now I'm hoping to do a gradual transition over to Capybara by passing most things through its driver.
class KaikiFS::CapybaraDriver::Base < KaikiFS::WebDriver::Base
  include Log4r
  include Capybara::DSL

  # The basename of the json file that contains all environment information
  ENVS_FILE = "envs.json"

  # The file that contains shared passwords for test users
  SHARED_PASSWORDS_FILE = "shared_passwords.yaml"

  attr_accessor :driver, :is_headless, :puts_method

  def initialize(username, password, options={})
    @username = username
    @password = password

    @standard_envs = JSON.parse(IO.readlines(ENVS_FILE).map{ |l| l.gsub(/[\r\n]/, '') }.join(""))
    @envs = options[:envs] ?
      @standard_envs.select { |k,v| options[:envs].include? k } :
      @standard_envs

    if @envs.empty?
      @envs = {
        options[:envs].first => { "code" => options[:envs].first, "url"  => options[:envs].first }
      }
    end

    if @envs.keys.size == 1
      @env = @envs.keys.first
    end

    @pause_time           = options[:pause_time] || 0.3
    @is_headless          = options[:is_headless]
    @firefox_profile_name = options[:firefox_profile]  # nil means make a new one
    @firefox_path         = options[:firefox_path]


    # record is a hash containing notes that the "user" needs to keep, like the
    # document number he just created.
    @record = {}

    @log = Logger.new 'debug_log'
    file_outputter = FileOutputter.new 'file', :filename => File.join(Dir::pwd, 'features', 'logs', Time.now.strftime("%Y.%m.%d-%H.%M.%S"))
    @log.outputters = file_outputter
    @log.level = DEBUG
  end

  # Switch to the default tab/window/frame, and backdoor login as `user`
  def backdoor_as(user)
    switch_to.default_content
    retries = 2
    begin
      @log.debug "    backdoor_as: Waiting up to #{DEFAULT_TIMEOUT} seconds to find(:name, 'backdoorId')..."
      find(:name, 'backdoorId').set(user)

    rescue Selenium::WebDriver::Error::TimeOutError => error
      raise error if retries == 0
      @log.debug "    backdoor_as: Page is likely boned. Navigating back home..."
      visit base_path
      retries -= 1
      retry
    end
    click_button 'login'
    find_link 'Main Menu'
  end

  def login_as(user)
    if @login_method == :backdoor
      backdoor_as(user)
    else # log out and log back in as user
      logout
      visit base_path
      login_via_webauth_with user
    end
  end

  def logout
    switch_to.default_content
    click_button 'logout'
  end

  def base_path
    uri = URI.parse url
    uri.path
  end

  # Check the field that is expressed with `selectors` (the first one that is found).
  # `selectors` is typically an Array returned by `ApproximationsFactory`, but it could be
  # hand-generated.
  def check_approximate_field(selectors)
    timeout = DEFAULT_TIMEOUT
    selectors.each do |selector|
      begin
        return check_by_xpath(selector)
      rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeOutError, Capybara::ElementNotFound
        timeout = 0.5
        # Try the next selector
      end
    end

    @log.error "Failed to check approximate field. Selectors are:\n#{selectors.join("\n") }"
    raise Selenium::WebDriver::Error::NoSuchElementError
  end

  # Uncheck the field that is expressed with `selectors` (the first one that is found).
  # `selectors` is typically an Array returned by `ApproximationsFactory`, but it could be
  # hand-generated.
  def uncheck_approximate_field(selectors)
    selectors.each do |selector|
      begin
        return uncheck_by_xpath(selector)
      rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeOutError, Capybara::ElementNotFound
        # Try the next selector
      end
    end

    @log.error "Failed to uncheck approximate field. Selectors are:\n#{selectors.join("\n") }"
    raise Selenium::WebDriver::Error::NoSuchElementError
  end

  # Check a field, selecting by xpath
  def check_by_xpath(xpath)
    find(:xpath, xpath).set(true)
  end

  # Uncheck a field, selecting by xpath
  def uncheck_by_xpath(xpath)
    find(:xpath, xpath).set(false)
  end

  # Hide a visual vertical tab inside a document's layout. Accepts the "name" of the
  # tab. Find the name of the tab by looking up the `title` of the `input` that is the
  # close button. The title is everything after the word "close."
  def hide_tab(name)
    find(:xpath, "//input[@title='close #{name}']").click
    pause
  end

  # Show a visual vertical tab inside a document's layout. Accepts the "name" of the
  # tab. Find the name of the tab by looking up the `title` of the `input` that is the
  # open button. The title is everything after the word "open."
  def show_tab(name)
    find(:xpath, "//input[@title='open #{name}']").click
    pause
  end

  # 'host' attribute of {#url}
  def host
    uri = URI.parse url
    "#{uri.scheme}://#{uri.host}"
  end

  # Login via Webauth with a specific username, and optional password. If no
  # password is given, it will be retrieved from the shared passwords file.
  def login_via_webauth_with(username, password=nil)
    password ||= self.class.shared_password_for username
    @driver.find_element(*main_menu_link).click
    sleep 1
    fill_in 'NetID', :with => username
    fill_in 'Password', :with => password
    click_button('LOGIN')
    sleep 1

    # Check if we logged in successfully
    begin
      status = @driver.find_element(:id, 'status')
      if    is_text_present("status") == "You entered an invalid NetID or password."
        raise WebauthAuthenticationError.new
      elsif is_text_present("status") == "Password is a required field."
        raise WebauthAuthenticationError.new
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError
      # keep going
    end

    begin
      expiring_password_link = @driver.find_element(:link_text, "Go there now")
      if expiring_password_link
        expiring_password_link.click
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError
      return
    end
  end

  # "Maximize" the current window using Selenium's `manage.window.resize_to`.
  # This script does not use the window manager's "maximize" capability, but
  # rather resizes the window.  By default, it positions the window 64 pixels
  # below and to the right of the top left corner, and sizes the window to be
  # 128 pixels smaller both vretically and horizontally than the available
  # space.
  def maximize_ish(x = 64, y = 64, w = -128, h = -128)
    if is_headless
      x = 0; y = 0; w = -2; h = -2
    end
    width  = w
    height = h
    width  = "window.screen.availWidth  - #{-w}" if w <= 0
    height = "window.screen.availHeight - #{-h}" if h <= 0
    if is_headless
      @driver.manage.window.position= Selenium::WebDriver::Point.new(0,0)
      max_width, max_height = @driver.execute_script("return [window.screen.availWidth, window.screen.availHeight];")
      @driver.manage.window.resize_to(max_width, max_height)
    else
      @driver.manage.window.position= Selenium::WebDriver::Point.new(40,30)
      max_width, max_height = @driver.execute_script("return [window.screen.availWidth, window.screen.availHeight];")
      @driver.manage.window.resize_to(max_width-90, max_height-100)
    end
    @driver.execute_script %[
      if (window.screen) {
        window.moveTo(#{x}, #{y});
        window.resizeTo(#{width}, #{height});
      };
    ]
  end

  # Set `@screenshot_dir`, and make the screenshot directory if it doesn't exist
  def mk_screenshot_dir(base)
    @screenshot_dir = File.join(base, Time.now.strftime("%Y-%m-%d.%H"))
    return if Dir::exists? @screenshot_dir
    Dir::mkdir(@screenshot_dir)
  end

  # Pause for `@pause_time` by default, or for `time` seconds
  def pause(time = nil)
    @log.debug "  breathing..."
    sleep (time or @pause_time)
  end

  # "Overrides" Cucumbers handling of STDOUT.
  def puts(*args)
    @puts_method.call(*args)
  end

  # Take a screenshot, and save it to `@screenshot_dir` by the name
  # `#{name}.png`
  def screenshot(name)
    # page.save_screenshot SHOULD work... but doesn't appear to be a method.
    @driver.save_screenshot(File.join(@screenshot_dir, "#{name}.png"))
    puts "Screenshot saved to " + File.join(@screenshot_dir, "#{name}.png")
  end

  # Start a browser session by choosing a Firefox profile, setting the Capybara
  # driver, and visiting the #base_path.
  def start_session
    @download_dir = File.join(Dir::pwd, 'features', 'downloads')
    Dir::mkdir(@download_dir) unless Dir::exists? @download_dir
    mk_screenshot_dir(File.join(Dir::pwd, 'features', 'screenshots'))

    if @firefox_profile_name
      @profile = Selenium::WebDriver::Firefox::Profile.from_name @firefox_profile_name
    else
      @profile = Selenium::WebDriver::Firefox::Profile.new
    end
    @profile['browser.download.dir'] = @download_dir
    @profile['browser.download.folderList'] = 2
    @profile['browser.helperApps.neverAsk.saveToDisk'] = "application/pdf"
    @profile['browser.link.open_newwindow'] = 3

    if @firefox_path
      Selenium::WebDriver::Firefox.path = @firefox_path
    end

    if is_headless
      # Possibly later we can use different video capture options...
      #video_capture_options = {:codec => 'mpeg4', :tmp_file_path => "/tmp/.headless_ffmpeg_#{@headless.display}.mp4", :log_file_path => 'foo.log'}
      @headless = Headless.new(:dimensions => DEFAULT_DIMENSIONS)
      @headless.start
    end

    # Setup some basic Capybara settings
    Capybara.run_server = false
    Capybara.app_host = host
    Capybara.default_wait_time = 5

    # Register the Firefox driver that is going to use this profile
    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new(app, :profile => @profile)
    end
    Capybara.current_driver = :selenium

    visit base_path

    @driver = page.driver.browser
  end

  def url
    @envs[@env]['url'] || "https://kf-#{@env}.mosaic.arizona.edu/kfs-#{@env}"
  end

  def config(key)
    key_iv = ('@'+key.to_s).to_sym

    if instance_variable_defined? key_iv
      return instance_variable_get key_iv
    end

    config_file = File.join(File.dirname(__FILE__), '..', '..', 'config', key.to_s + '.yaml')
    config_hash = YAML.load(File.read(config_file))
    instance_variable_set key_iv, config_hash
    return instance_variable_get key_iv
  end

  def user_by_singularized_title(title, account=nil)
    if account.nil?
      account = config(:accounts).values.first
    else
      account = config(:accounts)[account]
    end

    account[title.downcase.gsub(/ +/, '_')] || user_by_singularized_team(title)
  end

  def user_by_title(title, account=nil)
    if account.nil?
      account = config(:accounts).values.first
    else
      account = config(:accounts)[account]
    end

    account[title.downcase.gsub(/ +/, '_')] || user_by_team(title)
  end

  def user_by_singularized_team(team)
    singularized_teams = config(:arizona_teams).keys.map { |e| [e, e.singularize] }
    team_key = singularized_teams.select { |p,s| s == team.downcase.gsub(/ /, '_') }

    if team_key.size > 0
      config(:arizona_teams)[team_key.first.first]['user']
    else
      nil
    end
  end

  def user_by_team(team)
    config(:arizona_teams)[team.downcase.gsub(/ +/, '_')]['user']
  end

  def self.shared_password_for(username)
    return nil if not File.exist? SHARED_PASSWORDS_FILE

    shared_passwords = File.open(SHARED_PASSWORDS_FILE) { |h| YAML::load_file(h) }
    #puts shared_passwords
    if shared_passwords.keys.any? { |user| username[user] }
      user_group = shared_passwords.keys.select { |user| username[user] }[0]
      return shared_passwords[user_group]
    end
    nil
  end
end
