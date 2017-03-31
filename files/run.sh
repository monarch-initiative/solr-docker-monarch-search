#!/bin/bash

set -e

/data/solr-6.2.1/bin/solr start
/data/solr-6.2.1/bin/solr create -c search 
/data/solr-6.2.1/bin/solr stop
rm /data/solr-6.2.1/server/solr/search/conf/managed-schema 
cd /data/golr-schema && mvn exec:java -Dexec.mainClass="org.bbop.cli.Main" -Dexec.args="-c /data/monarch-app/conf/golr-views/monarch-search-config.yaml -o /data/solr-6.2.1/server/solr/search/conf/schema.xml"
wget -O /data/scigraph.tgz https://scigraph-ontology-dev.monarchinitiative.org/static_files/scigraph.tgz 
#wget -O /data/scigraph.tgz https://scigraph-data-dev.monarchinitiative.org/static_files/scigraph.tgz 
cd /data/ && tar xzfv scigraph.tgz 
cd /data/golr-loader && mvn exec:java -Dexec.mainClass="org.monarch.golr.SimpleLoaderMain" -Dexec.args="-g /data/graph.yaml -o output.json"
/data/solr-6.2.1/bin/solr start
/data/solr-6.2.1/bin/post -c search /data/golr-loader/output.json
/data/solr-6.2.1/bin/solr stop
cd /data/solr-6.2.1/server/solr && tar cfv search.tar search/
cp /data/solr-6.2.1/server/solr/search.tar /solr
