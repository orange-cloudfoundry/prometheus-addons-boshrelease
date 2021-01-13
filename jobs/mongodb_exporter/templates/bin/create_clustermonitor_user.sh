#!/usr/bin/env bash
set -eu

# create file content only when clustermonitor user should be created
<%- if p('mongodb.clustermonitor.create') == true -%>

<%-
  require "shellwords"

  def esc(x)
    Shellwords.shellescape(x)
  end

  _instances = ''
  link('exporter').instances.each do |instance|
    _instances = "#{_instances}#{instance.address} "
  end
  # remove last space
  instances = _instances[0..-2]
  current_ip = spec.ip
%>

JOB_DIR=/var/vcap/jobs/mongodb_exporter

# Add all packages' /bin & /sbin into $PATH
for package_bin_dir in $(ls -d /var/vcap/packages/*/bin)
do
  export PATH=${package_bin_dir}:${PATH}
done

LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-''} # default to empty
for package_lib_dir in $(ls -d /var/vcap/packages/*/lib /var/vcap/packages/*/lib64)
do
  LD_LIBRARY_PATH=${package_lib_dir}:${LD_LIBRARY_PATH}
done
export LD_LIBRARY_PATH

<%- if_p('mongodb.uri') do |uri| %>
PORT=$(echo <%= uri %>|sed -e "s/^.*@[^:]*:\([0-9]*\).*/\1/")
<%- end %>
# waiting for port availability

Timeout=120
reached=0
while [ ${Timeout} -gt 0 ] && [ ${reached} -ne 1 ]
do
	if nc -z 127.0.0.1 "${PORT}"
	then
		[ ${reached} -eq 0 ] && reached=1
	fi
	if [ ${reached} -eq 0 ]
	then
		sleep 1
		Timeout=$(($Timeout-1))
	fi
done
[ ${Timeout} -le 0 ] \
			&& echo "Cannot connect to mongodb on localhost:${PORT}. Timeout reached" \
			&& exit 1

MONGO_CMD="mongo"
<% if_p('mongodb.bin_path') do |bin_path| %>
MONGO_CMD="<%= bin_path %>/mongo"
<%- end %>

<%- if p('mongodb.tls') == true -%>
MONGO_CMD="$MONGO_CMD --ssl --sslCAFile <%= p('mongodb.tls_ca') %> --quiet"
CONNECT_STRING="mongodb://<%= p('mongodb.root.username') %>:<%= p('mongodb.root.password') %>@127.0.0.1:${PORT}/admin?authSource=admin&ssl=true"
<%- else -%>
MONGO_CMD="$MONGO_CMD --quiet"
CONNECT_STRING="mongodb://<%= p('mongodb.root.username') %>:<%= p('mongodb.root.password') %>@127.0.0.1:${PORT}/admin?authSource=admin"
<%- end -%>  

# wait for root user availability

root_initialized=0
Timeout=120
while [ ${Timeout} -gt 0 -a ${root_initialized} -eq 0 ]
do
    root_initialized=1
    
    if [ "$(echo $(${MONGO_CMD} ${CONNECT_STRING} \
    		--eval 'Mongo("'127.0.0.1:${PORT}'")'||echo 1)|grep 'connection to 127.0.0.1:'${PORT}|wc -l)" -eq 0 ] 
	then
		sleep 1
		Timeout=$(($Timeout-1))
		root_initialized=0
	fi
done

[ ${Timeout} -le 0 ] \
			&& echo "Cannot connect to mongodb on localhost:${PORT} with <%= p('mongodb.root.username') %> user. Timeout reached" \
			&& exit 1

# Perform user creation on master node only
Master_is_identified=0
Timeout=120
while [ ${Master_is_identified} -eq 0 -a ${Timeout} -gt 0 ]
do
	for i in <%= instances %>
	do
		CONNECT_STRING_CHECK=$(echo ${CONNECT_STRING}|sed -e "s/127.0.0.1/$i/")
		if [ "$(${MONGO_CMD} ${CONNECT_STRING_CHECK} --eval 'rs.isMaster().ismaster')" == "true" ]
		then
			Master=$i
			Master_is_identified=1
		fi
	done
	Timeout=$((Timeout-1))
done
[ ${Timeout} -le 0 ] \
			&& echo "Cannot find a valid master node within <%= instances %>. Timeout reached" \
			&& exit 1

if [ "${Master}" == "<%= esc(current_ip) %>" ]
then
    ${MONGO_CMD} ${CONNECT_STRING} $JOB_DIR/js/create_clustermonitor_user.js
fi

<%- end -%>