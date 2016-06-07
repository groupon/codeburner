class AddBranchAndPullRequestToBurns < ActiveRecord::Migration
  def change
    add_column :burns, :branch, :string
    add_column :burns, :pull_request, :string

    Burn.update_all(:branch => "master")
  end
end
