# docker-relk
A docker container with redis logstash Elasticsearch and kibana

#Installation
First download the project

Then go where you store your dockerfile
```
$ cd C:\DockerFiles\elk-redis
```

```
$ ls
```

Build your image (it can takes some minutes : 7 on my pc)
```
$ docker build -t relki .
```

You can see your image :
```
$ docker images
```

Then create your container (** this is the most important step **)
```
$ docker run -h relk -d --name relk -p 5601:5601 -p 9200:9200 -p 6379:6379 relki
```

It's done now you can see the container created :
```
$ docker ps -a
```
