# This program will scrape data from the Washington Peace Center's calendar of activist events, 
# taking location, time/date, description, link, and categorical data.
# First need to use Selectorgadget.com's tool to find which CSS selector uniquely
# identifies the relevant fields.

library(rvest)
library(RCurl)

#create data.frame to store all the data.
all_events <- data.frame(title=NULL,link=NULL,street_address=NULL,city=NULL,state=NULL,date=NULL,description=NULL,categories=NULL,stringsAsFactors=FALSE)
all_events <- data.frame(title="title",link="link",street_address="street address",city="city",state="state",date="date",
				 description="description",categories="categories",stringsAsFactors=FALSE)
# loop through nodes 1 to n, avoid running over non-existent pages
# figure out how to skip over errors in loop
for (n in 14800:15000) {
	nd <- paste("http://washingtonpeacecenter.org/node/",n,sep="")
	if(url.exists(nd)) {
		wpc_node <- html(nd)
		title <- html_text(html_nodes(wpc_node,"#page-title"))
		info <- html_text(html_nodes(wpc_node,".field__item"))
		all_events = rbind(all_events,c(title,nd,info))
 	}
}

#adjust categories to those we want
#Assemble Categories:


#write.csv(all_events,"C:\\Users\\Brett\\Documents\\Assemble\\assemble-web\\scraping\\wpc_events.csv")
write.csv(all_events,"wpc_events.csv")

