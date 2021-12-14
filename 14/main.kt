import java.io.File
import kotlin.collections.HashMap

fun solve(steps: Int) {
    var (initial, pairs) = File("input.txt").readText().split("\n\n")

    var mapping = pairs.split("\n")
        .map { it.split(" -> ")}
        .map { it.first() to it.last().first() }
        .toMap()

    var pairCounts = initial.windowed(2)
        .groupingBy { it }
        .eachCount()
        .map { (a, b) -> a to b.toLong() }
        .toMap()

    var charCounts = initial.toList()
        .groupingBy { it.toChar() }
        .eachCount()
        .map { (a, b) -> a to b.toLong() }
        .toMap()
        .toMutableMap()

    for (i in 1..steps) {
        var nextPairCounts = hashMapOf<String, Long>()
        for ((key, count) in pairCounts) {
            var c = mapping[key]!!
            var a = "${key.first()}$c"
            var b = "$c${key.last()}"

            charCounts[c] = charCounts.getOrDefault(c, 0) + count
            nextPairCounts[a] = nextPairCounts.getOrDefault(a, 0) + count
            nextPairCounts[b] = nextPairCounts.getOrDefault(b, 0) + count
        }
        pairCounts = nextPairCounts
    }

    var sorted_counts = charCounts.values.sorted()

    println((sorted_counts.last() - sorted_counts.first()))
}

fun main() {
    solve(10)
    solve(40)
}