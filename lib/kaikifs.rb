$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

module KaikiFS
end

require 'headless'
require 'json'

require 'string'
require 'file'
require 'kaikifs/web_driver_base'
require 'kaikifs/web_driver_kfs'
require 'kaikifs/web_driver_kc'
require 'kaikifs/capybara_driver_base'
require 'kaikifs/capybara_driver_kfs'
require 'kaikifs/errors'
require 'approximations_factory'
