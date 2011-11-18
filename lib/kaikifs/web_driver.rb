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

class KaikiFS::WebDriver
  include Log4r
  attr_reader :driver, :env, :username, :screenshot_dir, :log
  attr_accessor :pause, :record
  ENVS_FILE = "envs.json"
  extend Forwardable
  def_delegators :@driver, :execute_script, :quit, :switch_to

  def initialize(username, password, options={})
    @username = username
    @password = password

    @standard_envs = JSON.parse(IO.readlines(ENVS_FILE).map{ |l| l.gsub(/[\r\n]/, '') }.join(""))
    @envs = options[:envs] ?
      @standard_envs.select { |k,v| options[:envs].include? k } :
      @standard_envs

    if @envs.keys.size == 1
      @env = @envs.keys.first
    end

    @pause = options[:pause] || 0.3


    @threads = []
    @record = {}  # record is a hash containing notes that the "user" needs to keep, like the document number he just created.

    @stderr_log =            File.join(Dir::pwd, 'features', 'stderr', Time.now.strftime("%Y.%m.%d-%H.%M.%S"))  # This was largely (entirely?) for Selenium 1...
    @log        = Logger.new 'debug_log'
    file_outputter = FileOutputter.new 'file', :filename => File.join(Dir::pwd, 'features', 'logs',   Time.now.strftime("%Y.%m.%d-%H.%M.%S"))
    @log.outputters = file_outputter
    @log.level = DEBUG
  end


  ##### THIN WRAPPERS
  def find_element(method, selector, options={})
    sleep 0.1  # based on http://groups.google.com/group/ruby-capybara/browse_thread/thread/5e182835a8293def fixes "NS_ERROR_ILLEGAL_VALUE"
    begin
      @driver.find_element(method, selector)
    rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeOutError => e
      return nil if options[:no_raise]
      raise e
    end
  end

  def hide_tab(name)
    wait = Selenium::WebDriver::Wait.new(:timeout => 8)
    wait.until { driver.find_element(:xpath, "//input[@title='close #{name}']") }
    @driver.find_element(:xpath, "//input[@title='close #{name}']").click
  end

  def show_tab(name)
    wait = Selenium::WebDriver::Wait.new(:timeout => 8)
    wait.until { driver.find_element(:xpath, "//input[@title='open #{name}']") }
    @driver.find_element(:xpath, "//input[@title='open #{name}']").click
  end

  def show_complicated_tab(name)
    wait = Selenium::WebDriver::Wait.new(:timeout => 8)
    wait.until { driver.find_element(:xpath, "//input[@title='open #{name}']") }
    @driver.find_element(:xpath, "//input[@title='open #{name}']").click
  end

  def backdoor_as(user)
    switch_to.default_content
    wait = Selenium::WebDriver::Wait.new(:timeout => 8)
    wait.until { driver.find_element(:xpath, "//*[@name='backdoorId']") }
    set_field("//*[@name='backdoorId']", user)
    @driver.find_element(:css, 'input[value=login]').click
    @driver.switch_to.default_content
    @driver.find_element(:link_text, 'Main Menu')  # 'main_menu' #=> 'Main Menu'
  end

  def check_approximate_field(selectors)
    selectors.each do |selector|
      begin
        return check(:xpath, selector)
      rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeOutError
        # Try the next selector
      end
    end

    puts "Failed to check approximate field. Selectors are:\n#{selectors.join("\n") }"
    raise Selenium::WebDriver::Error::NoSuchElementError
  end

  def uncheck_approximate_field(selectors)
    selectors.each do |selector|
      begin
        return uncheck(:xpath, selector)
      rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeOutError
        # Try the next selector
      end
    end

    puts "Failed to uncheck approximate field. Selectors are:\n#{selectors.join("\n") }"
    raise Selenium::WebDriver::Error::NoSuchElementError
  end

  def check(method, locator)
    wait = Selenium::WebDriver::Wait.new(:timeout => 8)
    wait.until { driver.find_element(method, locator) }
    element = driver.find_element(method, locator)
    element.click unless element.selected?
  end

  def uncheck(method, locator)
    wait = Selenium::WebDriver::Wait.new(:timeout => 8)
    wait.until { driver.find_element(method, locator) }
    element = driver.find_element(method, locator)
    element.click if element.selected?
  end

  def click_and_wait(method, locator, options = {})
    timeout = options[:timeout] || 8
    wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
    wait.until { driver.find_element(method, locator) }
    dont_stdout! do
      @driver.find_element(method, locator).click
    end
    sleep @pause
  end

  def click_approximate_and_wait(locators)
    timeout = 8
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

  def dont_stdout!
    orig_stdout = $stdout
    $stdout = File.open(@stderr_log, 'a')  # redirect stdout to /dev/null
    yield if block_given?
    $stdout = orig_stdout  # restore stdout
  end

  def get_xpath(method, locator)
    wait = Selenium::WebDriver::Wait.new(:timeout => 8)
    wait.until { find_element(method, locator) }
    element = find_element(method, locator)
    xpath = execute_script("gPt=function(c){if(c.id!==''){return'id(\"'+c.id+'\")'}if(c===document.body){return c.tagName}var a=0;var e=c.parentNode.childNodes;for(var b=0;b<e.length;b++){var d=e[b];if(d===c){return gPt(c.parentNode)+'/'+c.tagName+'['+(a+1)+']'}if(d.nodeType===1&&d.tagName===c.tagName){a++}}};return gPt(arguments[0]);", element)
    # That line used to end with: return gPt(arguments[0]).toLowerCase();
  end

  def highlight(method, locator, ancestors=0)
    wait = Selenium::WebDriver::Wait.new(:timeout => 8)
    wait.until { find_element(method, locator) }
    element = find_element(method, locator)
    execute_script("hlt = function(c) { c.style.border='solid 1px red'; }; return hlt(arguments[0]);", element)
    parents = ""
    red = 255

    ancestors.times do
      parents << ".parentNode"
      red -= (15*8 / ancestors)
      execute_script("hlt = function(c) { c#{parents}.style.border='solid 1px rgb(#{red}, 0, 0)'; }; return hlt(arguments[0]);", element)
    end
  end

  def enlargen(method, locator)
    wait = Selenium::WebDriver::Wait.new(:timeout => 8)
    wait.until { find_element(method, locator) }
    element = find_element(method, locator)
    execute_script("hlt = function(c) { c.style.fontSize='3em'; }; return hlt(arguments[0]);", element)
  end

  def is_text_present(text, xpath='//*')
    begin
      @driver.find_element(:xpath, "#{xpath}[contains(text(),'"+text+"')]")
      true
    rescue Selenium::WebDriver::Error::NoSuchElementError
      puts "Could not find: @driver.find_element(:xpath, \"#{xpath}[contains(text(),'"+text+"')]\")"
      puts @driver.find_element(:xpath, xpath).inspect
      false
    end
  end

  def maximize_ish(x = 64, y = 64, w = -128, h = -128)
    width  = w
    height = h
    width  = "window.screen.availWidth  - #{-w}" if w <= 0
    height = "window.screen.availHeight - #{-h}" if h <= 0
    @driver.execute_script %[
      if (window.screen) {
        window.moveTo(#{x}, #{y});
        window.resizeTo(#{width}, #{height});
      };
    ]
  end

  def mk_screenshot_dir(base)
    @screenshot_dir = File.join(base, Time.now.strftime("%Y-%m-%d.%H"))
    return if Dir::exists? @screenshot_dir
    Dir::mkdir(@screenshot_dir)
  end

  def select_frame(id)
    @driver.switch_to().frame(id)
  end

  def record_kfs_version
    @driver.find_element(:id, "build").text =~ /(3.0-(?:\d+)) \(Oracle9i\)/
    kfs_version = "%-7s" % $1
    #@driver.save_screenshot("#{@screen_shot_dir}/main_#{@env}.png")
    begin
      ChunkyPNG  # will raise if library not included, fail back to normal screenshot in the 'rescue'
      screen_string_in_base64 = @driver.screenshot_as(:base64)
      @threads << Thread.new do
        screen_string = Base64.decode64(screen_string_in_base64)
        png_canvas = ChunkyPNG::Canvas.from_string(screen_string)
        png_canvas = png_canvas.crop 0, 0, 900, 240
        png_canvas = png_canvas.resample 450, 120
        png_canvas.to_image.save("public/images/cropped_#{@env}.png", :fast_rgba)
      end
    rescue NameError
      #@driver.save_screenshot("#{@screen_shot_dir}/cropped_#{@env}.png")
    end
  end

  def screenshot(name)
      @driver.save_screenshot(File.join(@screenshot_dir, "#{name}.png"))
  end

  def login_via_webauth
    @driver.find_element(:link_text, 'Main Menu').click
    sleep 1
    @driver.find_element(:id, 'username').send_keys(@username)
    @driver.find_element(:id, 'password').send_keys(@password)
    @driver.find_element(:css, '#fm1 .btn-submit').click
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
      return
    end
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
    timeout = 8
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
    timeout = options[:timeout] || 8
    wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
    wait.until { driver.find_element(:xpath, selector) }
    element = @driver.find_element(:xpath, selector)
    @driver.execute_script("return document.evaluate(\"#{selector}\", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.value;", nil)
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

    puts "Failed to set approximate field. Selectors are:\n#{selectors.join("\n") }"
    raise Selenium::WebDriver::Error::NoSuchElementError
  end

  def set_field(id, value=nil)
    @log.debug "Start: set_field(#{id.inspect}, #{value.inspect})"
    if id =~ /@value=/  # I am praying I only use value for radio buttons...
      node_name = 'radio'
      locator = id
    elsif id =~ /^\/\// or id =~ /^id\(".+"\)/
      node_name = nil
      dont_stdout! do
        begin
          node = @driver.find_element(:xpath, id)
          node_name = node.tag_name.downcase
        rescue Selenium::WebDriver::Error::NoSuchElementError
        end
      end
      locator = id
    elsif id =~ /^.+=.+ .+=.+$/
      node_name = 'radio'
      locator = id
    else
      wait = Selenium::WebDriver::Wait.new(:timeout => 10)
      wait.until { driver.find_element(:id, id) }
      node = @driver.find_element(:id, id)
      node_name = node.tag_name.downcase
      locator = "//*[@id='#{id}']"
    end

    case node_name
    when 'input'
      @log.debug "  set_field: node_name is #{node_name.inspect}"
      @log.debug "  set_field: locator is #{locator.inspect}"
      # Make the field empty first
      if not locator['"']  # @TODO UGLY UGLY workaround for now. If an xpath has double quotes in it... then I can't check if it's empty just yet.
        unless get_field(locator).empty?
          @driver.execute_script("return document.evaluate(\"#{locator}\", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.value = '';", nil)
        end
      else
        @log.warn "  set_field: locator (#{locator.inspect}) has a \" in it, so... I couldn't check if the input was empty. Good luck!"
      end

      @driver.find_element(:xpath, locator).send_keys(value)
    when 'select'
      wait = Selenium::WebDriver::Wait.new(:timeout => 10)
      wait.until { driver.find_element(:xpath, locator) }
      select = @driver.find_element(:xpath, locator)
      select.click
      sleep @pause

      option = select.find_elements( :tag_name => 'option' ).find do |option|
          option.text == value
      end
      if option.nil?
        puts "Error: Could not find an <option> with text: '#{value}'"
        raise Selenium::WebDriver::Error::NoSuchElementError
      end
      option.click
    when 'radio'
      @driver.find_element(:xpath, locator).click
    else
      @driver.find_element(:xpath, locator).send_keys(value)
    end

    sleep @pause
  end

  def start_session
    @download_dir = File.join(Dir::pwd, 'features', 'downloads')
    Dir::mkdir(@download_dir) unless Dir::exists? @download_dir

    @profile = Selenium::WebDriver::Firefox::Profile.new
    @profile['browser.download.dir'] = @download_dir
    @profile['browser.download.folderList'] = 2
    @profile['browser.helperApps.neverAsk.saveToDisk'] = "application/pdf"
    @profile['browser.link.open_newwindow'] = 3

    @driver = Selenium::WebDriver.for :firefox, :profile => @profile
    #@driver.manage.timeouts.implicit_wait = 3
    @driver.navigate.to (@envs[@env]['url'] || "https://kf-#{@env}.mosaic.arizona.edu/kfs-#{@env}")
  end

  def wait_for(method, locator)
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    sleep 0.1  # based on http://groups.google.com/group/ruby-capybara/browse_thread/thread/5e182835a8293def fixes "NS_ERROR_ILLEGAL_VALUE"
    wait.until { driver.find_element(method, locator) }
  end
end
