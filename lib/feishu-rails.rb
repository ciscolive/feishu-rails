require "feishu/version"
require "feishu/config"
require "feishu/connector"

module Feishu
  class << self
    def configure(&block)
      Config.configure(&block)
    end
  end
end
