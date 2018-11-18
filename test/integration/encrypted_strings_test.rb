require 'test_helper'
require 'sidekiq/api'

class EncryptedStringsTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def setup
    DatabaseCleaner.clean
    @data_encrypting_key = DataEncryptingKey.generate!(primary: true)
    1000.times do |n|
      EncryptedString.create(value: "string_#{n}")
    end
  end

  test "polls rotate endpoint" do
    assert_equal 1000, EncryptedString.count

    post "/data_encrypting_keys/rotate"
    sleep 3

    res = json_body(response.body)
    assert_response :success
    assert_equal 'Request received and processsing', res["message"]

    poll_active = Sidekiq::ScheduledSet.new.size + Sidekiq::Workers.new.size
    retries = 3

    # Continue polling for as long as there is a running or queued process
    while poll_active > 0 || retries > 0 do
      sleep 1

      get "/data_encrypting_keys/rotate/status"

      assert_response :success
      res = json_body(response.body)

      scheduled_set_size = Sidekiq::ScheduledSet.new.size
      total_active_workers = Sidekiq::Workers.new.size

      assert_equal 'Key rotation has been queued', res["message"] if scheduled_set_size > 1
      assert_equal 'Key rotation is in progress', res["message"] if total_active_workers > 1

      poll_active = scheduled_set_size + total_active_workers

      # retrying again to maker sure that the job has been completed
      retries = retries - 1 if (poll_active == 0)
    end

    assert_equal 'No key rotation queued or in progress', res["message"]
  end
end

def json_body(body)
  JSON.parse(body)
end
