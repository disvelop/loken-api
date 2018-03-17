class Analyser
  include ActiveModel::Model
  include Wowarmory
  include Warcraftlogs

  attr_accessor :armory, :logs

  MAX_ILVL = 989
  MAX_RELIC = 15
  MAX_WEAPON = 101
  MYTHIC_PERCENTILE = 100 * 11
  HEROIC_PERCENTILE = MYTHIC_PERCENTILE * 0.75
  NORMAL_PERCENTILE = MYTHIC_PERCENTILE * 0.50
  MYTHIC_BOSS_KILLS = 11
  HEROIC_BOSS_KILLS = MYTHIC_BOSS_KILLS * 0.75
  NORMAL_BOSS_KILLS = MYTHIC_BOSS_KILLS * 0.50

  def analyse
    output = {
      character: character_output,
      gear: gear_output,
      scores: score_output
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
      gear: gearinformation(armory)
    }
  end

  def logs_output
    {
      normal: parse_normal(logs),
      heroic: parse_heroic(logs),
      mythic: parse_mythic(logs)
    }
  end

  def total_score
    (parse_normal(logs) + parse_heroic(logs) + parse_mythic(logs) +
     itemlevel(armory) + artifact_weapon_level(armory))
  end

  def score_output
    {
      total_score: total_score,
      max_score: max_score.to_i
    }
  end
end
