
# very small function to return stock price based on stock
stockPricesDT

stockPricesDT[symbol == 'AAPL']

select_stock_price <- function(stock_symbol) {
	stockPricesDT[symbol == stock_symbol]
	
}

select_stock_price("AAPL")



dt <- data.table(mtcars)[, .(cyl, mpg)]
myfunc <- function(dt, v) {
	v2=deparse(substitute(v))
	dt[,..v2,with=TRUE]
	
}

myfunc(dt, mpg)

myfunc2 <- function(dt, v) {
	dt[, .(get(v))]	
	
}

myfunc2(dt, 'mpg')

ddat = dat[1:50000, .(Date, value1, value2, value3)]

add_engineered_dates <- function(mydt, date_col="Date"){
	
	new_dt = copy(mydt)
	
	new_dt[, paste0(date_col, "_year") := year(mdy_hms(get(date_col)))]
	new_dt[, paste0(date_col, "_month") := month(mdy_hms(get(date_col)))]
	new_dt[, paste0(date_col, "_day") := day(mdy_hms(get(date_col)))] 
	
	new_dt[, c(date_col) := NULL]
	
	new_dt[]
}