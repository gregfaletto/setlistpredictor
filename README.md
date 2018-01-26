# setlistpredictor

## Summary

During my internship with Live Nation (Feb - May 2017), I created an algorithm to predict the future concert set lists of bands using their database on setlist.fm. A set list is an ordered list of the songs a band plays at a particular concert. https://www.setlist.fm/ contains a database of past concert set lists of each band, including the date and the location of the concert.

The basic idea of my algorithm is that for every song the band has ever played in a concert listed on setlist.fm, a song score is created by taking a sum of the number of times that the band played the song at concerts in the setlist.fm database—except the sum is weighted by recency of the concert, so that more recent performances count more and less recent ones are discounted. This approach accounts for the fact that a band’s new set lists are more likely to be similar to their most recent concerts, but still exploits all of the data in the database to some degree.

## Files

Here are descriptions of each of the files in this repository:

* **setlist.R:** My R code implementing the algorithm I created.

* **Live Nation description.pdf:** A description of how the algorithm works.

There is also a folder containing the LaTeX files for the description.