# frozen_string_literal: false

module BinanceAPI
  class RequestError < StandardError
    attr_reader :status, :message

    def initialize(status, message)
      @status = status
      @message = message
    end
  end
end
