input <- if (file.exists("flights14.csv")) {
	"flights14.csv"
} else {
	"https://raw.githubusercontent.com/Rdatatable/data.table/master/vignettes/flights14.csv"
}
flights14 <- fread(input)
flights14

# Keys and fast binary search based subset

set.seed(1L)
DF = data.frame(ID1 = sample(letters[1:2], 10, TRUE),
								ID2 = sample(1:3, 10, TRUE),
								val = sample(10),
								stringsAsFactors = FALSE,
								row.names = sample(LETTERS[1:10]))

DF
rownames(DF)
DF["C",]

DT = as.data.table(DF)
DT
rownames(DT)

# set, get, and use keys on a data.table
# set the column `origin` as key in the data.table flights
setkey(flights14, origin)
head(flights14)

# alternative - we can provide a character vector to the function `setkeyv()`
# setkeyv(flights, "origin") # useful to program with

flights14[.("JFK")]
flights14[J("JFK")]
flights14[list("JFK")]

key(flights14)

setkey(flights14, origin, dest)
head(flights14)

flights14[.("JFK", "SFO"), mean(arr_delay + dep_delay)]

# return arr_delay column as a data.table correpsonding to origin="LGA" an dest="TPA"
key(flights14)
flights14[.("LGA", "TPA"), .(arr_delay)]

# use chaining on result above to order the column in decreasing order
flights14[.("LGA", "TPA"), .(arr_delay)][order(-arr_delay)]

# find the maximum arr_delay on above
flights14[.("LGA", "TPA"), max(arr_delay)]

# sub-assign using := in j
# get all `hours` in flights
flights14[, sort(unique(hour))]

# replace 24 with 0, this time using `key`
setkey(flights14, hour)
key(flights14)
flights14[.(24), hour:=0L]

# aggregation using `by`
# set the key back to origin,dest
setkey(flights14, origin, dest)
key(flights14)

# get the maximum departure delay for each month corresponding to origin="JFK"
# order result by month
ans <- flights14[.("JFK"), max(dep_delay), keyby=month]
head(ans)
key(ans)

