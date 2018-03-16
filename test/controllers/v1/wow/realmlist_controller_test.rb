require 'test_helper'

module V1
  module Wow
    class RealmlistControllerTest < ActionDispatch::IntegrationTest
      test 'index should return realm list(us)' do
        get v1_wow_realmlist_url('us')
        json_response = JSON.parse(response.body)
        assert_equal 'Aegwynn', json_response.first['name'] # this will fail in future if the realm list order changes find a better solution
        assert_response 200
      end
    end
  end
end
