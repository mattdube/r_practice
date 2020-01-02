
dt2 <- data.table(mtcars)[,.(cyl, gear)]
dt <- data.table(mtcars)[, .(cyl, mpg)] 
dt <- data.table(mtcars) 
flights <- data.table(nycflights13::flights)

input <- if (file.exists("flights14.csv")) {
	"flights14.csv"
} else {
	"https://raw.githubusercontent.com/Rdatatable/data.table/master/vignettes/flights14.csv"
}
flights14 <- fread(input)
flights14


dt2[,gearsL:=list(list(unique(gear))), by=cyl]
head(dt2)

dt2[, gearsL:=.(list(unique(gear))), by=cyl][]
head(dt2)


dt2[,gearL1:=lapply(gearsL, function(x) x[2])][]
head(dt2)


dt[, avg_mpg:=mean(mpg), by=cyl]
dt

dt[, .(avg_mpg = mean(mpg)), by = cyl]
dt[, .SD[,mean(mpg)], keyby=cyl]

# add columns by reference
# add columns speed and total_delay for each flight to `flights` data.table
flights
flights[, `:=`(speed = distance / (air_time/60),
							 delay = arr_delay + dep_delay)]

# alternative method using LHS:=RHS
# flights[, c("speed", "delay") := .(distance/(air_time/60), arr_delay + dep_delay)]
flights14[, `:=`(speed = distance / (air_time/60),
								 delay = arr_delay + dep_delay)]


head(flights)

# find max speed by carrier 
# to do this need to ignore NA speed values (for flights that were cancelled)
# dt[i, j, by] is used to:
# i - filter flights, removing NAs
# j - use max() function on speed
# by - carrier
flights[!is.na(speed), max(speed), by=carrier]
flights14[!is.na(speed), max(speed), keyby=carrier]

# update some rows of columns by reference - sub-assign by reference
# get all `hours` in flights
flights14[, sort(unique(hour))]

flights14[hour == 24L, hour := 0L]

# delete column by reference
# remove `delay` column
flights14[, c("delay") := NULL]
head(flights14)

# add a new column which contains for each orig,dest pair the maximum speed
flights14[, max_speed:=max(speed), by=.(origin, dest)]
head(flights14)


# add two more columns computing max() of dep_delay and arr_delay for each month, using .SD
flights14[, c("max_dep_delay", "max_arr_delay") := lapply(.SD, max), by=month,
					.SDcols = c("dep_delay", "arr_delay")]

head(flights14)

# remove columns added above
flights14[, c("max_dep_delay", "max_arr_delay", "speed", "max_speed") := NULL]
head(flights14)

