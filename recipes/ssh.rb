#
# Cookbook Name:: sys
# Recipe:: ssh
#
# Copyright 2012, Victor Penso
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

# default SSH daemon configuration copied from the original file
sshd_config = {
 "Port" => "22",
 "Protocol" => "2",
 "UsePrivilegeSeparation" => "yes",
 "KeyRegenerationInterval" => "3600",
 "ServerKeyBits" => "768",
 "SyslogFacility" => "AUTH",
 "LogLevel" => "INFO",
 "LoginGraceTime" => "120",
 "PermitRootLogin" => "no",
 "StrictModes" => "yes",
 "RSAAuthentication" => "yes",
 "PubkeyAuthentication" => "yes",
 "IgnoreRhosts" => "yes",
 "RhostsRSAAuthentication" => "no",
 "HostbasedAuthentication" => "no",
 "PermitEmptyPasswords" => "no",
 "ChallengeResponseAuthentication" => "no",
 "X11Forwarding" => "yes",
 "X11DisplayOffset" => "10",
 "PrintMotd" => "yes",
 "PrintLastLog" => "yes",
 "TCPKeepAlive" => "yes",
 "AcceptEnv" => "LANG LC_*",
 "Subsystem" => "sftp /usr/lib/openssh/sftp-server",
 "UsePAM" => "yes"
}

# only if SSH daemon configuration is defined
  package "openssh-server"
  service "ssh" do
    supports :reload => true
  end
  # overwrite the default configuration
  template '/etc/ssh/sshd_config' do
    source 'etc_ssh_sshd_config.erb'
    mode 0600
    variables :config => sshd_config
    notifies :reload, "service[ssh]"
    action :create
  end