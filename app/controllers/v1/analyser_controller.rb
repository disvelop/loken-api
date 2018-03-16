module V1
  class AnalyserController < ApplicationController
    include Wowarmory
    def show
      player = armory_character('xtda', 'frostmourne')
      render json: player
    end
  end
end
