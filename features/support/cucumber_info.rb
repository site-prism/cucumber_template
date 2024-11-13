# frozen_string_literal: true

class CucumberInfo
  class << self
    include Helpers::EnvVariables
    extend Forwardable

    def_delegators :tags, :not_ios12?, :not_mobile?

    attr_reader :session_id, :test_case
    attr_writer :scenario_result

    def skip_scenario?
      ScenarioSkipper.new(tag_array).skip_scenario?
    end

    def set_session_id
      # The call to Capybara.page.driver.browser can fail with the exception "no sessionId in returned payload"
      # This is caused by the response to create_session in Selenium's remote WebDriver not returning a payload
      # when being served by the Browserstack Hub infrastructure.

      # This should be wrapped and retried as it's an intermittent failure from Browserstack
      @session_id = Capybara.page.driver.browser.session_id if browserstack?
    end

    def test_case=(test_case)
      # Clear previous tag cache
      remove_instance_variable(:@tags) if instance_variable_defined?(:@tags)
      @test_case = test_case
    end

    def scenario_result
      @scenario_result ||= 'passed'
    end

    def tags
      @tags ||= Tags.new(tag_array)
    end

    def api_test?
      test_case.feature_file_path.include?("features/api")
    end

    private

    def tag_array
      test_case.source_tag_names
    end
  end
end
