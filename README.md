# percona-tools-boshrelease

**Readme writing in progress**



## Features

This is a bosh release providing the following tools from [percona](https://www.percona.com/)

* percona's grafana dashboards (**v1.15.0**)

  a set of [Grafana](https://grafana.com/) dashboards for database and system monitoring using Prometheus datasource

  *source: https://github.com/percona/grafana-dashboards*

* mongodb_exporter (**v0.6.2**) :

  A MongoDB exporter for [prometheus](https://prometheus.io/)

  *source: https://github.com/percona/mongodb_exporter.git*

The release is actually focused on [mongodb](https://www.mongodb.com), but is still subject to evolve if there is any need. 



## Upload the last release



* get the sources from github

  ```shell
  git clone https://github.com/jraverdy-orange/percona-tools-boshrelease.git
  ```

  

## Adding the dashboards to prometheus

The release provides the needed opsfile to include the attached dashboards

just add the following to the prometheus-boshrelease deployment command:

```shell
bosh deploy ... 
...
-o percona-tools-boshrelease/opsfiles/use-percona-dashboards.yml 
```



## Including the exporter to the mongodb deployment

The release provide to opsfiles considering if we use TLS or not for mongodb connection

**You should have to modify provided opsfiles to fit your instances group name**

```
path: /instance_groups/name=mongo/jobs/name=mongodb_exporter?
```

