class RotateKeyWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    current_primary_key = DataEncryptingKey.primary
    current_primary_key.update(primary: false) unless current_primary_key.nil?
    encrypting_key = DataEncryptingKey.generate!(primary: true)

    EncryptedString.find_each(batch_size: 100) do |string|
      string.rotate_key(string.value)
      string.save!
    end

    DataEncryptingKey.where(primary: false).delete_all
  end
end
