require 'test_helper'

class RotateKeyWorkerTest < ActiveJob::TestCase
  def setup
    require 'sidekiq/testing'
    Sidekiq::Testing.fake!
  end

  def teardown
    Sidekiq::Testing.disable!
  end

  test "enqueued jobs" do
    assert_equal 0, RotateKeyWorker.jobs.size
    RotateKeyWorker.perform_async
    assert_equal 1, RotateKeyWorker.jobs.size
  end
end
