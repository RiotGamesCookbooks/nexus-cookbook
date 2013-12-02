Vagrant.configure("2") do |config|

  config.vm.hostname = "nexus-berkshelf"

  # Requires the vagrant-berkshelf plugin
  config.berkshelf.enabled = true

  config.vm.box = "Berkshelf-CentOS-6.3-x86_64-minimal"
  config.vm.box_url = "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box"
  config.vm.network :private_network, ip: "192.168.33.10"
  config.vm.network :forwarded_port, guest: 8081, host: 8081
  config.vm.network :forwarded_port, guest: 8443, host: 8443

  config.vm.provision :chef_solo do |chef|
    chef_dir = File.join(Dir.home, ".chef")
    chef.data_bags_path = File.join(chef_dir, "data_bags")
    chef.encrypted_data_bag_secret_key_path = File.join(chef_dir, "encrypted_data_bag_secret")

    chef.json = {
      :nexus => {
        :cli => {
          :ssl => {
            :verify => false
          }
        },
        :app_server_proxy => {
          :use_self_signed => true
        }
      }
    }

    chef.run_list = [
      "recipe[nexus::default]"
    ]
  end
end
