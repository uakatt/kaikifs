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
  attr_reader :selenium_driver, :env, :pause
  alias :page :selenium_driver
  LOGFILE = "loggy-log"
  ENVS_FILE = "envs.json"
  SCREEN_SHOT_DIR = File.join(File.dirname(__FILE__), '..', '..', 'public', 'images')
  extend Forwardable
  def_delegators :@selenium_driver, :wait_for_text, :stop

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
    @pause = options[:pause] || 1

    ##@log = Logger.new 'log'
    ##@log.outputters = FileOutputter.new 'logfile', {:filename => LOGFILE, :trunc => true}
    unlink_old_screenshots

    @threads = []
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
    page.click "tab-#{name}-imageToggle"
  end

  def click(locator); page.click locator; end

  def click_and_wait(locator)
    page.click locator
    page.wait_for_page_to_load "60000"
  end

  def is_text_present(text)
    page.is_text_present(text)
  end

  def get_text(locator, regex)
    if regex.class != Regexp
      regex = Regexp.new(regex)
    end
    !60.times do
      break if (page.get_text(locator) =~ regex rescue false)
      puts page.get_text(locator)
      sleep 1
    end
  end

  def select_frame(frame); page.select_frame frame; end

  def wait_for_page_to_load(ms); page.wait_for_page_to_load ms; end

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

  def login_via_webauth
    page.click "link=Main Menu"
    page.wait_for_page_to_load "60000"
    sleep 1
    page.type "username", @username
    page.type "password", @password
    page.click "submit"
    sleep 1
    page.wait_for_page_to_load "60000"

    #@log.info "in login_via_webauth: #{@env} " + cookies.inspect
    #puts      "in login_via_webauth: #{@env} " + cookies.inspect

    # Check if we logged in successfully
    return if not page.is_element_present("status")  # this is where an error is displayed at the webauth site.
    if page.get_text("status") == "You entered an invalid NetID or password."
      ##@log.error "#{@env}: Webauth login returned: " + "You entered an invalid NetID or password."
      raise WebauthAuthenticationError.new
    elsif page.get_text("status") == "Password is a required field."
      ##@log.error "#{@env}: Webauth login returned: " + "Password is a required field."
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
        ##@log.error "#{@env}: Found error: #{err}" # eg: ERROR: Element link=Account not found
      rescue WebauthAuthenticationError
        raise
      rescue StandardError => err
        ##@log.error "#{@env}: Found error: #{err}"
        ##@log.error "#{@env}: Found error: #{err.class}"
      ensure
        @threads.each { |t| t.join }
        @selenium_driver.close_current_browser_session
      end
    end
  rescue WebauthAuthenticationError => err
    ##@log.error "Discontinuing tests following a #{err.class}."
  end

  def backdoor_as(user)
    set_field("//*[@name='backdoorId']", user)
    page.click("css=input[value=login]")
    page.wait_for_page_to_load "60000"
  end

  def set_field(id, value=nil)
    if id =~ /^\/\//
      nodeName = page.get_eval("window.document.evaluate(\"#{id}\", window.document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.nodeName;").downcase
      locator = id
    elsif id =~ /^.+=.+ .+=.+$/
      nodeName = 'radio'
      locator = id
    else
      nodeName = page.get_eval("window.document.getElementById('#{id}').nodeName;").downcase
      locator = 'id='+id
    end

    case nodeName
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
    ##@log.info "Results of Vendor search: " + page.get_text("//form[@id='kualiForm']/table/tbody/tr/td[2]/p/span[1]")

    page.select_frame "relative=up"
    page.click "link=Main Menu"
    page.wait_for_page_to_load "60000"
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
    ##@log.info "Results of Doc search after Transfer of Funds: " + validation_text

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

  def maintenance_panel
    page.select_frame "relative=up"
    page.click "link=Maintenance"
    page.wait_for_page_to_load "60000"
    page
  end
end
