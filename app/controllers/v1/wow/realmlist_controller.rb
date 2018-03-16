# frozen_string_literal: true
module V1
  module Wow
      # Retreive update to date realm list from armory
    class RealmlistController < ApplicationController
      include Wowarmory
      def index
        realms = realm_list(params[:id])
        render json: realms
      end
    end
  end
end
