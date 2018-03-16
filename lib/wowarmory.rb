require 'rest-client'

# Library to interact with the warcraft api located at https://dev.battle.net/
module Wowarmory
  WOW_API_KEY = Rails.application.credentials.battle_net_api_key
  API_URL = 'api.battle.net'.freeze
  REALMS_END_POINT = '/wow/realm/status'.freeze

  def armory_character(name, realm, region = 'us')
    uri = "https://#{region}.api.battle.net/wow/character/#{CGI.escape(realm)}/#{CGI.escape(name)}?fields=items,progression,guild,achievements,talents&apikey=#{WOW_API_KEY}"
    request = RestClient.get(uri) { |response, _request, _result| response }
    return JSON.parse(request) if request.code == 200
    false
  end

  def realm_list(region = 'us')
    request = RestClient.get("https://#{region}.#{API_URL}#{REALMS_END_POINT}?apikey=#{WOW_API_KEY}")
    realms = JSON.parse(request)
    realm_list = []
    puts realms['realms'].class
    realms['realms'].each do |k|
      realm = {
        name: k['name'],
        slug: k['slug']
      }
      realm_list.push(realm)
    end
    realm_list
  end
end
