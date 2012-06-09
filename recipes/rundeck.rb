include_recipe 'nexus'

plugin = {
  'name' => 'rundeck',
  'url' => 'https://github.com/downloads/vbehar/nexus-rundeck-plugin/nexus-rundeck-plugin-1.2.2.2-bundle.zip',
  'version' => '1.2.2.2'
} 

plugin_repo_path = "/var/lib/nexus/plugin-repository"
plugin_path = "#{plugin_repo_path}/nexus-#{plugin['name']}-plugin-#{plugin['version']}"

ark "nexus plugin #{plugin['name']}" do
  url plugin['url']
  path plugin_path
  owner 'nexus'
  group 'nexus'
  action :dump
end
