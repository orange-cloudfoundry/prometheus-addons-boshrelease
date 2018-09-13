#!/usr/bin/env bash
set -eu

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

timeout=120
reached=0
while [ ${timeout} -gt 0 ] && [ ${reached} -ne 1 ]
do
	if nc -z 127.0.0.1 "${PORT}"
	then
		[ ${reached} -eq 0 ] && reached=1
	fi
	if [ ${reached} -eq 0 ]
	then
		sleep 1
		timeout=$(($timeout-1))
	fi
done
[ ${timeout} -le 0 ] \
			&& echo "Cannot connect to mongodb on localhost:${PORT}. Timeout reached" \
			&& exit 1

<%- if p('mongodb.tls') == true -%>
MONGO_CMD="mongo --ssl --sslCAFile <%= p('mongodb.tls_ca') %> --quiet"
CONNECT_STRING="mongodb://<%= p('mongodb.root.username') %>:<%= p('mongodb.root.password') %>@127.0.0.1:${PORT}/admin?authSource=admin&ssl=true"
<%- else -%>
MONGO_CMD="mongo --quiet"
CONNECT_STRING="mongodb://<%= p('mongodb.root.username') %>:<%= p('mongodb.root.password') %>@127.0.0.1:${PORT}/admin?authSource=admin"
<%- end -%>  

# wait for root user availability

root_initialized=0
timeout=120
set -x
while [ ${timeout} -gt 0 -a ${root_initialized} -eq 0 ]
do
    root_initialized=`${MONGO_CMD} ${CONNECT_STRING} \
    	--eval 'Mongo()'||echo ""`
    
    if [ "$(echo ${root_initialized}|grep 'connection to 127.0.0.1:${PORT}'|wc -l)" -eq 0 ] 
	then
		sleep 1
		timeout=$(($timeout-1))
		root_initialized=0
	fi
done

[ ${timeout} -le 0 ] \
			&& echo "Cannot connect to mongodb on localhost:${PORT} with <%= p('mongodb.root.username') %> user. Timeout reached" \
			&& exit 1

# Perform user creation on master node only

if [ "$(${MONGO_CMD} ${CONNECT_STRING} --eval 'rs.isMaster().ismaster')" == "true" ]
then
     ${MONGO_CMD} ${CONNECT_STRING} < $JOB_DIR/js/create_clustermonitor_user.js
fi
