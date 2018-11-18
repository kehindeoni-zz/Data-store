require 'test_helper'

class EncryptedStringTest < ActiveSupport::TestCase
  test 'return encrypted key' do
    key = DataEncryptingKey.generate!(primary: true)
    encrypted_string = EncryptedString.new(value: 'string')
    assert_equal key.key, encrypted_string.encrypted_key
  end
end
