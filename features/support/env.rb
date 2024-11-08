# frozen_string_literal: true

# The purpose of this single file is to control all of your load orders
#
# You can omit items here if you trust the auto-loader to pick them up, but ideally you would contain
# 90% of the items you need IN the order you need them

# Always load dotenv first
require 'dotenv'
Dotenv.load('.env')

# Load all of your gem code here - Important to ensure you have the right loaders
require_relative 'all'
# Load all of your helper logic next, you will need these before this file is fully loaded
require_relative 'helpers/all'
# Require any logging code next, because you are likely to be calling loggers when autoloading
# every other item such as driver logic
require_relative 'automation_logger'
# Include any and all driver logic here - This example features 2 concepts of driver logic, so we load them both
require_relative 'driver'
require_relative 'drivers/all'
# You must lodd sections first before autoloading. An inside-out order is required here to prevent the
# SitePrism metaprogram from tripping up
require_relative 'sections/all'
# Optional step. Your pages should be picked up by the autoloader
require_relative 'pages/all'

# Add in all Worldable modules.
# NB: Capybara::RSpecMatcherProxies is required if you plan on using the `all` matcher inside your cukes
World(
  Helpers::Page,
  Helpers::Methods,
  Helpers::Regex,
  Helpers::EnvVariables,
  Capybara::RSpecMatcherProxies
)

# I prefer to have my driver class have a single method that just registers the single driver I'll need for
# my tests. But you can have any/all logic here you want
Driver.new.register

# Add any/all patches or last minute config/helpers required here
AutomationHelpers.logger.level = :DEBUG
AutomationHelpers::Patches::Capybara.new.patch!
AutomationHelpers::Patches::SeleniumLogger.new.patch!
AutomationHelpers::Patches::SeleniumManager.new.patch!
AutomationHelpers::Patches::SeleniumOptions.new(ENV['BROWSER'].to_sym).patch!
