import os

// Read input file into a two-dimensional array
fn load_input() ?[][]int {
    return os.read_file("input.txt")?
        .split_into_lines()
        .map(it.split('').map(it.int()))
}

// Increment a single value in the array and trigger a flash if it was a 9.
// Returns the number of flashes triggered
fn (mut arr [][]int) inc(x int, y int) int {
    if x >= 0 && x < arr[0].len && y >= 0 && y < arr.len {
        arr[y][x]++
        if arr[y][x] == 10 {
            return arr.flash(x, y)
        }
    }
    return 0
}

fn sum(a ...int) int {
    mut total := 0
    for x in a {
        total += x
    }
    return total
}

// Increment all neighbors.
// Returns the number of flashes triggered
fn (mut arr [][]int) flash(x int, y int) int {
    mut flashes := 1
    for n in [
        arr.inc(x-1, y),
        arr.inc(x+1, y),
        arr.inc(x, y-1),
        arr.inc(x, y+1),
        arr.inc(x-1, y+1),
        arr.inc(x+1, y-1),
        arr.inc(x-1, y-1),
        arr.inc(x+1, y+1),
    ] { flashes += n }
    return flashes
}

// Step once and return the number of flashes triggered
fn (mut arr [][]int) step() int {
    mut flashes := 0

    // Increment all and count the flashes
    for y in 0..arr.len {
        for x in 0..arr[y].len {
            flashes += arr.inc(x, y)
        }
    }

    // Change all flashed values to 0
    for y in 0..arr.len {
        for x in 0..arr[y].len {
            if arr[y][x] >= 10 {
                arr[y][x] = 0
            }
        }
    }

    return flashes
}

mut input := load_input()?
size := input.len * input[0].len
mut total_flashes := 0

for i := 1; true; i++ {
    step_flashes := input.step()
    total_flashes += step_flashes

    if i == 100 {
        // Part one
        println(total_flashes)
    }

    if step_flashes == size {
        // Part two
        println(i)
        break
    }
}
