#
# Cookbook Name:: nexus
# Resource:: download_indexes_task
#
# Author:: Leo Simons (<lsimons@schubergphilis.com>)
# Copyright 2013, Riot Games
# Copyright 2015, Schuberg Philis
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

actions :create, :delete # todo :update
default_action :create

attribute :name,                :kind_of => String, :name_attribute => true
attribute :type,                :kind_of => Symbol, :required => true
attribute :schedule,            :kind_of => String, :default => 'daily'
attribute :enabled,             :kind_of => :Boolean, :default => true
attribute :start_date,          :kind_of => [String, Numeric], :default => nil
attribute :recurring_time,      :kind_of => String, :default => '00:00'
attribute :repository_id,       :kind_of => String, :default => 'all_repo'

# todo custom code to properly compare :type with the below type-specifics
# :empty_trash
attribute :older_than_days,     :kind_of => Numeric, :default => 10

# :download_nuget_feed
attribute :clear_cache,         :kind_of => :Boolean, :default => false
attribute :all_versions,        :kind_of => :Boolean, :default => false
attribute :retries,             :kind_of => Numeric, :default => 3

# :snapshot_remover
attribute :min_snapshots,       :kind_of => Numeric, :default => 10
attribute :remove_older,        :kind_of => Numeric, :default => 10
attribute :remove_if_release,   :kind_of => :Boolean, :default => false
attribute :grace_after_release, :kind_of => Numeric, :default => nil
attribute :delete_immediately,  :kind_of => :Boolean, :default => false
