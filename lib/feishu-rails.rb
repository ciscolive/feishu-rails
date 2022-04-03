# frozen_string_literal: true

require "feishu/version"
require "feishu/connector"

module Feishu
  class << self
    attr_accessor :app_id, :app_secret, :encrypt_key

    def config
      yield self
    end
  end
end
