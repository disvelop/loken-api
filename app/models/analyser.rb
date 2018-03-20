class Analyser
  include ActiveModel::Model
  include Wowarmory
  include Warcraftlogs

  attr_accessor :armory, :logs

  MAX_ILVL = 989
  MAX_RELIC = 15
  MAX_WEAPON = 101
  NORMAL_DECREASE = 0.11
  HEROIC_DECREASE = 0.55
  MYTHIC_PERCENTILE = 100 * 11
  HEROIC_PERCENTILE = MYTHIC_PERCENTILE * HEROIC_DECREASE
  NORMAL_PERCENTILE = MYTHIC_PERCENTILE * NORMAL_DECREASE
  MYTHIC_BOSS_KILLS = 11
  HEROIC_BOSS_KILLS = MYTHIC_BOSS_KILLS * HEROIC_DECREASE
  NORMAL_BOSS_KILLS = MYTHIC_BOSS_KILLS * NORMAL_DECREASE

  def analyse
    output = {
      character: character_output,
      gear: gear_output,
      score: score_output
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
      background: background_link(armory)
    }
  end

  def gear_output
    {
      itemlevel: itemlevel(armory),
      weapon: artifact_weapon_level(armory),
      gear: gear_information(armory)
    }
  end

  def total_score
    itemlevel(armory) + artifact_weapon_level(armory) +
      mythic_logs(armory) + (heroic_logs(armory) * HEROIC_DECREASE).to_i +
      (normal_logs(armory) * NORMAL_DECREASE).to_i +
      raid_progression(armory).sum
  end

  def rating
    increase = (max_score - total_score).to_f
    percent = ((increase / max_score) * 100).to_f.round
    (100 - percent)
  end

  def progression
    {
      normal: normal_progression(armory),
      heroic: heroic_progression(armory),
      mythic: mythic_progression(armory),
      score: raid_progression(armory).sum
    }
  end

  def logs_display(type)
    if type == 'mythic'
      mythic_progression(armory).positive? ? mythic_logs(logs) / mythic_progression(armory) : 0 
    elsif type == 'heroic'
      heroic_progression(armory).positive? ? heroic_logs(logs) / heroic_progression(armory) : 0 
    else
      normal_progression(armory).positive? ? normal_logs(logs) / normal_progression(armory) : 0 
    end
  end

  def log
    {
      normal: logs_display('normal'),
      heroic: logs_display('heroic'),
      mythic: logs_display('mythic'),
      score: normal_logs(logs) + heroic_logs(logs) + mythic_logs(logs)
    }
  end

  def gear
    {
      ilvl: itemlevel(armory),
      weapon: artifact_weapon_level(armory),
      score: itemlevel(armory) + artifact_weapon_level(armory)
    }
  end

  def details
    {
      logs: log,
      progression: progression,
      gear: gear
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
