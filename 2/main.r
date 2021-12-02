source = read.delim("input.txt", sep = " ", header = FALSE)

# Part 1

x = 0
y = 0

for(i in 1:nrow(source)) {
    dir <- source[i,1]
    val <- source[i,2]
    
    if (dir == "forward") {
        x <- x + val
    } else if (dir == "up") {
        y <- y - val
    } else if (dir == "down") {
        y <- y + val
    }
}

print(x * y)

# Part 2

x = 0
y = 0
aim = 0

for(i in 1:nrow(source)) {
    dir <- source[i,1]
    val <- source[i,2]
    
    if (dir == "forward") {
        x <- x + val
        y <- y + (aim * val)
    } else if (dir == "up") {
        aim <- aim - val
    } else if (dir == "down") {
        aim <- aim + val
    }
}

print(x * y)