import Foundation

func readInput() -> [Int] {
    do {
        let data = try String(contentsOfFile: "input.txt")
        return data.components(separatedBy:"\r\n").map({ Int($0)!})
    } catch {
        return []
    }
    
}

var a = -1
var b = -1
var c = -1
var prevSum = -1
var partOne = -1
var partTwo = -1

for n in readInput() {
    if n > c {
        partOne += 1;
    }

    a = b
    b = c
    c = n

    if a != -1 && b != -1 && c != -1 {
        let sum = a + b + c

        if sum > prevSum {
            partTwo += 1
        }

        prevSum = sum
    }
}

print(partOne)
print(partTwo)
