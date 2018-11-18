require 'test_helper'

class DataEncryptingKeyTest < ActiveSupport::TestCase
  test ".generate!" do
    assert_difference "DataEncryptingKey.count" do
      key = DataEncryptingKey.generate!
      assert key
    end
  end
end
