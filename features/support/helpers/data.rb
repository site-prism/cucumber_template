# frozen_string_literal: true

module Helpers
  module Data
    def sample_data
      load_data(sample)
    end

    private

    def load_data(name)
      YAML.safe_load("#{Dir.pwd}/data/#{name}.yml")
    end
  end
end
