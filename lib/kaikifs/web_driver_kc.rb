# This class derives almost everything from {KaikiFS::WebDriver::Base}. So far the only
# thing different is the text on the "Main Menu" link.
class KaikiFS::WebDriver::KC < KaikiFS::WebDriver::Base
  MAIN_MENU_LINK = [:link_text, 'Researcher']
  def main_menu_link; MAIN_MENU_LINK; end
end
