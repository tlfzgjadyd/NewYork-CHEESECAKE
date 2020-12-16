# 분산컴퓨팅 뉴욕치즈케이크 프로젝트

library(rhdfs)
hdfs.init()
library(rmr2)

rmr.options(backend = "hadoop")
hdfs.ls("/data/taxi/combined")


# header 만들기
files <- hdfs.ls("/data/taxi/combined")$file; files

mr <- mapreduce(input = files[1], 
                input.format = make.input.format(
                  format = "csv", sep=",", stringsAsFactors=F)
)
res <- from.dfs(mr) 
ress <- values(res)
colnames.tmp <- as.character(ress[,1]); colnames.tmp
class.tmp <- as.character(ress[,2]); class.tmp 

colnames <- colnames.tmp[-1]; colnames
colclass <- class.tmp[-1]; colclass 
colclass[c(6,8,9,10)] <- "numeric"

# 파일 읽기
taxi.hdp1 <- "/data/taxi/combined/sample_combined1.csv"
taxi.format1 <- make.input.format(format = "csv", sep=",",
                                 col.names=colnames, 
                                 colClasses=colclass)
res1 <- from.dfs(taxi.hdp1, format=taxi.format1) 
val <- values(res1)
val <- val[-c(1,2)]
head(val)

# 요일 변환
taxi.map <- function(.,v) {
  pictime <- val[["pickup_datetime"]]
  date <- as.Date(pictime, origin = "1970-01-01")
  
  wkday <- weekdays(date); wkday
}

res <- from.dfs( mapreduce(input = taxi.hdp1,
                                 input.format=taxi.format1,
                                  map=taxi.map, combine=T))
day <- values(res) 


# 택시 승하차 스팟 : 시간대별, 요일별
# for 기사 , 승차 스팟 -> 승차 승객 수요가 많은 곳(pickup_lon, pickup_lat)
summary(val$pickup_longitude) # -1930.04 ~ 80.84
summary(val$pickup_latitude) # -3084.26 ~ 473.99
boxplot(val$pickup_longitude)
boxplot(val$pickup_latitude)

v <- val

# 위도, 경도 이상치 제거
boxplot(v$pickup_longitude, title="pickup_longitude")
v$pickup_longitude <- 
  ifelse(v$pickup_longitude<(-180) | v$pickup_longitude>180, 
         NA, v$pickup_longitude) # 경도

boxplot(v$pickup_latitude, title="pickup_latitude")
v$pickup_latitude <- 
  ifelse(v$pickup_latitude<(-90) | v$pickup_latitude>90, 
         NA, v$pickup_latitude) # 위도
val<-na.omit(v)

summary(val$pickup_longitude)
# plot(val$pickup_longitude) # mean = -72.63
# plot(val$pickup_latitude) # mean = 40.0204

# 시간 범주화
new <- as.POSIXct(val$pickup_datetime, 
                  format = "%Y-%m-%d %H:%M:%S")
val$pickup_time <- as.numeric(format(new, "%H"))
val$pickup_timezone<-
                  ifelse(val$pickup_time>=23 | val$pickup_time<6, "Dawn",
                ifelse(val$pickup_time>=6 & val$pickup_time<9, "Go",
                ifelse(val$pickup_time>=9 & val$pickup_time<17, "Day",
                ifelse(val$pickup_time>=17 & val$pickup_time<20, "Off",
                ifelse(val$pickup_time>=20 & val$pickup_time<23, "Night", NA)
                                     )))
                )
val$pickup_longitude[68414]
val$pickup_latitude[68414]
# 시간대 별 승차 스팟 찾기 (평균으로)
lon <- as.matrix(tapply(val$pickup_longitude, val$pickup_timezone, median))
#    Dawn       Day        Go     Night       Off 
# -73.98579 -73.97980 -73.97917 -73.98292 -73.98096 

lat <-as.matrix(tapply(val$pickup_latitude, val$pickup_timezone, median))
#   Dawn      Day       Go    Night      Off 
# 40.74259 40.75638 40.75594 40.75099 40.75527 

# 결과
cbind(lat["Dawn",],lon["Dawn",]) # Dawn
cbind(lat["Go",],lon["Go",]) # Go
cbind(lat["Day",],lon["Day",]) # Day
cbind(lat["Off",],lon["Off",]) # Off
cbind(lat["Night",],lon["Night",]) # Night 







