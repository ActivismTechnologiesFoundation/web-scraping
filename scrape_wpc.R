# This program will scrape data from the Washington Peace Center's calendar of activist events, 
# taking location, time/date, description, link, and categorical data.
# First need to use Selectorgadget.com's tool to find which CSS selector uniquely
# identifies the relevant fields.

setwd("C:/Users/Brett/Documents/Assemble/web-scraping")

library(rvest)
library(RCurl)
library(reshape2)
library(plyr)

nd.min = 14950
nd.max = 14960
N = nd.max - nd.min + 1

all.events = data.frame(title=rep(character(),N),link=rep(character(),N),
	street.address=rep(character(),N),city=rep(character(),N),state=rep(character(),N),
	date=rep(character(),N),description=rep(character(),N),
	category1=rep(character(),N),category2=rep(character(),N),category3=rep(character(),N),
	category4=rep(character(),N),category5=rep(character(),N),category6=rep(character(),N),
	stringsAsFactors=FALSE)
# loop through nodes 1 to n, avoid running over non-existent pages
for (n in nd.min:nd.max) {
	nd <- paste("http://washingtonpeacecenter.org/node/",n,sep="")
	if(url.exists(nd)) {
		wpc_node <- html(nd)
		title <- html_text(html_nodes(wpc_node,"#page-title"))
		info <- html_text(html_nodes(wpc_node,".field__item"))
		#adding NAs at end to prevent vector from looping when appending to data.frame with
		#more columns than it
		all.events[n-nd.min+1, ] = t(c(title,nd,info,NA,NA,NA,NA,NA,NA,NA))
		if(substr(all.events$description[n-nd.min+1],0,11)=="Event Info:") {
			all.events$description[n-nd.min+1] = substr(all.events$description[n-nd.min+1],
									  12,nchar(all.events$description[n-nd.min+1]))
		}
 	}
}

#adjust categories to those we want
#Assemble Categories, taken from native_categories.csv
ncat <- cbind(read.csv("native_categories.csv",header=TRUE,sep=",",strip.white=TRUE),wpc1=NA,wpc2=NA,wpc3=NA)

#Function to attach our native categories to 1 to 3 Washington Peace Center categories
cat_simp_transform <- function(native,w1,w2=NA,w3=NA) {
	ncat$wpc1 <- with(ncat, ifelse(ncat$native_categories==native,w1,ncat$wpc1))
	ncat$wpc2 <- with(ncat, ifelse(ncat$native_categories==native,w2,ncat$wpc2))
	ncat$wpc3 <- with(ncat, ifelse(ncat$native_categories==native,w3,ncat$wpc3))
	return(ncat)
}
ncat <- cat_simp_transform("Race",w1="Racial Justice")
ncat <- cat_simp_transform("Economics",w1="Labor/Workers' Rights",w2="Economic Justice",w3="Budget and Services")
ncat <- cat_simp_transform("Environment",w1="Environmental Justice/Climate Change")
ncat <- cat_simp_transform("War & Peace",w1="Peace/War")
ncat <- cat_simp_transform("Crime & Punishment",w1="Criminal Justice/Prisons")
ncat <- cat_simp_transform("Immigration",w1="Immigration/International Justice")
ncat <- cat_simp_transform("Gender",w1="Women/Gender/Sexuality Issues")
ncat <- cat_simp_transform("Education",w1="Education/Youth")
ncat <- cat_simp_transform("Arts & Culture",w1="Arts and Culture")
ncat <- cat_simp_transform("Civil Liberties",w1="Torture")
ncat <- cat_simp_transform("Health Care",w1="Health Equity")
#WPC categories not included are (1) DC Local Justice and (2) Other Social Justice Issues
#since these are too vague. May have to mine descriptions to more automatically categorize

##############################b#########################################
#Next, use category transformation to replace WPC categories with ours
#######################################################################
#reshape wide to long
ncat <- melt(ncat,id=c("native_categories"))
ncat <- ncat[names(ncat) %in% c("native_categories","value")]
ncat1 <- na.exclude(ncat) #drop NA's

#merge, which keeps only matched rows. Consider keeping others when text mining description to 
#categorize
i = 1
names(ncat1) = c(paste("native_categories",i,sep=""),paste("category",i,sep=""))
all.events <- merge(x=all.events,y=ncat1,all.x=TRUE)
i = 2
names(ncat1) = c(paste("native_categories",i,sep=""),paste("category",i,sep=""))
all.events <- merge(x=all.events,y=ncat1,all.x=TRUE)
i = 3
names(ncat1) = c(paste("native_categories",i,sep=""),paste("category",i,sep=""))
all.events <- merge(x=all.events,y=ncat1,all.x=TRUE)
i = 4
names(ncat1) = c(paste("native_categories",i,sep=""),paste("category",i,sep=""))
all.events <- merge(x=all.events,y=ncat1,all.x=TRUE)
i = 5
names(ncat1) = c(paste("native_categories",i,sep=""),paste("category",i,sep=""))
all.events <- merge(x=all.events,y=ncat1,all.x=TRUE)
i = 6
names(ncat1) = c(paste("native_categories",i,sep=""),paste("category",i,sep=""))
all.events <- merge(x=all.events,y=ncat1,all.x=TRUE)

all.events = subset(all.events, select = -c(category1,category2,category3,category4,category5,category6))

write.csv(all.events,"wpc_events.csv")

