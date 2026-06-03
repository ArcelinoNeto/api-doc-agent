require "ipaddr"
require "net/http"
require "resolv"
require "uri"

module ApiDocs
  class UrlContentFetcher
    Error = Class.new(StandardError)

    PRIVATE_IP_RANGES = [
      IPAddr.new("0.0.0.0/8"),
      IPAddr.new("10.0.0.0/8"),
      IPAddr.new("127.0.0.0/8"),
      IPAddr.new("169.254.0.0/16"),
      IPAddr.new("172.16.0.0/12"),
      IPAddr.new("192.168.0.0/16"),
      IPAddr.new("::1/128"),
      IPAddr.new("fc00::/7"),
      IPAddr.new("fe80::/10")
    ].freeze

    MAX_RESPONSE_BYTES = 2.megabytes
    OPEN_TIMEOUT = 5
    READ_TIMEOUT = 10

    def self.call(url)
      new(url).call
    end

    def initialize(url)
      @uri = URI.parse(url)
    rescue URI::InvalidURIError => error
      raise Error, "Invalid URL: #{error.message}"
    end

    def call
      validate_uri!
      validate_host!

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
        response = http.request(Net::HTTP::Get.new(uri))
        raise Error, "Could not read URL: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        body = response.body.to_s
        raise Error, "URL response is too large" if body.bytesize > MAX_RESPONSE_BYTES

        body
      end
    end

    private

    attr_reader :uri

    def validate_uri!
      raise Error, "URL scheme must be HTTP or HTTPS" unless %w[http https].include?(uri.scheme)
      raise Error, "URL host is required" if uri.host.blank?
    end

    def validate_host!
      addresses = Resolv.getaddresses(uri.host)
      raise Error, "URL host could not be resolved" if addresses.empty?

      addresses.each do |address|
        ip = IPAddr.new(address)
        raise Error, "URL host resolves to a private or local address" if PRIVATE_IP_RANGES.any? { |range| range.include?(ip) }
      end
    rescue Resolv::ResolvError, IPAddr::InvalidAddressError => error
      raise Error, "URL host validation failed: #{error.message}"
    end
  end
end
