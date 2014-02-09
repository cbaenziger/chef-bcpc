# proxy setup
#
# Make sure this file defines CURL in any case
# Only define http_proxy if you will be using a proxy
#

# sample setup using a local squid cache at 10.0.1.2 - the hypervisor
# change to reflect your real proxy info
#export PROXY="10.0.1.2:3128"

export CURL='curl'
if [ -n "$PROXY" ]; then
  echo "Using a proxy at $PROXY"

  local_ips=$(ip addr list |grep 'inet '|sed -e 's/.* inet //' -e 's#/.*#,#')

  export http_proxy=http://${PROXY}
  export https_proxy=https://${PROXY}
  export no_proxy="$(sed 's/ //g' <<< $local_ips)localhost,$(hostname),$(hostname -f),.$(domainname),10.0.100."
  export NO_PROXY="$(sed 's/ //g' <<< $local_ips)localhost,$(hostname),$(hostname -f),.$(domainname),10.0.100."

  # to ignore SSL errors
  export GIT_SSL_NO_VERIFY=true
  export CURL="curl -k -x http://${PROXY}"
fi

# load_chef_server_ip
# Arguments: None
# Pre-Condition: Chef has been run on bootstrap node
# Post-Conditions: sets $chef_server_ip
# Raises: Error if Knife fails to run
# the bootstrap node may have multiple IP's we use Chef to figure out what is registered on the management net
function load_chef_server_ip {
  export chef_server_ip=$(knife node show $(hostname) -a 'bcpc.management.ip' | tail -1 | sed 's/.* //')
  if [[ -z "$chef_server_ip" ]]; then
    echo 'Failed to load $chef_server_ip!' > /dev/stderr
    exit 1
  fi
}
