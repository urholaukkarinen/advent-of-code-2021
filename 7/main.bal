import ballerina/io;

function readInput() returns int[]|error {
    var readableByteChannel = check io:openReadableFile("input.txt");
    var readableCharChannel = new io:ReadableCharacterChannel(readableByteChannel, "UTF-8");
    var readableRecordsChannel = new io:ReadableCSVChannel(readableCharChannel, fs = ",");

    var values = check readableRecordsChannel.getNext();

    return (values is string[])
        ? values.map(((n) => checkpanic int:fromString(n)))
        : [];
}

function solve(function (int) returns int fun) returns int {
    var input = checkpanic readInput();

    var min = int:MAX_VALUE;
    var max = int:MIN_VALUE;
    foreach var i in input {
        min = int:min(i, min);
        max = int:max(i, max);
    }

    var best = int:MAX_VALUE;
    foreach var i in min ... max + 1 {
        var sum = 0;

        foreach var n in input {
            sum += fun((n - i).abs());
        }

        if sum < best {
            best = sum;
        }
    }

    return best;
}

public function main() {
    // Part 1
    // Fuel consuption per crab = move distance
    io:println(solve(((d) => d)));
    // Part 2
    // Fuel consuption per crab = n-th triangular number where n = move distance
    io:println(solve(((d) => (d * d + d) / 2)));
}
