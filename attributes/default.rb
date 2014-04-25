default['play_app']['installation_user'] = "play"
# default['play_app']['installation_dir'] = "/home/play/"
default['play_app']['dist_url'] = "http://eladron.e-technik.uni-ulm.de/execwarefrontend"
default['play_app']['dist_name'] = "executionware-1.0-SNAPSHOT"
default['play_app']['application_name'] = 'executionware'
#default['play_app']['config_dir'] = '/opt/configuration'
#default['play_app']['vm_options']='-Xms512M -Xmx1024M -Xss1M -XX:MaxPermSize=512M'
default['play_app']['pid_file_path']="/var/run/play.pid"
default['play_app']['application_secret_key']="Your Secret Key here"

default['play_app']['dbUser']="play"
default['play_app']['dbPass']="playSecretDatabasePassword"
default['play_app']['dbName']="play"

default['play_app']['play_log_level']="INFO"  
default['play_app']['app_log_level']="DEBUG"
default['play_app']['language']="en"

default['play_app']['cloudify_url'] = "http://eladron.e-technik.uni-ulm.de/cloudify"
default['play_app']['cloudify_release'] = "gigaspaces-cloudify-2.7.0-ga-b5996"
default['play_app']['cloudify_name'] = "gigaspaces-cloudify-2.7.0-ga"


override['java']['jdk_version'] = "7"
