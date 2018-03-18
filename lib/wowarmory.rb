require 'rest-client'

# Library to interact with the warcraft api located at https://dev.battle.net/
module Wowarmory
  WOW_API_KEY = Rails.application.credentials.battle_net_api_key
  API_URL = 'api.battle.net'.freeze
  REALMS_END_POINT = '/wow/realm/status'.freeze

  def character_data(region, realm, name)
    uri = "https://#{region}.api.battle.net/wow/character/#{CGI.escape(realm)}/#{CGI.escape(name)}?fields=items,progression,guild,achievements,talents&apikey=#{WOW_API_KEY}"
    request = RestClient.get(uri) { |response, _request, _result| response }
    return JSON.parse(request) if request.code == 200
    false
  end

  def player_class_is(player)
    classes = ['Warrior', 'Paladin', 'Hunter', 'Rogue', 'Priest', \
               'Death Knight', 'Shaman', 'Mage', 'Warlock', \
               'Monk', 'Druid', 'Demon Hunter'].freeze
    classes.at(player['class'] - 1)
  end

  def player_spec_is(player)
    player['talents'].each do |key|
      return key['spec']['name'] if key['selected'] == true
    end
  end

  def healer?(player)
    player_spec = player_spec_is(player)
    return true if %w[Holy Discipline Restoration Mistweaver].include?(player_spec)
    false
  end

  def tank?(player)
    player_spec = player_spec_is(player)
    return true if %w[Blood Protection Vengeance Guardian].include?(player_spec)
    false
  end

  def ranged?(player)
    player_spec = player_spec_is(player)
    player_class = player['class']

    return true if [5, 8, 9].include?(player_class) ||
                   %w[Balance Beast\ Mastery Marksmanship Elemental].include?(player_spec)
    false
  end

  def role(player)
    return 'tank' if tank?(player)
    return 'healer' if healer?(player)
    return 'ranged' if ranged?(player)
    'melee'
  end

  def avatar_link(player)
    player['thumbnail']
  end

  def background_link(player)
    player['thumbnail'].gsub! 'avatar', 'main'
  end

  def itemlevel(player)
    @itemlevel ||= player['items']['averageItemLevelEquipped'].to_i
  end

  def artifact_weapon_level(player)
    player_spec_is(player) == 'protection' ? weapon_info = player['items']['offHand']['artifactTraits'] : weapon_info = player['items']['mainHand']['artifactTraits']
    weapon_info.map { |s| s['rank'] }.reduce(0, :+) - 3
  end

  def gear_information(player)
    gear_info = []
    player['items'].each do |k, v|
      next if %w[averageItemLevel averageItemLevelEquipped].include?(k)
      item = {
        slot: k,
        name: v['name'],
        id: v['id'],
        ilvl: v['itemLevel']
      }
      gear_info.push(item)
    end
    gear_info
  end

  def normal_progression(player)
    @normal_progression ||= raid_progression(player).first
  end

  def heroic_progression(player)
    @heroic_progression ||= raid_progression(player).second
  end

  def mythic_progression(player)
    @mythic_progression ||= raid_progression(player).last
  end

  def raid_progression(player)
    valid_raid_ids = [
      8638 # Antorus, the Burning Throne
    ].freeze

    normal_kills = 0
    heroic_kills = 0
    mythic_kills = 0

    raid_progression = player['progression']['raids']
    raid_progression.each_entry do |k|
      next unless valid_raid_ids.any?(k['id'])
      k['bosses'].each do |boss|
        if boss['normalKills'].positive?
          normal_kills += 1
        end
        if boss['heroicKills'].positive?
          heroic_kills += 1
        end
        if boss['mythicKills'].positive?
          mythic_kills += 1
        end
      end
    end
    [normal_kills, heroic_kills, mythic_kills]
  end

  def realm_list(region = 'us')
    request = RestClient.get("https://#{region}.#{API_URL}#{REALMS_END_POINT}?apikey=#{WOW_API_KEY}")
    realms = JSON.parse(request)
    realm_list = []
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
