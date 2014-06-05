#
# Cookbook Name:: nexus
# Library:: chef_nexus
#
# Author:: Kyle Allan (<kallan@riotgames.com>)
# Copyright 2013, Riot Games
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
class Chef
  module Nexus
    DEFAULT_DATABAG       = "nexus"
    SSL_FILES_DATABAG     = "nexus_ssl_files"
    WILDCARD_DATABAG_ITEM = "_wildcard"
    
    class << self

      # Loads the nexus encrypted data bag item. Attempts to load a data bag item
      # named after the current Chef environment. If one is not found, an item named
      # "_wildcard" will be used.
      # 
      # @param node [Chef::Node] the Chef node
      # 
      # @return [Chef::Mash] the data bag item as a Mash with indifferent access
      def get_nexus_data_bag(node)
        encrypted_data_bag_for(node, DEFAULT_DATABAG)
      end

      # Loads the credentials entry from the nexus data bag item
      # 
      # @param  node [Chef::Node] the Chef node
      # 
      # @return [Chef::Mash] the credentials entry in the data bag item
      def get_credentials(node)
        get_nexus_data_bag(node)[:credentials]
      end

      # Loads the license entry from the nexus data bag item
      # 
      # @param  node [Chef::Node] the Chef node
      # 
      # @return [Chef::Mash] the license entry in the data bag item
      def get_license(node)
        get_nexus_data_bag(node)[:license]
      end

      # Loads the nexus_ssl_files encrypted data bag item for this node.
      # 
      # @example
      #   knife data bag load nexus_ssl_files _wildcard --secret-file
      # 
      # @param  node [Chef::Node] the Chef node
      # 
      # @return [Chef::Mash] the loaded data bag item
      def get_ssl_files_data_bag(node)
        encrypted_data_bag_for(node, SSL_FILES_DATABAG)
      end

      # Creates and returns an instance of a NexusCli::RemoteFactory that
      # will be authenticated with the info inside the credentials data bag
      # item.
      # 
      # @param  node [Chef::Node] the node
      # 
      # @return [NexusCli::RemoteFactory] a connection to a Nexus server
      def nexus(node)
        require 'nexus_cli'
        credentials_entry = get_credentials(node)
        default_credentials = credentials_entry["default_admin"]
        updated_credentials = credentials_entry["updated_admin"]

        url = generate_nexus_url(node)

        overrides = {"url" => url, "repository" => node[:nexus][:cli][:repository]}
        if Chef::Config[:solo]
          begin
            merged_credentials = overrides.merge(default_credentials)
            NexusCli::RemoteFactory.create(merged_credentials, node[:nexus][:cli][:ssl][:verify])
          rescue NexusCli::PermissionsException, NexusCli::CouldNotConnectToNexusException, NexusCli::UnexpectedStatusCodeException => e
            merged_credentials = overrides.merge(updated_credentials)
            NexusCli::RemoteFactory.create(merged_credentials, node[:nexus][:cli][:ssl][:verify])
          end
        else
          if node[:nexus][:cli][:default_admin_credentials_updated]
            credentials = credentials_entry["updated_admin"]
          else
            credentials = credentials_entry["default_admin"]
          end
          merged_credentials = overrides.merge(credentials)
          NexusCli::RemoteFactory.create(merged_credentials, node[:nexus][:cli][:ssl][:verify])
        end
      end

      # Checks to ensure the Nexus server is available. When
      # it is unavailable, the Chef run is failed. Otherwise
      # the Chef run continues.
      # 
      # @param  node [Chef::Node] the Chef node
      # 
      # @return [NilClass]
      def ensure_nexus_available(node)
        Chef::Application.fatal!("Could not connect to Nexus. Please ensure Nexus is running.") unless Chef::Nexus.nexus_available?(node)
      end

      # Attempts to connect to the Nexus and retries if a connection 
      # cannot be made.
      # 
      # @param  node [Chef::Node] the node
      # 
      # @return [Boolean] true if a connection could be made, false otherwise
      def nexus_available?(node)
        retries = node[:nexus][:cli][:retries]
        begin
          remote = anonymous_nexus_remote(node)
          return remote.status['state'] == 'STARTED'
        rescue Errno::ECONNREFUSED, NexusCli::CouldNotConnectToNexusException, NexusCli::UnexpectedStatusCodeException => e
          if retries > 0
            retries -= 1
            Chef::Log.info "Could not connect to Nexus, #{retries} attempt(s) left"
            sleep node[:nexus][:cli][:retry_delay]
            retry
          end
          return false
        end
      end

      # Checks the Nexus users credentials and returns false if they
      # have been changed.
      # 
      # @param  username [String] the Nexus username
      # @param  password [String] the Nexus password
      # @param  node [Chef::Node] the Chef node
      # 
      # @return [Boolean] true if a connection can be made, false otherwise
      def check_old_credentials(username, password, node)
        require 'nexus_cli'
        url = generate_nexus_url(node)
        overrides = {"url" => url, "repository" => node[:nexus][:cli][:repository], "username" => username, "password" => password}
        begin
          nexus = NexusCli::RemoteFactory.create(overrides, node[:nexus][:cli][:ssl][:verify])
          true
        rescue NexusCli::PermissionsException, NexusCli::CouldNotConnectToNexusException, NexusCli::UnexpectedStatusCodeException => e
          false
        end
      end

      # Returns a 'safe-for-Nexus' identifier by replacing
      # spaces with underscores and downcasing the entire
      # String.
      # 
      # @param  nexus_identifier [String] a Nexus identifier
      # 
      # @example
      #   Chef::Nexus.parse_identifier("Artifacts Repository") => "artifacts_repository"
      # 
      # @return [String] a safe-for-Nexus version of the identifier
      def parse_identifier(nexus_identifier)
        nexus_identifier.gsub(" ", "_").downcase
      end

      def decode(value)
        require 'base64'
        Base64.decode64(value)
      end

      private


        # Creates a new instance of a Nexus connection using only
        # the URL to the local server. This connection is anonymous.
        #
        # @param  node [Chef::Node] the Chef node
        #
        # @return [NexusCli::BaseRemote] a NexusCli remote class
        def anonymous_nexus_remote(node)
          require 'nexus_cli'
          NexusCli::RemoteFactory.create({'url' => generate_nexus_url(node)}, node[:nexus][:cli][:ssl][:verify])
        end

        def generate_nexus_url(node)
          if node[:nexus][:app_server_proxy][:ssl][:enabled]
            "https://localhost:#{node[:nexus][:ssl][:port]}#{node[:nexus][:context_path]}"
          else
            "http://localhost:#{node[:nexus][:port]}#{node[:nexus][:context_path]}"
          end
        end

        def encrypted_data_bag_for(node, data_bag)
          @encrypted_data_bags = {} unless @encrypted_data_bags

          if @encrypted_data_bags[data_bag].nil?
            data_bag_item = encrypted_data_bag_item(node, data_bag, node.chef_environment)
            data_bag_item ||= encrypted_data_bag_item(node, data_bag, WILDCARD_DATABAG_ITEM)
            @encrypted_data_bags[data_bag] = data_bag_item
          end          

          if @encrypted_data_bags[data_bag]
            return @encrypted_data_bags[data_bag]
          end
          raise Nexus::EncryptedDataBagNotFound.new(data_bag)
        end

        def encrypted_data_bag_item(node, data_bag, data_bag_item)
          if node[:nexus][:use_chef_vault]
            item = ChefVault::Item.load(data_bag, data_bag_item)
          else
            item = Chef::EncryptedDataBagItem.load(data_bag, data_bag_item)
          end
          Mash.from_hash(item.to_hash)
        rescue Net::HTTPServerException => e
          nil
        end
    end
  end
end
