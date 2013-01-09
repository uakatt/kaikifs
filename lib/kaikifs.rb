$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

# This is the top level file for KaikiFS that should be required in order to
# load all of the KaikiFS module and its inner components. This file also loads
# some monkey-patching for File and String, as well as the following gems:
# headless and json.
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
