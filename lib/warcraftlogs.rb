require 'rest-client'
# Warcraftlogs api helper used to get parses
module Warcraftlogs
  WCL_API_KEY = Rails.application.credentials.warcraftlogs_api_key
  WCL_API_URL = 'https://www.warcraftlogs.com:443/v1/'.freeze
  WCL_PARSES_API_END_POINT = 'parses/character/'.freeze

  def playerlogs_data(region, realm, name, role)
    uri = "#{WCL_API_URL}#{WCL_PARSES_API_END_POINT}#{CGI.escape(name)}/#{CGI.escape(realm)}/#{region}?metric=#{role}&api_key=#{WCL_API_KEY}"
    request = RestClient.get(uri) { |response, _request, _result| response }
    return false unless request.code == 200
    JSON.parse(request)
  end

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

  def parse_mythic(logs)
    parse_logs(logs, 5).to_i
  end

  def parse_heroic(logs)
    (parse_logs(logs, 4) * 0.55).to_i
  end

  def parse_normal(logs)
    (parse_logs(logs, 3) * 0.10).to_i
  end
end
