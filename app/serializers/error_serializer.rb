# frozen_string_literal: true

module ErrorSerializer
  extend self

  def from_messages(error_messages, meta: {})
    error_messages = Array.wrap(error_messages)
    { errors: build_errors(error_messages, meta) }
  end
  alias from_message from_messages

  def from_model(model)
    { errors: build_model_errors(model.errors) }
  end

  private

  def build_errors(error_messages, meta)
    error_messages.map { |message| build_error(message: message, meta: meta) }
  end

  def build_model_errors(errors)
    errors.messages.map do |key, messages|
      messages.map do |message|
        build_error(message: message, key: key)
      end
    end.flatten
  end

  def build_error(message:, key: nil, meta: {})
    if message.is_a?(Hash)
      key = message.keys.join(', ')
      message = message.values.join(', ')
    end

    error = { detail: message }
    error[:meta] = meta if meta.present?
    error[:key] = key if key.present?
    error
  end
end
