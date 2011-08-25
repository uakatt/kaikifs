require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'kaikifs')
require 'rspec'
require 'highline/import'
require 'active_support/inflector'

class KaikiFSWorld
    username = ask("NetID:  ")    { |q| q.echo = true }
    password = ask("Password:  ") { |q| q.echo = "*" }
    @@kaikifs = KaikiFS::Driver.new(username, password, :envs => ['dev'])
    @@kaikifs.start_session
    @@kaikifs.page.open "kfs-dev/portal.jsp"
    @@kaikifs.login_via_webauth

    at_exit { @@kaikifs.stop }

  def kaikifs; @@kaikifs; end
end

World do
  KaikiFSWorld.new
end
