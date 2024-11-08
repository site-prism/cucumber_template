# frozen_string_literal: true

# This class is setup the way I like to log - for ease and simplicity

# Any / all configuration here is person/team specific. The preferences here are my own
class AutomationLogger
  class << self
    extend Forwardable
    include Helpers::EnvVariables

    def_delegators :logger, :debug, :info, :warn, :error, :fatal, :unknown

    def logger
      @logger ||= create_logger
    end

    private

    def create_logger
      ::Logger.new(log_name, logs_to_keep, size_of_log).tap do |logger|
        logger.progname = 'AutomationLogger'
        logger.level = log_level
        logger.formatter = proc do |severity, time, progname, msg|
          "#{time.strftime('%F %T')} - #{severity} - #{progname} - #{msg}\n"
        end
      end
    end

    def log_name
      Pathname.new('tmp/logs') + log_location
    end

    def logs_to_keep
      7
    end

    def size_of_log
      1_048_576
    end
  end
end
