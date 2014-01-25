# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Noteweb::Application.initialize!

if $0 = 'irb'
	require 'hirb'
	Hirb.enable
end
