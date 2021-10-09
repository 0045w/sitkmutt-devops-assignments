#ratings (port 8080)

docker build -t ratings .

docker run -d --name mongodb -p 27017:27017 \
  -v $(pwd)/databases:/docker-entrypoint-initdb.d bitnami/mongodb:5.0.2-debian-10-r2

docker run -d --name ratings -p 8080:8080 --link mongodb:mongodb \
  -e SERVICE_VERSION=v2 -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings' ratings

#details (port 8081)

cd details/

docker build -t details .

docker run --name details -p 8081:8081 -d details

#reviews (port 8082)

cd reviews/

docker build -t reviews .

docker run -d --name reviews -p 8082:9080 --link ratings:ratings -e ENABLE_RATINGS=true \
 -e RATINGS_SERVICE=http://ratings:8080/ reviews

#productpage (port 8083)

docker build -t productpage .

docker run -d --name productpage -p 8083:8083 \
 --link details:details --link ratings:ratings --link reviews:reviews \
 -e RATINGS_HOSTNAME=http://ratings:8080 \
 -e DETAILS_HOSTNAME=http://details:8081 \
 -e REVIEWS_HOSTNAME=http://reviews:9080 productpage
