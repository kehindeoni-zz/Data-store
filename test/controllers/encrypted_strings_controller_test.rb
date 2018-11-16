require 'test_helper'

class EncryptedStringsControllerTest < ActionController::TestCase

  def setup
    @data_encrypting_key = DataEncryptingKey.generate!(primary: true)
  end

  test "POST #create saves new EncryptedString" do
    assert_difference "EncryptedString.count" do
      post :create, encrypted_string: { value: "to encrypt"}
    end

    assert_response :success

    json = JSON.parse(response.body)
    assert json["token"]
  end

  test "POST #create returns invalud when value does not exist" do
    assert_no_difference "EncryptedString.count" do
      post :create, encrypted_string: {value: nil}
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Value can't be blank", json["message"]
  end

  test "get #show returns the decrypted value" do
    @encrypted_string = EncryptedString.create!(value: "decrypted string")

    get :show, token: @encrypted_string.token

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal "decrypted string", json["value"]
  end

  test "get #show returns 404 for invalid token" do
    get :show, token: "does not exist"

    assert_response :not_found
  end

  test "delete #destroy removes the token from the database" do
    @encrypted_string = EncryptedString.create!(value: "value to destroy")


    assert_difference "EncryptedString.count", -1 do
      post :destroy, token: @encrypted_string.token
    end

    assert_response :success
  end

  test "delete #destroy returns 404 for invalid token" do
    delete :destroy, token: "does not exist"

    assert_response :not_found
  end
end
