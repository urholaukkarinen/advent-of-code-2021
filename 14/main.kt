import java.io.File
import kotlin.collections.HashMap

fun solve(steps: Int) {
    var (initial, pairs) = File("input.txt").readText().split("\n\n")

    var mapping = pairs.split("\n")
        .map { it.split(" -> ")}
        .map { it.first() to listOf(it.first()[0] + it.last(),
             it.last() + it.first()[1]) }
        .toMap()

    var counts = initial.windowed(2)
        .groupingBy { it }
        .eachCount()
        .map { (a, b) -> a to b.toLong() }
        .toMap()

    for (i in 1..steps) {
        var nextCounts = hashMapOf<String, Long>()
        for ((key, count) in counts) {
            for (next in mapping[key]!!) {
                nextCounts[next] = nextCounts.getOrDefault(next, 0) + count;
            }
        }
        counts = nextCounts
    }

    var charCounts = hashMapOf<Char, Long>()
    for ((key, count) in counts) {
        if (count > 0) {
            charCounts[key.first()] = charCounts.getOrDefault(key.first(), 0) + count
            charCounts[key.last()] = charCounts.getOrDefault(key.last(), 0) + count
        }
    }

    charCounts[initial.first()] = charCounts.getOrDefault(initial.first(), 0) + 1
    charCounts[initial.last()] = charCounts.getOrDefault(initial.last(), 0) + 1

    var sorted_counts = charCounts.values.sorted()

    println((sorted_counts.last() - sorted_counts.first()) / 2)
}

fun main() {
    solve(10)
    solve(40)
}