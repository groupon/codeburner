Octokit.configure do |c|
  if $app_config.github.api_endpoint
    c.api_endpoint = $app_config.github.api_endpoint
  end
end

$github = Octokit::Client.new(:access_token => $app_config.github.api_access_token)
