# setwd("/Users/gregfaletto/Documents/Live Nation")

# setwd("/Users/gfaletto/Documents/R/Live Nation")

rm(list=ls())

#comment: Libraries needed:
library(jsonlite)

# library(RCurl)

key <- "3c73aad6-ba7f-4a3d-882a-f917ac75001a"
# mbid <- "65f4f0c5-ef9e-490c-aee3-909e7ae6b2ab" # Metallica
# mbid <- "8bfac288-ccc5-448d-9573-c33ea2aa5c30" # RHCP
# mbid <- "fc7bbf00-fbaa-4736-986b-b3ac0266ca9b" # alt-J
mbid <- "603c5f9f-492a-4f21-9d6f-1642a5dbea2d" # the unicorns
# mbid <- "8e494408-8620-4c6a-82c2-c2ca4a1e4f12" #Lorde
lambda <- 5 # half-life parameter; the larger this is, the
			# more weight is placed on older songs
ell <- 10 # Number of songs to return

#comment: First page only with this link, adjust as necessary 
# or loop for multiple
jsonLocation <- paste('http://api.setlist.fm/rest/0.1/artist/',
	mbid,'/setlists.json?p=1',sep='')

##comment: Getting api call into dataframe
jsonFile <- fromJSON(txt=jsonLocation)
ipp <- as.integer(jsonFile$setlists$"@itemsPerPage") # Items per page
pages <- ceiling(as.integer(jsonFile$setlists$`@total`)/ipp)
artist <- jsonFile$setlists$setlist$artist$"@name"[1]

##comment: All the setlists from this page into a separate data frame
set.lists <- list(NULL)
dates <- c(as.Date("2017-05-11"))


for(k in 1:pages) {
	jsonLocation <- paste('http://api.setlist.fm/rest/0.1/artist/',
		mbid,'/setlists.json?p=', k, sep='')
	jsonFile <- fromJSON(txt=jsonLocation)
	jsonDF <- as.data.frame(jsonFile)

	for (i in 1:ipp) {
		if (is.atomic(jsonDF[i,]$setlists.setlist.sets[[1]])) {
			next
		}
		if (is.data.frame(jsonDF[i,]$setlists.setlist.sets[[1]]$
			set$song)) {
			set.lists[[((k-1)*ipp+i)]] <- jsonDF[i,]$setlists.setlist.sets[[1]]$
			set$song$"@name"
		}
		else if (typeof(jsonDF[i,]$setlists.setlist.sets[[1]]$
			set$song)=="list") {
			if (length(jsonDF[i,]$setlists.setlist.sets[[1]]$
				set$song)==2) {
				list.temp <- NULL
				if (is.atomic(jsonDF[i,]$
							setlists.setlist.sets[[1]]$set$song[[1]])) {
						list.temp <- jsonDF[i,]$setlists.setlist.sets[[1]]$set$
							song$"@name"
					}
				else for (j in 1:2) {
					list.temp <- c(list.temp, jsonDF[i,]$
						setlists.setlist.sets[[1]]$set$song[[j]]$
						"@name")
				}
				set.lists[[((k-1)*ipp+i)]] <- list.temp
			}
			if (length(jsonDF[i,]$setlists.setlist.sets[[1]]$
				set$song)==3) {
				set.lists[[((k-1)*ipp+i)]] <- jsonDF[i,]$setlists.setlist.sets[[1]]$
					set$song$"@name"
			}
		}
		if (is.null(jsonDF[i,]$setlists.setlist.sets[[1]]$set)) {
			if (is.atomic(jsonDF[i,]$setlists.setlist.sets[[1]][[1]])) {
				next
			}
			if (is.data.frame(jsonDF[i,]$setlists.setlist.sets[[1]][[1]]$song)) {
				set.lists[[((k-1)*ipp+i)]] <- jsonDF[i,]$setlists.setlist.sets[[1]][[1]]$
					song$"@name"
			}
			else if (typeof(jsonDF[i,]$setlists.setlist.sets[[1]][[1]]$
				song)=="list") {
				if (length(jsonDF[i,]$setlists.setlist.sets[[1]][[1]]$
					song)==2) {
					list.temp <- NULL
					if (is.atomic(jsonDF[i,]$
							setlists.setlist.sets[[1]][[1]]$song[[1]])) {
						list.temp <- jsonDF[i,]$setlists.setlist.sets[[1]][[1]]$
							song$"@name"
					}
					else for (j in 1:2) {
						list.temp <- c(list.temp, jsonDF[i,]$
							setlists.setlist.sets[[1]][[1]]$song[[j]]$
							"@name")
					}
					
					set.lists[[((k-1)*ipp+i)]] <- list.temp
				}
				if (length(jsonDF[i,]$setlists.setlist.sets[[1]]$
					set$song)==3) {
					set.lists[[((k-1)*ipp+i)]] <- jsonDF[i,]$setlists.setlist.sets[[1]][[1]]$
					song$"@name"
				}
			}
		}

	}
# str(jsonDF[i,]$setlists.setlist.sets[[1]][[1]])
dates.temp <- as.Date(jsonDF$setlists.setlist..eventDate, format="%d-%m-%Y")
# if(length(dates.temp)!=ipp) {print(paste("Error on i =", i,
# 	"j =", j, "k = ", k))}
dates <- c(dates, dates.temp)
	
rm(jsonFile)
rm(jsonDF)
}

n.concerts <- length(set.lists)
dates <- dates[2:(n.concerts+1)]

# prepare data

big.ol.list <- c()
for (i in 1:length(set.lists)) {
	big.ol.list <- c(big.ol.list, set.lists[[i]])
}
songs <- unique(big.ol.list)
n.songs <- length(songs)

# Create matrix of songs

A.prime <- matrix(rep(0, n.concerts*n.songs), ncol=n.songs)

for (i in 1:n.concerts){
	for(j in 1:n.songs) {
		if (songs[j] %in% set.lists[[i]]) {
			A.prime[i, j] <- 1
		}
	}
}

v <- rep(0, n.concerts)

MyWeights <- function(date) {
	t <- as.numeric(difftime(as.Date(Sys.Date()), date,
		unit="weeks"))/52.25
	return(2^(-t/lambda))
}

v <- sapply(dates, Myv)
song.scores <- v%*%A.prime
sorted <- songs[order(song.scores, decreasing=T)]
print(paste("Top", ell, "most likely songs for", artist, ":"))
print(sorted[1:ell])