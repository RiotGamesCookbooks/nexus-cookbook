#
# Cookbook Name:: nexus
# Resource:: user
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

actions :create, :update, :delete, :change_password
default_action :create

attribute :username, :kind_of     => String, :name_attribute => true
attribute :first_name, :kind_of   => String
attribute :last_name, :kind_of    => String
attribute :email, :kind_of        => String
attribute :enabled, :kind_of      => [TrueClass, FalseClass]
attribute :password, :kind_of     => String
attribute :old_password, :kind_of => String
attribute :roles, :kind_of        => Array, :default => []
