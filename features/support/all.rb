# frozen_string_literal: true

# Add in all of your gem code requirements here
#
# This will be loaded first from env.rb
# NB: We don't need dotenv here as we did that manually in env.rb

require 'capybara'
require 'capybara/dsl'
require 'capybara/cucumber'
require 'faraday'
require 'forwardable'
require 'logger'
require 'rspec'
require 'selenium-webdriver'
require 'singleton'
require 'site_prism'
require 'webdrivers'

# Patches need to be required last after everything else defined
require 'active_support/core_ext/object/blank'
require 'automation_helpers'
