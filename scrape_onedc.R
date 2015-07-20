#Scrape OneDC event listing

setwd("C:/Users/Brett/Documents/Assemble/web-scraping")

library(rvest)
library(stringr)


pg.min = 1
pg.max = 1
N = nd.max - nd.min + 1

all.events = data.frame(title=rep(character(),N),link=rep(character(),N),
	street.address=rep(character(),N),city=rep(character(),N),state=rep(character(),N),
	date=rep(character(),N),description=rep(character(),N),
	category1=rep(character(),N),category2=rep(character(),N),
	stringsAsFactors=FALSE)

for (p in pg.min:pg.max) {
	pg <- paste("http://www.onedconline.org/events?page=",p,sep="")
	if(url.exists(pg)) {
		page_src = html(pg)

		titles = html_text(html_nodes(page_src,"h4 a"))
		dates = str_trim(html_text(html_nodes(page_src,"h4+ .padtopless")),"both")
		address = str_trim(html_text(html_nodes(page_src,".event_venue")),"both")
		descriptions = str_trim(html_text(html_nodes(page_src,".truncate-200")),"both")
	
		category1 = "Economics"
		category2 = "Race"

		gsub("\\n*.*","",dates)
	}
	all.events = cbind(titles,pg,dates,address,descriptions,category1,category2)
}


write.csv(all.events,"onedc_events.csv")
