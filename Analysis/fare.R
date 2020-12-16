library(rhdfs)
hdfs.init()
library(rmr2)

rmr.options(backend = "hadoop")
hdfs.ls("/data/taxi/combined")
header.file <- "/data/taxi/combined/info.csv"

header.format <- make.input.format(format = "csv", sep = ",", stringsAsFactors = FALSE)
header.Info <- values(from.dfs(header.file, format = header.format))
header.Info

#header.Info <- values(from.dfs(header.file, format = "csv"))
#header.Info

colNames <- header.Info[-1, 1]; colNames
colClasses <- header.Info[-1, 2]; colClasses
colClasses[colClasses == "integer"] <- "numeric"
cbind(colNames, colClasses)

#hdfs.ls("/data/taxi/combined/")
taxi.hdp <- "/data/taxi/combined/sample_combined1.csv"

taxi.format <- make.input.format(format = "csv", sep = ",",
                                 col.names = colNames,
                                 colClasses = colClasses,
                                 stringsAsFactors = FALSE)


res <- from.dfs( mapreduce(input = taxi.hdp, input.format = taxi.format) )
head(values(res))

v <- values(res)

#trip_distance 
dist <- v[[17]] 

#fare_amount
fare <- v[[5]]


#map
taxi.map <- function(k, v) {
  
  
  keyval(v[,17], v[,5])
  
}


res <- values(from.dfs( mapreduce(input = taxi.hdp, 
                                  input.format = taxi.format,
                                  map = taxi.map,  
                                  combine = T ) ))

#reduce
taxi.reduce <- function(k, v) {
  
  
  keyval(k, sum(v))
  
}

#reduce 포함해서 mapreduce
res <- values( from.dfs( mapreduce(input = taxi.hdp, 
                                   input.format = taxi.format,
                                   map = taxi.map, 
                                   reduce = taxi.reduce, 
                                   combine = T ) ) )


#거리에 따른 운임비용 값 예측 위한 회귀분석모델
model <- lm(fare~dist, data=as.data.frame(res))



#회귀분석에 따른 거리 1부터 n까지의 운임비용 예측

n=20 #n개의 예측/ 예시가 20

p <- predict(model, data.frame(dist=seq(n)))
df_p <-  as.data.frame(p)

newdist=c()
for(i in 1:n){
  newdist[i]=i
}

newfare <- df_p[,1]


newdist#n개의 거리
newfare#1부터 n까지 거리의 각 운임비용



#시각화
plot(v[,17], v[,5], xlab="거리", ylab = "운임비용")
abline(coef(model), col="blue")

