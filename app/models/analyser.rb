class Analyser
  include ActiveModel::Model
  include Wowarmory
  include Warcraftlogs

  attr_accessor :armory, :logs

  MAX_ILVL = 989
  MAX_RELIC = 15
  MAX_WEAPON = 101
  MYTHIC_PERCENTILE = 100 * 11
  HEROIC_PERCENTILE = MYTHIC_PERCENTILE * 0.55
  NORMAL_PERCENTILE = MYTHIC_PERCENTILE * 0.10
  MYTHIC_BOSS_KILLS = 11
  HEROIC_BOSS_KILLS = MYTHIC_BOSS_KILLS * 0.55
  NORMAL_BOSS_KILLS = MYTHIC_BOSS_KILLS * 0.10

  def analyse
    output = {
      character: character_output,
      gear: gear_output,
      rating: score_output
    }
    output
  end

  def log_type
    healer?(armory) ? 'hps' : 'dps'
  end

  private

  def max_score
    MAX_ILVL + MAX_RELIC + MAX_WEAPON +
      MYTHIC_PERCENTILE + HEROIC_PERCENTILE + NORMAL_PERCENTILE +
      MYTHIC_BOSS_KILLS + HEROIC_BOSS_KILLS + NORMAL_BOSS_KILLS
  end

  def character_output
    {
      name: armory['name'],
      class: player_class_is(armory),
      spec: player_spec_is(armory),
      role: role(armory),
      avatar: avatar_link(armory),
      background: background_link(armory),
    }
  end

  def gear_output
    {
      itemlevel: itemlevel(armory),
      weapon: artifact_weapon_level(armory),
      gear: gear_information(armory)
    }
  end

  def normal_logs
    @normal_logs ||= parse_normal(logs)
  end

  def heroic_logs
    @heroic_logs ||= parse_heroic(logs)
  end

  def mythic_logs
    @mythic_logs ||= parse_mythic(logs)
  end

  def total_score
    (normal_logs + heroic_logs + mythic_logs +
     itemlevel(armory) + artifact_weapon_level(armory))
  end

  def rating
    increase = (max_score - total_score).to_f
    percent = ((increase / max_score) * 100).to_f.round
    (100 - percent)
  end

  def details
    {
      logs: {
        normal: normal_logs,
        heroic: heroic_logs,
        mythic: mythic_logs
      },
      progression: raid_progression(armory) 
    }
  end

  def score_output
    {
      details: details,
      total_score: total_score,
      max_score: max_score.to_i,
      rating: rating
    }
  end
end
