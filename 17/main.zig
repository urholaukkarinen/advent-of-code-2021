const std = @import("std");
const os = std.os;
const print = std.debug.print;

const input = @embedFile("input.txt");

fn parseInput() [4]i32 {
    var it = std.mem.tokenize(input, " ,=.");
    var i: usize = 0;
    var vals = [_]i32{ 0, 0, 0, 0 };

    while (it.next()) |item| {
        vals[i] = std.fmt.parseInt(i32, item, 10) catch continue;
        i += 1;
    }

    return vals;
}

pub fn main() !void {
    const vals = parseInput();

    var minX = vals[0];
    var maxX = vals[1];
    var minY = vals[2];
    var maxY = vals[3];

    var partOne: i32 = -minY - 1;
    partOne = @divFloor(partOne * (partOne + 1), 2);
    var partTwo: i32 = 0;

    var x: i32 = 0;
    while (x <= maxX) : (x += 1) {
        var y: i32 = minY;

        while (y < -minY) : (y += 1) {
            var nx: i32 = 0;
            var ny: i32 = 0;
            var i: i32 = 0;

            while (true) : (i += 1) {
                if (i <= x) {
                    nx += x - i;
                }
                ny += y - i;

                if (nx >= minX and nx <= maxX and ny >= minY and ny <= maxY) {
                    partTwo += 1;
                    break;
                } else if (nx > maxX or ny < minY) {
                    break;
                }
            }
        }
    }

    print("{d}\n{d}\n", .{ partOne, partTwo });
}
