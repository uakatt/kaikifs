require "rubygems"
gem "selenium-client"
require "selenium/client"
require "open-uri"
require "nokogiri"
require "log4r"
include Log4r
begin
  require "chunky_png"
rescue
end
require "base64"

module KaikiFS
end

class KaikiFS::Driver
  attr_reader :selenium_driver, :env, :username, :screenshot_dir
  attr_accessor :pause, :record
  alias :page :selenium_driver
  LOGFILE = "loggy-log"
  ENVS_FILE = "envs.json"
  SCREEN_SHOT_DIR = File.join(File.dirname(__FILE__), '..', '..', 'public', 'images')
  extend Forwardable
  def_delegators :@selenium_driver, :click, :get_text, :stop, :wait_for_text, :window_maximize

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

    @screen_shot_dir = options[:screen_shot_dir] || SCREEN_SHOT_DIR
    @pause = options[:pause] || 0.2

    unlink_old_screenshots

    @threads = []
    @record = {}  # record is a hash containing notes that the "user" needs to keep, like the document number he just created.

    @stderr_log = File.join(Dir::pwd, 'features', 'stderr', Time.now.strftime("%Y.%m.%d-%H.%M.%S"))
  end

  def unlink_old_screenshots
    Dir["public/images/main_*"].each { |image| File.unlink(image) }
    Dir["public/images/cropped_*"].each { |image| File.unlink(image) }
    Dir["public/images/account_1080000_*"].each { |image| File.unlink(image) }
  end

  ##### THIN WRAPPERS
  def hide_tab(name)
    page.click "tab-#{name}-imageToggle"
  end

  def show_tab(name)
    #page.click "tab-#{name}-imageToggle"
    page.click "//input[@title='open #{name}']"
  end

  def click_and_wait(locator)
    dont_stdout! do
      page.click locator
      page.wait_for_page_to_load "60000"
    end
  end

  def click_approximate_and_wait(locators)
    locators.each do |locator|
      begin
        click_and_wait(locator)
        return
      rescue Selenium::CommandError
        # Try the next selector
      end
    end
    raise Selenium::CommandError
  end

  def is_text_present(text)
    page.is_text_present(text)
  end

  #def get_text(locator, regex)
  #  if regex.class != Regexp
  #    regex = Regexp.new(regex)
  #  end
  #  !60.times do
  #    break if (page.get_text(locator) =~ regex rescue false)
  #    puts page.get_text(locator)
  #    sleep 1
  #  end
  #end

  def select_frame(frame); page.select_frame frame; end

  def wait_for_page_to_load(ms='60000'); page.wait_for_page_to_load ms; end

  def record_kfs_version
    !60.times{ break if (page.get_text("build") =~ /(3.0-(?:\d+)) \(Oracle9i\)/ rescue false); sleep 1 }
    kfs_version = "%-7s" % $1
    page.capture_entire_page_screenshot("#{@screen_shot_dir}/main_#{@env}.png", "")
    begin
      ChunkyPNG  # will raise if library not included, fail back to normal screenshot in the 'rescue'
      screen_string_in_base64 = page.capture_entire_page_screenshot_to_string("")
      @threads << Thread.new do
        screen_string = Base64.decode64(screen_string_in_base64)
        png_canvas = ChunkyPNG::Canvas.from_string(screen_string)
        png_canvas = png_canvas.crop 0, 0, 900, 240
        png_canvas = png_canvas.resample 450, 120
        png_canvas.to_image.save("public/images/cropped_#{@env}.png", :fast_rgba)
      end
    rescue NameError
      page.capture_entire_page_screenshot("#{@screen_shot_dir}/cropped_#{@env}.png", "background=#FFFFFF")
    end
  end

  def mk_screenshot_dir(base)
    @screenshot_dir = File.join(base, Time.now.strftime("%Y-%m-%d.%H"))
    return if Dir::exists? @screenshot_dir
    Dir::mkdir(@screenshot_dir)
  end

  def screenshot(name)
      page.capture_entire_page_screenshot(File.join(@screenshot_dir, "#{name}.png"), "background=#FFFFFF")
  end

  def login_via_webauth
    page.click "link=Main Menu"
    page.wait_for_page_to_load "60000"
    sleep 1
    page.type "username", @username
    page.type "password", @password
    page.click "submit"
    sleep 1
    page.wait_for_page_to_load "60000"


    # Check if we logged in successfully
    return if not page.is_element_present("status")  # this is where an error is displayed at the webauth site.
    if page.get_text("status") == "You entered an invalid NetID or password."
      raise WebauthAuthenticationError.new
    elsif page.get_text("status") == "Password is a required field."
      raise WebauthAuthenticationError.new
    end
  end

  def lookup_basic_account
    page.click "link=Account"
    page.wait_for_page_to_load "60000"
    page.select_frame "iframeportlet"
    page.type "chartOfAccountsCode", "UA"
    page.type "accountNumber", "1080000"
    page.click "//input[@name='methodToCall.search' and @value='search']"
    page.wait_for_page_to_load "60000"
    page.capture_entire_page_screenshot("#{@screen_shot_dir}/account_1080000_#{@env}.png", "background=#FFFFFF")

    begin
      ChunkyPNG  # will raise if library not included, fail back to normal screenshot in the 'rescue'
      screen_string_in_base64 = page.capture_entire_page_screenshot_to_string("")
      @threads << Thread.new do
        screen_string = Base64.decode64(screen_string_in_base64)
        png_canvas = ChunkyPNG::Canvas.from_string(screen_string)
        png_canvas = png_canvas.resample(png_canvas.width/2, png_canvas.width/2)
        png_canvas.to_image.save("#{@screen_shot_dir}/account_1080000_#{@env}_thumb.png", :fast_rgba)
      end
    rescue NameError
      page.capture_entire_page_screenshot("#{@screen_shot_dir}/account_1080000_#{@env}_thumb.png", "background=#FFFFFF")
    end

    sleep 1
    #page.click "link=1080000"
    #page.select_frame "relative=up"
    #!60.times{ break if ("1080000" == page.get_text("accountNumber.div") rescue false); sleep 1 }
  end

  def run_in_envs(envs = @envs)
    envs.each do |env, properties|
      begin
        @env = env
        start_session
        page.open "/kfs-#{@env}/portal.jsp"
        login_via_webauth
        yield
      rescue Selenium::CommandError => err
        1
      rescue WebauthAuthenticationError
        raise
      rescue StandardError => err
        1
      ensure
        @threads.each { |t| t.join }
        @selenium_driver.close_current_browser_session
      end
    end
  rescue WebauthAuthenticationError => err
    1
  end

  def backdoor_as(user)
    set_field("//*[@name='backdoorId']", user)
    page.click("css=input[value=login]")
    page.wait_for_page_to_load "60000"
  end

  def set_approximate_field(selectors, value=nil)
    selectors.each do |selector|
      begin
        set_field(selector, value)
        return
      rescue Selenium::CommandError
        # Try the next selector
      end
    end
    raise Selenium::CommandError
  end

  def set_field(id, value=nil)
    if id =~ /@value=/  # I am praying I only use value for radio buttons...
      node_name = 'radio'
      locator = id
    elsif id =~ /^\/\//
      node_name = nil
      dont_stdout! do
        begin
          node_name = page.get_eval("window.document.evaluate(\"#{id}\", window.document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.nodeName;").downcase
        rescue Selenium::CommandError
          node_name = page.get_eval("window.document.getElementById(\"iframeportlet\").contentDocument.evaluate(\"#{id}\", window.document.getElementById(\"iframeportlet\").contentDocument, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.nodeName;").downcase
        end
      end
      locator = id
    elsif id =~ /^.+=.+ .+=.+$/
      node_name = 'radio'
      locator = id
    else
      node_name = page.get_eval("window.document.getElementById('#{id}').nodeName;").downcase
      locator = 'id='+id
    end

    case node_name
    when 'input'
      page.type locator, value
    when 'select'
      page.select locator, value
    when 'radio'
      page.check locator
    else
      page.type locator, value
    end

    sleep @pause
  end

  def selectFirstUnderDocument(selector)
    page.get_eval("window.document.evaluate("+selector+", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;");
  end

  def vendor_search(options = {})
    page.click "link=Vendor"
    page.wait_for_page_to_load "60000"
    page.select_frame "iframeportlet"
    options.each do |id,value|
      set_field(id, value)
    end
    page.click "//input[@name='methodToCall.search' and @value='search']"
    page.wait_for_page_to_load "60000"

    !60.times{ break if (page.get_text("//form[@id='kualiForm']/table/tbody/tr/td[2]/p/span[1]") =~ /(\d+) items retrieved, displaying 1 to 100./ rescue false); sleep 1 }

    page.select_frame "relative=up"
    page.click "link=Main Menu"
    page.wait_for_page_to_load "60000"
  end

  def dont_stdout!
    orig_stdout = $stdout

    # redirect stdout to /dev/null
    $stdout = File.open(@stderr_log, 'a')

    yield if block_given?

    # restore stdout
    $stdout = orig_stdout
  end

  def transfer_of_funds_new(options = {})
    page.click "link=Transfer of Funds"
    page.wait_for_page_to_load "60000"
    page.select_frame "iframeportlet"
    options.reject {|k,v| k == "accounting_lines"}.each do |id,value|
      set_field(id, value)
    end

    if options["accounting_lines"]
      accounting_lines = options["accounting_lines"]
      if accounting_lines["from"]
        accounting_lines["from"].each do |acct_line|
          acct_line.each { |id,value| set_field(id, value) }
          page.click "methodToCall.insertSourceLine.anchoraccountingSourceAnchor"
          page.wait_for_page_to_load "60000"
        end
      end

      if accounting_lines["to"]
        accounting_lines["to"].each do |acct_line|
          acct_line.each { |id,value| set_field(id, value) }
          page.click "methodToCall.insertTargetLine.anchoraccountingTargetAnchor"
          page.wait_for_page_to_load "60000"
        end
      end
    end

    page.click "methodToCall.route"
    page.wait_for_page_to_load "60000"

    page.select_frame "relative=up"
    page.click "link=Main Menu"
    page.wait_for_page_to_load "60000"
    page.click "//img[@alt='doc search']"
    page.wait_for_page_to_load "60000"
    page.select_frame "iframeportlet"
    page.type "fromDateCreated", Time.now.strftime("%m/%d/%Y")
    page.click "//input[@name='methodToCall.search' and @value='search']"
    page.wait_for_page_to_load "60000"
    if options["//input[@id='document.documentHeader.documentDescription']"]
      validation_text = "Transfer Of Funds - #{options["//input[@id='document.documentHeader.documentDescription']"]}"
    else
      validation_text = "Transfer of Funds"
    end
    !60.times{ break if (page.is_text_present(validation_text) rescue false); sleep 1 }

    page.select_frame "relative=up"
    page.click "link=Main Menu"
    page.wait_for_page_to_load "60000"
  end

  def start_session
    @selenium_driver = Selenium::Client::Driver.new \
      :host => "localhost",
      :port => 4444,
      :browser => "*chrome",
      :url => (@envs[@env]['url'] || "https://kf-#{@env}.mosaic.arizona.edu/"),
      :timeout_in_second => 60
    @selenium_driver.start_new_browser_session
  end


  ##### PANELS
  def main_menu_panel
    page.select_frame "relative=up"
    page.click "link=Main Menu"
    page.wait_for_page_to_load "60000"
    page
  end

  def central_admin_panel
    page.select_frame "relative=up"
    page.click "link=Central Admin"
    page.wait_for_page_to_load "60000"
    page
  end

  def maintenance_panel
    page.select_frame "relative=up"
    page.click "link=Maintenance"
    page.wait_for_page_to_load "60000"
    page
  end

  def administration_panel
    page.select_frame "relative=up"
    page.click "link=Administration"
    page.wait_for_page_to_load "60000"
    page
  end


  #def method_missing(name, *args, &block)
  #  if name.to_s =~ /^try_(.*)/

  #  end
  #end
end
