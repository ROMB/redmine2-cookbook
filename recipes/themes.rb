#
# Cookbook Name:: redmine2
# Recipe:: themes
#
# Copyright 2014, Anton Minin
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

themes = node[:redmine][:themes]

if !themes.nil? && !themes.empty?
  themes.each do |theme|
    case theme[:type]
    when 'git' then
      rev = theme[:revision] || 'master'
      git "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/public/themes/#{theme[:name]}" do
        repository theme[:source]
        revision rev
        action :sync
      end

    when 'zip' then
      zipfile = File.basename(theme[:source])
      # FC041
      bash "Deploy redmine theme #{theme[:name]}" do
        cwd '/tmp'
        code <<-EOF
          wget #{theme[:source]}
          unzip #{zipfile}
          mv #{theme[:name]} #{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/public/themes/#{theme[:name]}
          rm -rf #{zipfile}
        EOF
        not_if { ::File.exist?("#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/public/themes/#{theme[:name]}") }
      end
    end
  end
end
