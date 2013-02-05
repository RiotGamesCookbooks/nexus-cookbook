#
# Cookbook Name:: nexus
# Resource:: proxy
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

actions :enable, :disable, :add_trusted_key, :delete_trusted_key

attribute :name, :kind_of        => String, :name_attribute => true
attribute :id, :kind_of          => String
attribute :host, :kind_of        => String
attribute :port, :kind_of        => Fixnum
attribute :certificate, :kind_of => String
attribute :description, :kind_of => String
