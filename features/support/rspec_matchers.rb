# frozen_string_literal: true

RSpec::Matchers.define :be_non_empty do
  description { 'be a non-empty collection (Hash values/Array)' }
  failure_message { "'#{actual}' contains some empty values: #{dump_empty_data(actual)}" }

  match do |actual|
    actual = actual.values if actual.is_a?(Hash)
    actual = [actual] unless actual.is_a?(Array)
    actual.none? { |value| empty?(value) }
  end

  def dump_empty_data(actual)
    if actual.is_a?(Hash)
      actual.select { |_key, value| empty?(value) }
    else
      actual.select { |item| empty?(item) }
    end
  end

  def empty?(value)
    value.nil? || value.empty?
  end
end

RSpec::Matchers.define :have_errors do
  description { 'contains some errors' }
  failure_message { "'#{actual}' does not contain any errors" }

  match do |actual|
    actual = [actual] unless actual.is_a?(Array)
    actual.any?(&:errored?)
  end
end
