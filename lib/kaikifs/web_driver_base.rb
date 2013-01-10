require "rubygems"
require "selenium-webdriver"
require "open-uri"
require "nokogiri"
require "log4r"
begin
  require "chunky_png"
rescue
end
require "base64"

module KaikiFS
end

module KaikiFS::WebDriver
end

class KaikiFS::WebDriver::Base
  include Log4r
  attr_reader :driver, :env, :username, :screenshot_dir, :log
  attr_accessor :headless, :is_headless, :pause_time, :record

  # The basename of the json file that contains all environment information
  ENVS_FILE = "envs.json"

  # The default timeout for Waits
  DEFAULT_TIMEOUT = 8

  # The default dimensions for the headless display
  DEFAULT_DIMENSIONS = "1024x768x24"

  # The pair of selectors that will identify the Main Menu link to `find_element`
  MAIN_MENU_LINK = [:link_text, 'Main Menu']

  # I think just a more attractive form of this constant?
  def main_menu_link; MAIN_MENU_LINK; end

  extend Forwardable
  def_delegators :@driver, :close, :current_url, :execute_script, :page_source, :quit, :switch_to,
                           :window_handle, :window_handles

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


    @threads = []
    @record = {}  # record is a hash containing notes that the "user" needs to keep, like the document number he just created.

    @stderr_log = File.join(Dir::pwd, 'features', 'stderr', Time.now.strftime("%Y.%m.%d-%H.%M.%S"))  # This was largely (entirely?) for Selenium 1...
    @log = Logger.new 'debug_log'
    file_outputter = FileOutputter.new 'file', :filename => File.join(Dir::pwd, 'features', 'logs', Time.now.strftime("%Y.%m.%d-%H.%M.%S"))
    @log.outputters = file_outputter
    @log.level = DEBUG
  end


  # An extrnsion of Selenium::WebDriver's find_element. It receives the same `method` and `selector`
  # arguments, and receives a third, optional argument: an options hash.
  #
  # By default, it will pass `method` and `selector` on to Selenium::WebDriver's
  # `find_element`, retrying 4 more times whenever Selenium::WebDriver throws an
  # `InvalidSelectorError`. By default, it will raise if a `NoSuchElementError`, or a
  # `TimeOutError` is raised. If you pass in `:no_raise => true`, then it will return `nil` on
  # these exceptions, rather than retry or raise.
  def find_element(method, selector, options={})
    retries = 4

    sleep 0.1  # based on http://groups.google.com/group/ruby-capybara/browse_thread/thread/5e182835a8293def fixes "NS_ERROR_ILLEGAL_VALUE"
    begin
      @driver.find_element(method, selector)
    rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeOutError => e
      return nil if options[:no_raise]
      raise e
    rescue Selenium::WebDriver::Error::InvalidSelectorError => e
      raise e if retries == 0
      @log.warn "Caught a Selenium::WebDriver::Error::InvalidSelectorError: #{e}"
      @log.warn "  Retrying..."
      pause 2
      retries -= 1
      retry
    end
  end

  # Switch to the default tab/window/frame, and backdoor login as `user`
  def backdoor_as(user)
    switch_to.default_content
    retries = 2
    begin
      @log.debug "    backdoor_as: Waiting up to #{DEFAULT_TIMEOUT} seconds to find_element(:xpath, \"//*[@name='backdoorId']\")..."
      wait = Selenium::WebDriver::Wait.new(:timeout => DEFAULT_TIMEOUT)
      wait.until { driver.find_element(:xpath, "//*[@name='backdoorId']") }
    rescue Selenium::WebDriver::Error::TimeOutError => error
      raise e if retries == 0
      @log.debug "    backdoor_as: Page is likely boned. Navigating back home..."
      @driver.navigate.to (@envs[@env]['url'] || "https://kf-#{@env}.mosaic.arizona.edu/kfs-#{@env}")
      retries -= 1
      pause
      retry
    end
    set_field("//*[@name='backdoorId']", user)
    @driver.find_element(:css, 'input[value=login]').click
    @driver.switch_to.default_content
    @driver.find_element(*main_menu_link)
  end

  def click_and_wait(method, locator, options = {})
    @log.debug "  Start click_and_wait(#{method.inspect}, #{locator.inspect}, #{options.inspect})"
    timeout = options[:timeout] || DEFAULT_TIMEOUT
    @log.debug "    click_and_wait: Waiting up to #{timeout} seconds to find_element(#{method}, #{locator})..."
    wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
    wait.until { driver.find_element(method, locator) }
    #dont_stdout! do
      @driver.find_element(method, locator).click
    #end
    pause
  end

  def click_approximate_and_wait(locators)
    timeout = DEFAULT_TIMEOUT
    locators.each do |locator|
      begin
        click_and_wait(:xpath, locator, {:timeout => timeout})
        return
      rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeOutError
        timeout = 0.2
        # Try the next selector
      end
    end
    raise Selenium::WebDriver::Error::NoSuchElementError
  end

  # Close all windows that have a current url of "about:blank". Must follow this with a call to
  # `#switch_to, so that you know what window you're on.
  def close_blank_windows
    @driver.window_handles.each do |handle|
      @driver.switch_to.window(handle)
      @driver.close if @driver.current_url == 'about:blank'
    end
  end

  # Enlargens the text of an element, using `method` and `locator`, by changing the `font-size`
  # in the style to be `3em`. It uses the following Javascript:
  #
  #     hlt = function(c) { c.style.fontSize='3em'; }; return hlt(arguments[0]);
  def enlargen(method, locator)
    @log.debug "    enlargen: Waiting up to #{DEFAULT_TIMEOUT} seconds to find_element(#{method}, #{locator})..."
    wait = Selenium::WebDriver::Wait.new(:timeout => DEFAULT_TIMEOUT)
    wait.until { find_element(method, locator) }
    element = find_element(method, locator)
    execute_script("hlt = function(c) { c.style.fontSize='3em'; }; return hlt(arguments[0]);", element)
  end

  def get_xpath(method, locator)
    @log.debug "    wait_for: Waiting up to #{DEFAULT_TIMEOUT} seconds to find_element(#{method}, #{locator})..."
    wait = Selenium::WebDriver::Wait.new(:timeout => DEFAULT_TIMEOUT)
    wait.until { find_element(method, locator) }
    element = find_element(method, locator)
    xpath = execute_script("gPt=function(c){if(c.id!==''){return'id(\"'+c.id+'\")'}if(c===document.body){return c.tagName}var a=0;var e=c.parentNode.childNodes;for(var b=0;b<e.length;b++){var d=e[b];if(d===c){return gPt(c.parentNode)+'/'+c.tagName+'['+(a+1)+']'}if(d.nodeType===1&&d.tagName===c.tagName){a++}}};return gPt(arguments[0]);", element)
    # That line used to end with: return gPt(arguments[0]).toLowerCase();
  end

  def highlight(method, locator, ancestors=0)
    @log.debug "    highlight: Waiting up to #{DEFAULT_TIMEOUT} seconds to find_element(#{method}, #{locator})..."
    wait = Selenium::WebDriver::Wait.new(:timeout => DEFAULT_TIMEOUT)
    wait.until { find_element(method, locator) }
    element = find_element(method, locator)
    execute_script("hlt = function(c) { c.style.border='solid 1px rgb(255, 16, 16)'; }; return hlt(arguments[0]);", element)
    parents = ""
    red = 255

    ancestors.times do
      parents << ".parentNode"
      red -= (12*8 / ancestors)
      execute_script("hlt = function(c) { c#{parents}.style.border='solid 1px rgb(#{red}, 0, 0)'; }; return hlt(arguments[0]);", element)
    end
  end

  # "Maximize" the current window using Selenium's `manage.window.resize_to`. This script
  # does not use the window manager's "maximize" capability, but rather resizes the window.
  # By default, it positions the window 64 pixels below and to the right of the top left
  # corner, and sizes the window to be 128 pixels smaller both vretically and horizontally
  # than the available space.
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

  # Select a frame by its `id`
  def select_frame(id)
    @driver.switch_to().frame(id)
    pause
  end

  # Assume the browser is looking at Kuali, and can click the main_menu_link,
  # in order to trigger a redirect to WebAuth. Then login via WebAuth.
  def login_via_webauth
    login_via_webauth_with @username, @password
  end

  def run_in_envs(envs = @envs)
    envs.each do |env, properties|
      begin
        @env = env
        start_session
        @driver.navigate.to "/kfs-#{@env}/portal.jsp"
        login_via_webauth
        yield
      rescue Selenium::WebDriver::Error::NoSuchElementError => err
        1
      rescue WebauthAuthenticationError
        raise
      rescue StandardError => err
        1
      ensure
        @threads.each { |t| t.join }
        @driver.quit
      end
    end
  rescue WebauthAuthenticationError => err
    1
  end

  def get_approximate_field(selectors)
    timeout = DEFAULT_TIMEOUT
    selectors.each do |selector|
      begin
        return get_field(selector, {:timeout => timeout})
      rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeOutError
        timeout = 0.2
        # Try the next selector
      end
    end

    puts "Failed to get approximate field. Selectors are:\n#{selectors.join("\n") }"
    raise Selenium::WebDriver::Error::NoSuchElementError
  end

  def get_field(selector, options={})
    timeout = options[:timeout] || DEFAULT_TIMEOUT
    @log.debug "    get_field: Waiting up to #{timeout} seconds to find_element(:xpath, #{selector})..."
    wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
    wait.until { driver.find_element(:xpath, selector) }
    element = @driver.find_element(:xpath, selector)
    @driver.execute_script("return document.evaluate(\"#{selector}\", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.value;", nil)
  end

  # Deselect all `<option>s` within a `<select>`, suppressing any `UnsupportedOperationError`
  # that Selenium may throw
  def safe_deselect_all(el)
    el.deselect_all
  rescue Selenium::WebDriver::Error::UnsupportedOperationError
  end

  def set_approximate_field(selectors, value=nil)
    timeout = 2
    selectors.each do |selector|
      begin
        set_field(selector, value)
        return
      rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeOutError
        sleep timeout
        timeout = 0.2
        # Try the next selector
      end
    end

    @log.error "Failed to set approximate field. Selectors are:"
    selectors.each { |s| @log.error "  #{s}" }
    raise Selenium::WebDriver::Error::NoSuchElementError
  end

  def set_field(id, value=nil)
    @log.debug "  Start set_field(#{id.inspect}, #{value.inspect})"
    if id =~ /@value=/  # I am praying I only use value for radio buttons...
      node_name = 'radio'
      locator = id
    elsif id =~ /^\/\// or id =~ /^id\(".+"\)/
      node_name = nil
      #dont_stdout! do
        begin
          node = @driver.find_element(:xpath, id)
          node_name = node.tag_name.downcase
        rescue Selenium::WebDriver::Error::NoSuchElementError
        end
      #end
      locator = id
    elsif id =~ /^.+=.+ .+=.+$/
      node_name = 'radio'
      locator = id
    else
    @log.debug "    set_field: Waiting up to #{DEFAULT_TIMEOUT} seconds to find_element(:id, #{id})..."
      wait = Selenium::WebDriver::Wait.new(:timeout => DEFAULT_TIMEOUT)
      wait.until { driver.find_element(:id, id) }
      node = @driver.find_element(:id, id)
      node_name = node.tag_name.downcase
      locator = "//*[@id='#{id}']"
    end

    case node_name
    when 'input'
      @log.debug "    set_field: node_name is #{node_name.inspect}"
      @log.debug "    set_field: locator is #{locator.inspect}"
      # Make the field empty first
      # REPLACE WITH CLEAR
      if not locator['"']  # @TODO UGLY UGLY workaround for now. If an xpath has double quotes in it... then I can't check if it's empty just yet.
        unless get_field(locator).empty?
          @driver.execute_script("return document.evaluate(\"#{locator}\", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.value = '';", nil)
        end
      else
        @log.warn "  set_field: locator (#{locator.inspect}) has a \" in it, so... I couldn't check if the input was empty. Good luck!"
      end

      @driver.find_element(:xpath, locator).send_keys(value)
    when 'select'
      @log.debug "    set_field: Waiting up to #{DEFAULT_TIMEOUT} seconds to find_element(:xpath, #{locator})..."
      wait = Selenium::WebDriver::Wait.new(:timeout => DEFAULT_TIMEOUT)
      wait.until { driver.find_element(:xpath, locator) }
      select = Selenium::WebDriver::Support::Select.new(@driver.find_element(:xpath, locator))
      safe_deselect_all(select)
      select.select_by(:text, value)
    when 'radio'
      @driver.find_element(:xpath, locator).click
    else
      @driver.find_element(:xpath, locator).send_keys(value)
    end

    pause
  end

  # Start a Selenium session by defining some profile attributes and the
  # Firefox path, starting up Headless if so desired, and navigating to the
  # home page.
  def start_session
    @download_dir = File.join(Dir::pwd, 'features', 'downloads')
    Dir::mkdir(@download_dir) unless Dir::exists? @download_dir

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

    @driver = Selenium::WebDriver.for :firefox, :profile => @profile
    @driver.navigate.to (@envs[@env]['url'] || "https://kf-#{@env}.mosaic.arizona.edu/kfs-#{@env}")
  end

  # Create and execute a `Selenium::WebDriver::Wait` for finding an element by
  # `method` and `selector`
  def wait_for(method, locator)
    @log.debug "    wait_for: Waiting up to #{DEFAULT_TIMEOUT} seconds to find_element(#{method}, #{locator})..."
    sleep 0.1  # based on http://groups.google.com/group/ruby-capybara/browse_thread/thread/5e182835a8293def fixes "NS_ERROR_ILLEGAL_VALUE"
    find(method, locator)
  end
end
