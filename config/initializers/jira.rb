jira_options = {
  :site => $app_config.jira.host,
  :username => $app_config.jira.username,
  :password => $app_config.jira.password,
  :context_path => $app_config.jira.context_path,
  :auth_type => :basic,
  :use_ssl => $app_config.jira.use_ssl
}

$jira = JIRA::Client.new(jira_options)
