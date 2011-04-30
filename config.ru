require 'rubygems'
require 'bundler/setup'

require './eetee'
require './config_manager'

ConfigManager.load

use Rack::CommonLogger
use Rack::Session::Cookie, :secret => ConfigManager['cookie_secret']

use Rack::Static, :urls => ['/images'], :root => 'public'

run Eetee
