#
# Cookbook Name:: sys
# Recipe:: ldap
#
# Copyright 2013, Matthias Pausch
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

unless node.sys.ldap.empty?
  %w(
    nslcd
    kstart
    libpam-ldapd
    libnss-ldapd
    ldap-utils
  ).each { |p| package p }

  node.set[:sys][:ldap][:servers] = [ node.sys.ldap.master, node.sys.ldap.slave ]

  # Environment variables for nslcd.  They mainly just configure k5start.
  template "/etc/default/nslcd" do
    source "etc_default_nslcd.conf.erb"
    user "root"
    group "root"
    mode 0644
    notifies :restart, "service[nslcd]", :delayed
    variables ({
        :servers => node.sys.ldap.servers,
        :searchbase => node.sys.ldap.searchbase,
        :realm => node.sys.ldap.realm.upcase,
      })
  end

  # Configuration for nslcd.  nlscd queries an ldap-server for user-information.
  template "/etc/nslcd.conf" do
    source "etc_nslcd.conf.erb"
    user "root"
    group "root"
    mode "0644"
    notifies :restart, "service[nslcd]", :delayed
    variables(
      :servers => node.sys.ldap.servers,
      :searchbase => node.sys.ldap.searchbase,
      :realm => node.sys.ldap.realm.upcase
    )
  end

  # The ldap.conf configuration file is used to set system-wide defaults for ldap-client applications
  template "/etc/ldap/ldap.conf" do
    source "etc_ldap_ldap.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :servers => node.sys.ldap.servers,
      :searchbase => node.sys.ldap.searchbase,
      :realm => node.sys.ldap.realm.upcase
    )
  end

  service "nslcd" do
    supports :restart => true
    action [:start, :enable]
  end

  # Should nscd run at all? Or just be removed from the system?
  service "nscd" do
    action [:stop, :disable]
  end
end
