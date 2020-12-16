library(httr)
library(XML)
url_places<-"http://127.0.0.1:5500/html/cost.html"
web_places<-GET(url_places)
html_places<-htmlTreeParse(web_places, useInternalNodes=T, trim=T, encoding='utf-8')
rootNode_places<-xmlRoot(html_places)
start<-xpathSApply(rootNode_places, "//body/div/div[@class='main']/div[1]/div[1]/input[1]", xmlAttrs)
start<- str_trim(start)
start<-start[4]
start<-str_replace_all(start,' ','+')
end<-xpathSApply(rootNode_placeslaces, "//body/div/div[@class='main']/div[1]/div[1]/input[2]", xmlAttrs)
end<- str_trim(end)
end<-end[4]
end<-str_replace_all(end, ' ','+')
url<-paste("https://google.co.kr/search?q=",start,"%28뉴욕%29에서+",end,"%28뉴욕%29까지의+거리", sep="")
web<-GET(url)
html<-htmlTreeParse(web, useInternalNodes=T, trim=T, encoding='utf-8')
rootNode<-xmlRoot(html)
tag<-xpathSApply(rootNode, "//body/div[@id='main']/div[3]", xmlValue)
library(stringr)
mile <- str_trim(substr(tag, regexpr('\\(', tag)+1, regexpr('마일',tag)-1))
miles<-as.numeric(mile)
km<-miles*1.60934
km<-round(km, digit=1)
setwd("./Analysis")
write(km, file="distance.txt")
km

