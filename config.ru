require 'faye'
require './app'

use Faye::RackAdapter,
  :mount      => '/faye',
  :timeout    => 25

run App
