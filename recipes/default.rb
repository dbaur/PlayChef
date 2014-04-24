#
# Author:: Sameer Arora (<sameera@bluepi.in>)
# Cookbook Name:: deploy-play
# Recipe:: default
#
# Copyright 2014, sameer11sep
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

# Modified_by:: Etienne Charlier (<etienne.charlier@cetic.be>)

include_recipe 'zip'

install_user          = "#{node[:play_app][:installation_user]}"
application_name      = "#{node[:play_app][:application_name]}"
dist_url              = "#{node[:play_app][:dist_url]}"
dist_name             = "#{node[:play_app][:dist_name]}"

def uid_of_user(username)
  node['etc']['passwd'].each do |user, data|
    if user = username
      return data['uid']
    end
    return 0
  end
end




if node.attribute?('installation_dir')
  installation_dir      = "#{node[:play_app][:installation_dir]}"
else
  installation_dir      = "/home/#{install_user}/#{application_name}/app"
end

if node.attribute?('config_dir')
  config_dir      = "#{node[:play_app][:config_dir]}"
else
  config_dir      = "/home/#{install_user}/#{application_name}/config"
end

install_user_uid = uid_of_user install_user

if node.attribute?('pid_file_path')
  pid_file_path      = "#{node[:play_app][:pid_file_path]}"
else
  pid_file_path      = "/run/user/#{install_user_uid}/#{application_name}.pid"
end



#Download the Distribution Artifact from remote location

user "#{install_user}" do
  action :create
  password "$6$.t9HpiQyyB$PfCWxk/Sjdd.i0L5Ka6nKKU40Vc8u7R..dQpzUClETcMEbtIn8T4T46fpbvAxKOxCuglHtFFCS9k8qGXoTe.20"
  shell "/bin/bash"
end

directory "#{installation_dir}" do
  action :create
  mode "0755"
  owner "#{install_user}"
  group "#{install_user}"
  recursive true
end

directory "#{config_dir}" do
  action :create
  mode "0755"
  owner "#{install_user}"
  group "#{install_user}"
  recursive true
end



remote_file "#{installation_dir}/#{application_name}.zip" do
  source "#{dist_url}/#{dist_name}.zip"
  owner install_user
  group install_user
  mode "0644"
  action :create
end

#Unzip the Artifact and copy to the destination , assign permissions to the start script
bash "unzip-#{application_name}" do
  cwd "/#{installation_dir}"
  code <<-EOH
    sudo rm -rf #{installation_dir}/#{application_name}
    sudo unzip #{installation_dir}/#{application_name}.zip
    sudo chmod +x #{installation_dir}/#{application_name}/start
    sudo rm #{installation_dir}/#{application_name}.zip
    sudo chown -R #{install_user}:#{install_user} #{installation_dir}
  EOH
end

#Create the Application Conf file
#Add/remove variables here and in the application.conf.erb file as per your requirements e.g Database settings 

template "#{config_dir}/prod.conf" do
  source "application.conf.erb"
  owner install_user
  group install_user
  variables({
                :applicationSecretKey => "#{node[:play_app][:application_secret_key]}",
                :dbDriver => "#{node[:play_app][:db_driver]}",
		:dbUrl => "#{node[:play_app][:db_url]}",
		:cloudify => "#{node[:play_app][:cloudify_path]}"
            })
end

#Define a logger file, change parameter values in attributes/default.rb as per your requirements

template "#{config_dir}/logger.xml" do
  source "logger.xml.erb"
  owner install_user
  group install_user
  variables({
                :configDir => "#{config_dir}",
                :application_name => "#{application_name}",
                :maxHistory => "#{node[:play_app][:max_logging_history]}",
                :playloggLevel => "#{node[:play_app][:play_log_level]}",
                :applicationLogLevel => "#{node[:play_app][:app_log_level]}"
            })
end

#Finally Define a Service for your Application to be kept under /etc/init.d 

template "/etc/init.d/#{application_name}" do
  source "initd.erb"
  owner "root"
  group "root"
  mode "0744"
  variables({
                :run_as =>  "#{install_user}",
                :name => "#{application_name}",
                :path => "#{installation_dir}/#{dist_name}",
                :pidFilePath => "#{node[:play_app][:pid_file_path]}",
                :options => "-Dconfig.file=#{config_dir}/prod.conf -Dpidfile.path=#{node[:play_app][:pid_file_path]} -Dlogger.file=#{config_dir}/logger.xml #{node[:play_app][:vm_options]}",
                :command => "bin/#{application_name}"
            })
end

service "#{application_name}" do
  supports :stop => true, :start => true, :restart => true
  action [ :enable, :restart ]
end







