#
# Cookbook Name:: nexus
# Library:: chef_nexus_errors
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
    class NexusError < StandardError; end

    class EncryptedDataBagNotFound < NexusError
      def initialize(data_bag_item)
        @data_bag_item = data_bag_item
      end

      def message
        "Unable to locate the Nexus encrypted data bag '#{DEFAULT_DATABAG}' or data bag item #{@data_bag_item}"
      end
    end

    class InvalidDataBagItem < NexusError
      def initialize(data_bag, missing)
        @data_bag = data_bag
        @missing = missing
      end

      def message
        "Your data bag '#{@data_bag}' is missing a #{@missing} element."
      end
    end
  end
end
