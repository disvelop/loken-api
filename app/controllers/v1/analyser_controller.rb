module V1
  class AnalyserController < ApplicationController
    include Wowarmory
    include Warcraftlogs

    def show
      player = Analyser.new

      player.armory = character_data(params[:region],
                                     params[:realm], params[:name])

      return render json: { status: 'user not found' }, status: 404 unless player.armory

      player.logs = playerlogs_data(
        params[:region],
        params[:realm],
        params[:name],
        player.log_type
      )
      
      render json: player.analyse
    end
  end
end
