#
# Cookbook Name:: mongodb
# Recipe:: replicaset
#
# Copyright 2011, edelight GmbH
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

node.set['mongodb']['is_replicaset'] = true
node.set['mongodb']['cluster_name'] = node['mongodb']['cluster_name']

include_recipe 'mongodb::install'
include_recipe 'mongodb::mongo_gem'
require 'etc'

if ::File.exist?("/data/admin.0")
  if ::File.stat("/data/admin.0").uid == 220
    data_uid = 0
  else
    data_uid = ::File.stat("/data/admin.0").uid
  end

  execute "Make sure that data directory has correct permissions" do
    command "chown -R #{node['mongodb']['user']} /data"
    not_if { ::Etc.getpwuid(data_uid).name == node['mongodb']['user'] }
  end
end

if ::File.exist?("/log/mongodb/mongodb.log")
  if ::File.stat("/log/mongodb/mongodb.log").uid == 220
    log_uid = 0
  else
    log_uid = ::File.stat("/log/mongodb/mongodb.log").uid
  end

  execute "Make sure that log directory has correct permissions" do
    command "chown -R #{node['mongodb']['user']} /log"
    not_if { ::Etc.getpwuid(log_uid).name == node['mongodb']['user'] }
  end
end

if ::File.exist?("/journal/prealloc.0")
  if ::File.stat("/journal/prealloc.0").uid == 220
    journal_uid = 0
  else
    journal_uid = ::File.stat("/journal/prealloc.0").uid
  end

  execute "Make sure that journal directory has correct permissions" do
    command "chown -R #{node['mongodb']['user']} /journal"
    not_if { ::Etc.getpwuid(journal_uid).name == node['mongodb']['user'] }
  end
end

unless node['mongodb']['is_shard']
  mongodb_instance node['mongodb']['instance_name'] do
    mongodb_type 'mongod'
    port         node['mongodb']['config']['port']
    logpath      node['mongodb']['config']['logpath']
    dbpath       node['mongodb']['config']['dbpath']
    replicaset   node
    enable_rest  node['mongodb']['config']['rest']
    smallfiles   node['mongodb']['config']['smallfiles']
  end
end

service node['mongodb']['instance_name'] do
  action :nothing
end
