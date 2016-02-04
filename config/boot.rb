ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# require 'rails/commands/server'

# module DefaultOptions
#   def default_options
#     super.merge!(Port: 10000)
#   end
# end

# Rails::Server.send(:prepend, DefaultOptions)
