class AddDefaultBurnUser < ActiveRecord::Migration
  def change
    Burn.all.each do |burn|
      burn.update(:user => User.first) unless burn.user
    end
  end
end
