#Takes a city and state, returns the largest string of digits which uniquely start 
#a zip code. E.g. Washington, DC has many zip codes, but all start with 20 so 20 
#would be returned by this function

library(zipcode)

data(zipcode)

#takes city and state strings, returns zipcode string
zip_lookup <- function(c,st,cityzips=c()) {
	if (nrow(subset(zipcode,city==c & state==st))==0){
		return(character(0))
	}
	if (is.null(cityzips)) {
		cityzips = subset(zipcode,city==c & state==st,zip)
	}
	if (nrow(cityzips)==1) {
		return(as.character(cityzips$zip[1]))
	}
	else {
		cityzips <- as.data.frame(lapply(cityzips,function(x) substr(x,1,nchar(as.character(x))-1)))
		cityzips <- unique(cityzips)
		zip_lookup(c,st,cityzips)
	}
}

