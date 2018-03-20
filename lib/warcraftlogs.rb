
# Warcraftlogs api helper used to get parses
module Warcraftlogs
  WCL_API_KEY = Rails.application.credentials.warcraftlogs_api_key
  WCL_API_URL = 'https://www.warcraftlogs.com:443/v1/'.freeze
  WCL_PARSES_API_END_POINT = 'parses/character/'.freeze

  def playerlogs_data(region, realm, name, role)
      uri = "#{WCL_API_URL}#{WCL_PARSES_API_END_POINT}#{CGI.escape(name)}/#{CGI.escape(realm)}/#{region}?metric=#{role}&api_key=#{WCL_API_KEY}"
      Typhoeus::Config.cache = Typhoeus::Cache::Rails.new
      request = Typhoeus::Request.new(
        uri,
        method: :get,
        followlocation: true,
        accept_encoding: 'gzip'
      )

      request.on_complete do |response|
        if response.success?
          return JSON.parse(response.response_body)
        else
          false
        end
      end
      request.run
  end

  def normal_logs(logs)
    @normal_logs ||= parse_logs(logs, 3).to_i
  end

  def heroic_logs(logs)
    @heroic_logs ||= parse_logs(logs, 4).to_i
  end

  def mythic_logs(logs)
    @mythic_logs ||= parse_logs(logs, 5).to_i
  end

  private

  def parse_logs(logs, difficulty)
    total_percent = 0
    logs.each do |k|
      highest_percent = 0
      next unless k['difficulty'] == difficulty
      k['specs'].first['data'].each do |spec|
        if highest_percent.round < spec['percent'].round
          highest_percent = spec['percent'].round
        end
      end
      total_percent += highest_percent
    end
    total_percent
  end
end
