# frozen_string_literal: true

class ApplicationService
  USER_AGENT = {"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"}

  def self.call(*args, &block)
    new(*args, &block).call
  end
end