################################################################################
################################################################################
## Title: 
## Author: Matt Dube
## Date: <date time>
## Synopsis: 
## Time-stamp: <time>
################################################################################
################################################################################
library(dplyr)
library(ggplot2)
library(data.table)
library(lobstr)

# objects or values don't have names. 
# The name (x or y for example) has a value

x <- c(1, 2, 3)
y <- x

obj_addr(x)
obj_addr(y)

obj_addr(mean(x))
obj_addr(base::mean(x))

obj_addr(mean)
obj_addr(base::mean)
obj_addr(get("mean"))
obj_addr(evalq(mean))
obj_addr(match.fun("mean"))


# use tracemem() to see when an object gets copied
# tracemem() returns the object's current address
cat(tracemem(x), "\n")

y <- x
y[[3]] <- 4L

# untracemem() is the opposite of tracemem(); it turns tracing off
untracemem(x)

# it's not just names (i.e. variables) that point to values
# elements of lists do too
l1 <- list(1, 2, 3)
l2 <- l1

obj_addr(l1)
obj_addr(l2)
l2[[3]] <- 4
obj_addr(l2)

obj_addrs(l1)
obj_addrs(l2)

ref(l1, l2)

s <- c("a", "a", "abc", "d", "ab", "bc", "d")

ref(s, character = TRUE)

x <- c(1L, 2L, 3L)
tracemem(x)
x[[3]] <- 4

lobstr::obj_size(3L)
lobstr::obj_size(3.020)

a  <- 1:10
b <- list(a, a)
c <- list(b, a, 1:10)
obj_addr(a)
obj_addr(b)
obj_addr(c)
ref(a, b, c)
ref(c)

x <- list(1:10)
obj_addr(x)
x[[2]] <- x

obj_addr(x)

obj_size(letters)
obj_size(ggplot2::diamonds)

a  <- runif(1e6)
obj_size(a)

b <- list(a, a)
obj_size(b)
obj_size(a, b)

b[[1]][[1]] <- 10
obj_size(b)
obj_size(a, b)

b[[2]][[1]] <- 10
obj_size(b)
obj_size(a, b)

v <- c(1, 2, 3)
obj_addr(v)

v[[3]] <- 4
obj_addr(v)


x <- data.frame(matrix(runif(5 * 1e4), ncol = 5))
medians <- vapply(x, median, numeric(1))

for (i in seq_along(medians)) {
    x[[i]]  <- x[[i]] - medians[[i]]
}

cat(tracemem(x), "\n")

for (i in 1:5) {
    x[[i]]  <- x[[i]] - medians[[i]]
}

untracemem(x)

y <- as.list(x)
cat(tracemem(y), "\n")

for (i in 1:5) {
    y[[i]]  <- y[[i]] - medians[[i]]
}


untracemem(y)


mem_used()
