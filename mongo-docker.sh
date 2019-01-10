#! /bin/bash

shard_nums=7;

echo "version: '3.3'" > docker-compose.yml
echo "services:" >> docker-compose.yml

for (( c=1; c<=$shard_nums; c++ ))
do
   echo "    shard$c:" >> docker-compose.yml;
   echo "        container_name: shard$c:" >> docker-compose.yml;
   echo "        image: mongo" >> docker-compose.yml;
   echo "        command: mongod --shardsvr --replSet shard --dbpath /data/db --port 27018" >> docker-compose.yml
   echo "        ports:" >> docker-compose.yml
   echo "            - 270${c}8:27018" >> docker-compose.yml
   echo "        expose:" >> docker-compose.yml
   echo "            - '27018'" >> docker-compose.yml
   echo "        environment:" >> docker-compose.yml
   echo "            TERM: xterm" >> docker-compose.yml
   echo "        volumes:" >> docker-compose.yml
   echo "            - /etc/localtime:/etc/localtime:ro" >> docker-compose.yml
   echo "            - /mongo_cluster/data${c}:/data/db" >> docker-compose.yml
done

for (( c=1; c<=3; c++ ))
do
   echo "    mongocfg$c:" >> docker-compose.yml
   echo "        container_name: mongocfg$c" >> docker-compose.yml
   echo "        image: mongo" >> docker-compose.yml
   echo "        command: mongod --configsvr --replSet mongors${c}conf --dbpath /data/db --port 27017" >> docker-compose.yml
   echo "        environment:" >> docker-compose.yml
   echo "            TERM: xterm" >> docker-compose.yml
   echo "        expose:" >> docker-compose.yml
   echo "            - '27017'" >> docker-compose.yml
   echo "        volumes:" >> docker-compose.yml
   echo "            - /etc/localtime:/etc/localtime:ro" >> docker-compose.yml
   echo "            - /mongo_cluster/config${c}:/data/db" >> docker-compose.yml
done


echo "    mongos1:" >> docker-compose.yml
echo "        container_name: mongos1" >> docker-compose.yml
echo "        image: mongo" >> docker-compose.yml
echo "        depends_on:" >> docker-compose.yml
echo "            - mongocfg1" >> docker-compose.yml
echo "            - mongocfg2" >> docker-compose.yml
echo "            - mongocfg3" >> docker-compose.yml

for (( c=1; c<=$shard_nums; c++ ))
do
   echo "            - shard$c" >> docker-compose.yml
done

echo "        command: mongos --configdb mongors1conf/mongocfg1:27017,mongocfg2:27017,mongocfg3:27017 --port 27017 --bind_ip_all" >> docker-compose.yml
echo "        ports:" >> docker-compose.yml
echo "            - 27017:27017" >> docker-compose.yml
echo "        expose:" >> docker-compose.yml
echo "            - '27017'" >> docker-compose.yml
echo "        volumes:" >> docker-compose.yml
echo "            - /etc/localtime:/etc/localtime:ro" >> docker-compose.yml

docker-compose build
docker0compose up -d

docker exec -it mongocfg1 bash -c "echo 'rs.initiate({_id: \"mongors1conf\",configsvr: true, members: [{ _id : 0, host : \"mongocfg1\" },{ _id : 1, host : \"mongocfg2\" }, { _id : 2, host : \"mongocfg3\" }]})' | mongo"

command="echo 'rs.initiate({_id : \"shard\", members: ["

for (( c=1; c<=$shard_nums; c++ ))
do
   command=$command"{ _id : ${c-1}, host : \"shard$c:27018\" },"
done

command=$command"]})' | mongo --port 27018"

docker exec -it shard1 bash -c command

for (( c=1; c<=$shard_nums; c++ ))
do
   docker exec -it mongos1 bash -c "echo 'sh.addShard(\"shard/shard$c:27018\")' | mongo "
done
