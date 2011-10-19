require "rubygems"
require "selenium-webdriver"
require "open-uri"
require "nokogiri"
begin
  require "chunky_png"
rescue
end
require "base64"

module KaikiFS
end

class KaikiFS::WebDriver
  attr_reader :driver, :env, :username, :screenshot_dir
  attr_accessor :pause, :record
  ENVS_FILE = "envs.json"
  extend Forwardable
  def_delegators :@driver, :find_element, :quit, :switch_to

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

    @pause = options[:pause] || 0.5


    @threads = []
    @record = {}  # record is a hash containing notes that the "user" needs to keep, like the document number he just created.

    @stderr_log = File.join(Dir::pwd, 'features', 'stderr', Time.now.strftime("%Y.%m.%d-%H.%M.%S"))
  end


  ##### THIN WRAPPERS
  def hide_tab(name)
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until { driver.find_element(:xpath, "//input[@title='close #{name}']") }
    @driver.find_element(:xpath, "//input[@title='close #{name}']").click
  end

  def show_tab(name)
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until { driver.find_element(:xpath, "//input[@title='open #{name}']") }
    @driver.find_element(:xpath, "//input[@title='open #{name}']").click
  end


  def backdoor_as(user)
    switch_to.default_content
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until { driver.find_element(:xpath, "//*[@name='backdoorId']") }
    set_field("//*[@name='backdoorId']", user)
    @driver.find_element(:css, 'input[value=login]').click
    @driver.switch_to.default_content
    @driver.find_element(:link_text, 'Main Menu')  # 'main_menu' #=> 'Main Menu'
  end

  def check(method, locator)
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until { driver.find_element(method, locator) }
    element = driver.find_element(method, locator)
    element.click unless element.selected?
  end

  def uncheck(method, locator)
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until { driver.find_element(method, locator) }
    element = driver.find_element(method, locator)
    element.click if element.selected?
  end

  def click_and_wait(method, locator, options = {})
    timeout = options[:timeout] || 10
    wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
    wait.until { driver.find_element(method, locator) }
    dont_stdout! do
      @driver.find_element(method, locator).click
    end
    sleep @pause
  end

  def click_approximate_and_wait(locators)
    timeout = 10
    locators.each do |locator|
      begin
        click_and_wait(:xpath, locator, {:timeout => timeout})
        return
      rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeOutError
        timeout = 2
        # Try the next selector
      end
    end
    raise Selenium::WebDriver::Error::NoSuchElementError
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

  def mk_screenshot_dir(base)
    @screenshot_dir = File.join(base, Time.now.strftime("%Y-%m-%d.%H"))
    return if Dir::exists? @screenshot_dir
    Dir::mkdir(@screenshot_dir)
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

  def set_approximate_field(selectors, value=nil)
    selectors.each do |selector|
      begin
        set_field(selector, value)
        return
      rescue Selenium::WebDriver::Error::NoSuchElementError
        # Try the next selector
      end
    end
    raise Selenium::WebDriver::Error::NoSuchElementError
  end

  def set_field(id, value=nil)
    if id =~ /@value=/  # I am praying I only use value for radio buttons...
      node_name = 'radio'
      locator = id
    elsif id =~ /^\/\//
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
      option.click
    when 'radio'
      @driver.find_element(:xpath, locator).click
    else
      @driver.find_element(:xpath, locator).send_keys(value)
    end

    sleep @pause
  end

  def dont_stdout!
    orig_stdout = $stdout
    $stdout = File.open(@stderr_log, 'a')  # redirect stdout to /dev/null
    yield if block_given?
    $stdout = orig_stdout  # restore stdout
  end

  def start_session
    @driver = Selenium::WebDriver.for :firefox
    #@driver.manage.timeouts.implicit_wait = 3
    @driver.navigate.to (@envs[@env]['url'] || "https://kf-#{@env}.mosaic.arizona.edu/kfs-#{@env}")
  end

  def wait_for(method, locator)
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until { driver.find_element(method, locator) }
  end
end
