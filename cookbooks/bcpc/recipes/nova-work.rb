#
# Cookbook Name:: bcpc
# Recipe:: nova-head
#
# Copyright 2013, Bloomberg L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "bcpc::openstack"
include_recipe "bcpc::ceph-work"

ruby_block "initialize-nova-work-config" do
    block do
        make_config('ssh-nova-private-key', %x[printf 'y\n' | ssh-keygen -t rsa -N '' -q -f /dev/stdout | sed -e '1,1d' -e 's/.*-----BEGIN/-----BEGIN/'])
        make_config('ssh-nova-public-key', %x[echo "#{get_config('ssh-nova-private-key')}" | ssh-keygen -y -f /dev/stdin])
    end
end

case node['platform']
when "centos","redhat","fedora","suse"
  include_recipe "bcpc::nova-work-yum"
when "debian","ubuntu"
  include_recipe "bcpc::nova-work-apt"
end
