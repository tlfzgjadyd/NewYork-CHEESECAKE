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
v <- values(res1)
v <- v[-c(1,2)]

# 택시 승하차 스팟 : 시간대별, 요일별
# for 기사 , 승차 스팟 -> 승차 승객 수요가 많은 곳(pickup_lon, pickup_lat)
summary(v$pickup_longitude) # -1930.04 ~ 80.84
summary(v$pickup_latitude) # -3084.26 ~ 473.99
boxplot(v$pickup_longitude)
boxplot(v$pickup_latitude)

# 위도, 경도 이상치 제거
boxplot(v$pickup_longitude, title="pickup_longitude")
v$pickup_longitude <- 
  ifelse(v$pickup_longitude<(-180) | v$pickup_longitude>180, 
         NA, v$pickup_longitude) # 경도

boxplot(v$pickup_latitude, title="pickup_latitude")
v$pickup_latitude <- 
  ifelse(v$pickup_latitude<(-90) | v$pickup_latitude>90, 
         NA, v$pickup_latitude) # 위도
v<-na.omit(v)

summary(v$pickup_longitude)
# plot(val$pickup_longitude) # mean = -72.63
# plot(val$pickup_latitude) # mean = 40.0204

# 시간 범주화
new <- as.POSIXct(v$pickup_datetime, 
                  format = "%Y-%m-%d %H:%M:%S")
v$pickup_time <- as.numeric(format(new, "%H"))
v$pickup_timezone<-
                  ifelse(v$pickup_time>=23 | v$pickup_time<6, "Dawn",
                ifelse(v$pickup_time>=6 & v$pickup_time<9, "Go",
                ifelse(v$pickup_time>=9 & v$pickup_time<17, "Day",
                ifelse(v$pickup_time>=17 & v$pickup_time<20, "Off",
                ifelse(v$pickup_time>=20 & v$pickup_time<23, "Night", NA)
                                     )))
                )

# 시간대 별 승차 스팟 찾기 (중앙값으로)
lon <- as.matrix(tapply(v$pickup_longitude, v$pickup_timezone, median))
lat <- as.matrix(tapply(v$pickup_latitude, v$pickup_timezone, median))

# lon
#    Dawn       Day        Go     Night       Off 
# -73.98579 -73.97980 -73.97917 -73.98292 -73.98096 

# lat
#   Dawn      Day       Go    Night      Off 
# 40.74259 40.75638 40.75594 40.75099 40.75527 

# 결과
cbind(lat["Dawn",],lon["Dawn",]) # Dawn
cbind(lat["Go",],lon["Go",]) # Go
cbind(lat["Day",],lon["Day",]) # Day
cbind(lat["Off",],lon["Off",]) # Off
cbind(lat["Night",],lon["Night",]) # Night 

# table로 깔끔하게 그리기 
table <- function() {
  tab <- cbind(lat["Dawn",],lon["Dawn",]) # Dawn
  tab <- rbind(tab,cbind(lat["Go",],lon["Go",])) # Go
  tab <- rbind(tab,cbind(lat["Day",],lon["Day",])) # Day
  tab <- rbind(tab,cbind(lat["Off",],lon["Off",])) # Off
  tab <- rbind(tab,cbind(lat["Night",],lon["Night",])) # Night 
  colnames(tab) <- c("위도","경도")
  tab
}
table()

## 결과
dawn<-cbind(lat["Dawn",],lon["Dawn",]) # Dawn
go<-cbind(lat["Go",],lon["Go",]) # Go
day<-cbind(lat["Day",],lon["Day",]) # Day
off<-cbind(lat["Off",],lon["Off",]) # Off
night<-cbind(lat["Night",],lon["Night",]) # Night

setwd("./Analysis")
write(dawn, file="dawn.txt")
write(go, file="go.txt")
write(day, file="day.txt")
write(off, file="off.txt")
write(night, file="night.txt")



