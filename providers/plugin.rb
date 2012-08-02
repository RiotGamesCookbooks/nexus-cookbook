action :install do
  plugins = [new_resource.name] if new_resource.name.kind_of? String
  plugins = new_resource.name if new_resource.name.kind_of? Array
  available_plugins = Dir.entries("#{node[:nexus][:home]}/nexus/WEB-INF/optional-plugins")

  plugins.each do |plugin|
    matched_plugin = available_plugins.find{|plugin_dir| plugin_dir.match(plugin)}

    if matched_plugin.nil? || matched_plugin.empty?
      log "Plugin #{plugin} did not match any optional-plugins for your Nexus installation."
    else
      log "Adding symlink #{node[:nexus][:home]}/nexus/WEB-INF/plugin-repository/#{matched_plugin} to #{node[:nexus][:home]}/nexus/WEB-INF/optional-plugins/#{matched_plugin}"
      link "#{node[:nexus][:home]}/nexus/WEB-INF/plugin-repository/#{matched_plugin}" do
        to "#{node[:nexus][:home]}/nexus/WEB-INF/optional-plugins/#{matched_plugin}"
      end
    end
  end
end