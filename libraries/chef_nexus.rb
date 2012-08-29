#
# Cookbook Name:: nexus
# Library:: chef_nexus
#
# Copyright 2011, DTO Solutions, Inc.
# Copyright 2010, Opscode, Inc.
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
    DATABAG = "nexus"
    CREDENTIALS_DATABAG_ITEM = "credentials"
    LICENSE_DATABAG_ITEM = "license"
    CERTIFICATES_DATABAG_ITEM = "certificates"
    
    class << self
      def get_credentials_data_bag
        begin
          data_bag_item = Chef::EncryptedDataBagItem.load(DATABAG, CREDENTIALS_DATABAG_ITEM)
        rescue Net::HTTPServerException => e
          raise Nexus::EncryptedDataBagNotFound.new(CREDENTIALS_DATABAG_ITEM)
        end
        validate_credentials_data_bag(data_bag_item)
        data_bag_item
      end

      def get_license_data_bag
        begin
          data_bag_item = Chef::EncryptedDataBagItem.load(DATABAG, LICENSE_DATABAG_ITEM)
        rescue Net::HTTPServerException => e
          raise Nexus::EncryptedDataBagNotFound.new(LICENSE_DATABAG_ITEM)
        end
        validate_license_data_bag(data_bag_item)
        data_bag_item
      end

      def get_certificates_data_bag(node)
        begin
          data_bag_item = Chef::EncryptedDataBagItem.load(DATABAG, CERTIFICATES_DATABAG_ITEM)
        rescue Net::HTTPServerException => e
          raise Nexus::EncryptedDataBagNotFound.new(CERTIFICATES_DATABAG_ITEM)
        end
        validate_certificates_data_bag(data_bag_item, node)
        data_bag_item
      end

      private

        def validate_credentials_data_bag(data_bag_item)
          raise Nexus::InvalidDataBagItem.new(CREDENTIALS_DATABAG_ITEM, "default_admin") unless data_bag_item["default_admin"]
          raise Nexus::InvalidDataBagItem.new(CREDENTIALS_DATABAG_ITEM, "updated_admin") unless data_bag_item["updated_admin"]
        end

        def validate_license_data_bag(data_bag_item)
          raise Nexus::InvalidDataBagItem.new(LICENSE_DATABAG_ITEM, "file") unless data_bag_item["file"]
        end

        def validate_certificates_data_bag(data_bag_item, node)
          node[:nexus][:smart_proxy][:trusted_servers].each do |server|
            raise Nexus::InvalidDataBagItem.new(CERTIFICATES_DATABAG_ITEM, server) unless data_bag_item[server]
            raise Nexus::InvalidDataBagItem.new(CERTIFICATES_DATABAG_ITEM, "#{server}::certificate") unless data_bag_item[server]["certificate"]
            raise Nexus::InvalidDataBagItem.new(CERTIFICATES_DATABAG_ITEM, "#{server}::description") unless data_bag_item[server]["description"]
          end
        end
    end
  end
end