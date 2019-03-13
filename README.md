# prometheus-addons-boshrelease



## Features

This is a bosh release providing the following tools from 

* grafana's dashboards

  a set of [Grafana](https://grafana.com/) dashboards for database and system monitoring using Prometheus datasource based on [percona](https://www.percona.com/) dashboard and updated to fit bosh deployment and work without PMM need

  *source: https://github.com/percona/grafana-dashboards*

* mongodb_exporter (**v0.7.0**) :

  A MongoDB exporter for [prometheus](https://prometheus.io/)

  *source: https://github.com/percona/mongodb_exporter.git*

The release is actually focused on [mongodb](https://www.mongodb.com), but is still subject to evolve if there is any need. 



## Upload the last release

* get and upload the last release from github

  ```shell
  wget https://github.com/jraverdy-orange/prometheus-addons-boshrelease/releases/download/v2.0.0/prometheus-addons-v2.0.0.tgz
  
  bosh upload-release prometheus-addons-v2.0.0.tgz
  ```

  

* get the sources from github to recover needed opsfiles

  ```shell
  git clone https://github.com/jraverdy-orange/prometheus-addons-boshrelease.git
  ```

  

## Adding the dashboards to prometheus

The release provides the needed opsfile to include the attached dashboards

just add the following to the prometheus-boshrelease deployment command:

```shell
bosh deploy ... 
...
-o prometheus-addons-boshrelease/opsfiles/use-mongodb-dashboards.yml 
```



## Including the exporter to the mongodb deployment

The release provide to opsfiles considering if we use TLS or not for mongodb connection

**You should have to modify provided opsfiles to fit your instances group name**

```
path: /instance_groups/name=mongo/jobs/name=mongodb_exporter?
```

