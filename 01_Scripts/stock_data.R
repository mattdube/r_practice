library(tidyverse)
library(tidyquant)
library(tidyr)
library(dtplyr)
library(data.table)
library(tictoc)
library(profvis)
library(bench)

stock_symbols <- c("AAPL", "MSFT", "NFLX", "TSLA")

# Keep just the closing price
stock_prices <- tq_get(stock_symbols, from = "2010-01-01") %>%
    select(symbol, date, close)

class(stock_prices) # tbl

stock_prices2 <- lazy_dt(stock_prices)

# create data.table
stockPricesDT <- setDT(tq_get(stock_symbols, from = "2010-01-01"))
stockPricesDT <- stockPricesDT[,.(symbol, date, close)]
class(stockPricesDT) # data.table

# visualize stocks over time
theme_set(theme_tq())
ggplot(stockPricesDT, aes(date, close, color=symbol)) +
    geom_line()

# tidyverse solution
stock_prices %>%
    inner_join(stock_prices,
               by = "symbol",
               suffix = c("", "_future"))

# data.table solution
merge(stockPricesDT, stockPricesDT, 
      by="symbol", 
      suffixes = c("", "_future"), 
      allow.cartesian = TRUE)

# This creates all combinations of present and future dates, 
# ending up in columns close and close_future. Now we’ll need a few dplyr steps:
#     
#   *  Filter for cases where date_future is greater than date (filter)
#   *  Look at the change if you bought on date and sold on date_future (mutate)
#   *  Aggregate to find the maximum and minimum change within each symbol (group_by/summarize)

system.time({
stock_prices %>%
    inner_join(stock_prices,
               by = "symbol",
               suffix = c("", "_future")) %>%
    filter(date_future > date) %>%
    mutate(change = close_future - close) %>%
    group_by(symbol) %>%
    summarize(largest_lost = min(change),
              largest_gain = max(change)) %>%
    ungroup()
})

system.time({stock_prices2 %>%
  inner_join(stock_prices2,
             by = "symbol",
             suffix = c("", "_future")) %>%
  filter(date_future > date) %>%
  mutate(change = close_future - close) %>%
  group_by(symbol) %>%
  summarize(largest_gain = max(change),
            largest_loss = min(change)) %>% 
    as_tibble()})


system.time({merge(stockPricesDT, stockPricesDT, 
      by="symbol", 
      suffixes = c("", "_future"), 
      allow.cartesian = TRUE)[date_future > date][
        ,`:=`(change = close_future - close)][,
      .(largest_gain = max(change),
        largest_loss = min(change)), keyby = .(symbol)][]})


profvis({
  stock_prices %>%
    inner_join(stock_prices,
               by = "symbol",
               suffix = c("", "_future")) %>%
    filter(date_future > date) %>%
    mutate(change = close_future - close) %>%
    group_by(symbol) %>%
    summarize(largest_lost = min(change),
              largest_gain = max(change)) %>%
    ungroup()
})

profvis({stock_prices2 %>%
    inner_join(stock_prices2,
               by = "symbol",
               suffix = c("", "_future")) %>%
    filter(date_future > date) %>%
    mutate(change = close_future - close) %>%
    group_by(symbol) %>%
    summarize(largest_gain = max(change),
              largest_loss = min(change)) %>% 
    as_tibble()})


profvis({merge(stockPricesDT, stockPricesDT, 
                   by="symbol", 
                   suffixes = c("", "_future"), 
                   allow.cartesian = TRUE)[date_future > date][
                     ,`:=`(change = close_future - close)][,
                                                           .(largest_gain = max(change),
                                                             largest_loss = min(change)), keyby = .(symbol)][]})
