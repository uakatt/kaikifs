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

  attr_accessor :driver, :is_headless

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

  def base_path
    uri = URI.parse url
    uri.path
  end

  def check_by_xpath(xpath)
    find(:xpath, xpath).set(true)
  end

  def uncheck_by_xpath(xpath)
    find(:xpath, xpath).set(false)
  end

  def host
    uri = URI.parse url
    "#{uri.scheme}://#{uri.host}"
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
end
