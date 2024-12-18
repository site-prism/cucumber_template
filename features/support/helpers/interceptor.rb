# frozen_string_literal: true

# Based on a code example from: https://github.com/mihael/intercepted/blob/498b6e1d087596a5111134d073b2c40dc11a85a3/lib/interceptor.rb

# Cucumber:
#
# Put this file in features/support/helpers/interceptor.rb and require it
#
#     require_relative "support/helpers/interceptor"
#
# Add the code as a Worldable module
#
#     World(......,Helpers::Interceptor)
#
# Include the autorun code in your hooks as the final line of "hook" code in `Before` and the first
# line of code in your `After`
#
#     Before
#       ........
#       start_intercepting
#     end
#
#     After
#       stop_intercepting
#       ......
#     end
#
# How to use:
#
# Manual Single use ONLY - Intercept one specific URL in one specific test
#
# Call the `intercept` method in any point in your step definitions with the following info
#   -> url
#   -> response
#   -> http method (optional, defaults to :any)
#
#     Given('Some step with a specific intercept') do
#       url_to_intercept = 'https://www.google.com/'
#       intercept(url_to_intercept, "fixed response")
#       visit url_to_intercept
#
#       # assert something that depends on the intercepted request
#     end
#
# Multi-use - Intercept a URL or group of URLs in all tests
# - Configure default interceptions that should always apply to all tests by overriding the `default_interceptions` method

module Helpers
  module Interceptor
    def add_headers_for_cloudflare_interceptor_bypass
      page.driver.browser.intercept do |request, &continue|
        AutomationLogger.debug('Adding headers to bypass Cloudflare protections')
        request.headers['CF-Access-Client-Id'] = ENV.fetch('CF_ACCESS_CLIENT_ID')
        request.headers['CF-Access-Client-Secret'] = ENV.fetch('CF_ACCESS_CLIENT_SECRET')
        continue.call(request)
      end
    end

    # Add an interception hash for a given url, http method, and response
    # @url can be a regexp or a string
    # @method can be a string or a symbol. Can be uppercase or lowercase
    def intercept(url, response = '', method = :any)
      interceptions << { url: url, method: method, response: response }
    end

    def start_intercepting
      raise 'Unsupported Driver' unless page.driver.browser.respond_to?(:intercept)

      # If this isn't the first time this has been invoked, stop as we don't want to attach the interceptor twice
      return if @intercepting

      page.driver.browser.intercept do |request, &continue|
        AutomationLogger.debug("REQUEST METHOD: #{request.method}. REQUEST URL: #{request.url}")
        interception = intercepted_response_for(request.url, request.method)
        determine_interception_logic(interception, request, &continue)
      end
      @intercepting = true
    end

    def stop_intercepting
      clear_devtools_intercepts
      @intercepting = false
      @previous_intercepted_response = nil
      # some requests may finish after the test is done if we let them go through untouched
      sleep(0.2)
    end

    private

    def clear_devtools_intercepts
      page.driver.browser.devtools.tap do |devtools|
        devtools.callbacks.delete('Fetch.requestPaused')
        devtools.callbacks.delete('Network.loadingFailed')
        devtools.network.set_cache_disabled(cache_disabled: false)
        devtools.network.disable
        devtools.fetch.disable
      end
    end

    # Override this method to define default interceptions that should apply to all tests
    # Each element of the array should be a hash with `url`, `response` and `method` key, like
    # the hash added by the `intercept` method
    #
    # For example:
    # - [{url: "https://external.api.com", response: ""}, {url: another_domain, response: fixed_response, method: :get}]
    def default_interceptions
      []
    end

    def determine_interception_logic(interception, request, &)
      if interception
        perform_interception(interception, request, &)
      else
        # leave request untouched
        yield(request)
      end
    end

    # Find the first matching interception hash (if one exists), for a given url and http method pair
    def intercepted_response_for(url, method = 'GET')
      interceptions.detect do |interception|
        matches_url = url.match?(interception[:url])
        intercepted_method = interception[:method] || :any
        matches_method = intercepted_method == :any || method == intercepted_method.to_s.upcase

        matches_url && matches_method
      end
    end

    def interceptions
      @interceptions ||= default_interceptions
    end

    def intercepted_responses
      @intercepted_responses ||= []
    end

    def perform_interception(interception, request, &continue)
      # Set all parameters of response if there's an interception detected
      continue.call(request) do |response|
        intercepted_responses << response.body
        SitePrism.logger.debug("INTERCEPTED #{request.url}. Will mock response with: #{interception[:response]}")
        response.code ||= 200
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.body = interception[:response]
      end
    end
  end
end
