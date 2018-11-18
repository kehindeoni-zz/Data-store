class EncryptedStringsController < ApplicationController
  require "sidekiq/api"

  before_action :load_encrypted_string, only: [:show, :destroy]

  def create
    @encrypted_string = EncryptedString.new(value: encrypted_string_params[:value])
    if @encrypted_string.save
      render json: { token: @encrypted_string.token }
    else
      render json: { message: @encrypted_string.errors.full_messages.to_sentence},
             status: :unprocessable_entity
    end
  end

  def show
    render json: { value: @encrypted_string.value }
  end

  def destroy
    @encrypted_string.destroy!
    head :ok
  end

  def rotate
    if still_processing?
      render json: { message: @status_message }
    else
      RotateKeyWorker.perform_in(5.seconds)
      render json: { message: 'Request received and processsing' }
    end
  end

  def get_rotation_status
    still_processing?
    render json: { message: @status_message }
  end

  private

  def load_encrypted_string
    @encrypted_string = EncryptedString.find_by(token: params[:token])
    if @encrypted_string.nil?
      render json: { messsage: "No entry found for token #{params[:token]}" },
             status: :not_found
    end
  end

  def encrypted_string_params
    params.require(:encrypted_string).permit(:value)
  end

  def still_processing?
    processing = false
    @status_message = if processing = Sidekiq::ScheduledSet.new.size > 0
                        "Key rotation has been queued"
                      elsif processing = Sidekiq::Workers.new.size > 0
                        "Key rotation is in progress"
                      else
                        "No key rotation queued or in progress"
                      end
    processing
  end
end
