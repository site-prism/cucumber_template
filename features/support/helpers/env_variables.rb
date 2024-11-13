# frozen_string_literal: true

module Helpers
  module EnvVariables
    # Add in helpers here relevant to the env construct - such as boolean checks on browser types

    def base_url
      'https://www.google.com/'
    end

    def browser
      :chrome
    end

    def browserstack?
      false
    end

    def device?
      false
    end

    def ios13?
      false
    end

    def ipad?
      false
    end

    def iphone?
      false
    end

    def safari?
      false
    end

    def log_level
      :INFO
    end
  end
end
