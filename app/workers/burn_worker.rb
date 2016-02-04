class BurnWorker
  include Sidekiq::Worker

  sidekiq_options queue: :codeburner, retry: 5, backtrace: true

  def perform(burn_id)
    burn = Burn.find(burn_id)
    burn.ignite
  end

end
