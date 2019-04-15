# prometheus-addons-boshrelease



## Features

This is a bosh release providing the following tools from 

* grafana's dashboards

  a set of [Grafana](https://grafana.com/) dashboards for database and system monitoring using Prometheus datasource based on [percona](https://www.percona.com/) dashboard and updated to fit bosh deployment and work without PMM need

  *source: https://github.com/percona/grafana-dashboards*

* mongodb_exporter (**v0.7.0**) :

  A MongoDB exporter for [prometheus](https://prometheus.io/)

  *source: https://github.com/percona/mongodb_exporter.git*

* Alertmanager alerts files 

  *source: https://github.com/orange-cloudfoundry/mongodb_prometheus-dashboards_alerts-boshrelease*

  * **Note that alerting is actually only related to replicaset deployment and does not warn on any sharding specific metric**

The release is actually focused on [mongodb](https://www.mongodb.com), but is still subject to evolve if there is any need. 



## Upload the last release

* get and upload the last release from github

  ```shell
  wget https://github.com/jraverdy-orange/prometheus-addons-boshrelease/releases/download/v2.1.1/prometheus-addons-v2.1.1.tgz
  
  bosh upload-release prometheus-addons-v2.1.1.tgz
  ```

  

* get the sources from github to recover needed opsfiles, which are necessary on both prometheus and mongodb deployments

  ```shell
  git clone https://github.com/jraverdy-orange/prometheus-addons-boshrelease.git
  ```

  

## Adding the dashboards and alerts to grafana and alertmanager

The release provides the needed opsfile to include the attached dashboards

just add the following to the prometheus-boshrelease deployment command:

```shell
bosh deploy ... 
...
-o prometheus-addons-boshrelease/opsfiles/use-mongodb-dashboards-alerts.yml 
```



## Including the exporter to the mongodb deployment

The release provide to opsfiles considering if we use TLS or not for mongodb connection

**You should have to modify provided opsfiles to fit your instances group name**

```
path: /instance_groups/name=mongo/jobs/name=mongodb_exporter?
```

