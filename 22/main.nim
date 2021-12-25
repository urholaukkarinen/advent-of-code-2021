import strutils
import sequtils

proc overlap(a: seq[int], b: seq[int]): seq[int] =
    let new_x1 = max(a[0], b[0])
    let new_x2 = min(a[1], b[1])
    let new_y1 = max(a[2], b[2])
    let new_y2 = min(a[3], b[3])
    let new_z1 = max(a[4], b[4])
    let new_z2 = min(a[5], b[5])
    if new_x1 > new_x2 or new_y1 > new_y2 or new_z1 > new_z2:
        return @[]
    return @[new_x1, new_x2, new_y1, new_y2, new_z1, new_z2]

proc cut(a: seq[int], b: seq[int]): seq[seq[int]] =
    var a = overlap(a, b)
    var b = b

    if len(a) == 0:
        return @[]

    var pieces = newSeq[seq[int]]()
    while true:
        var next = false
        for i in countup(0, 5, 2):
            if a[i] > b[i]:
                pieces.add(b[0..i] & @[a[i]-1] & b[i+2.. ^1])
                b = b[0..i-1] & @[a[i]] & b[i+1.. ^1]
                next = true
                break
            if a[i+1] < b[i+1]:
                pieces.add(b[0..i-1] & @[a[i+1]+1] & b[i+1.. ^1])
                b = b[0..i] & @[a[i+1]] & b[i+2.. ^1]
                next = true
                break
        if not next:
            break
    pieces.add(a)
    pieces

proc area(a: seq[int]): int =
    abs(a[1]-a[0]+1) * abs(a[3]-a[2]+1) * abs(a[5]-a[4]+1)

proc inside_init_region(a: seq[int]): bool =
    a[0] >= -50 and a[1] <= 50 and a[2] >= -50 and a[3] <= 50 and a[4] >= -50 and a[5] <= 50

var rects = newSeq[(bool, seq[int])]()
var part_one = 0
var score = 0

for line in readFile("input.txt").split({'\n'}):
    let items = line.split(" ")
    var coords = newSeq[int](6)
    let c = items[1].split(",").mapIt(it.split("=")[1].split("..").map(parseInt))
    for i in countup(0, 2):
        coords[i*2] = c[i][0]
        coords[i*2+1] = c[i][1]
    rects.add((items[0] == "on", coords))

var i = 0
while i < len(rects):
    if part_one == 0 and not inside_init_region(rects[i][1]):
        part_one = score
    if rects[i][0]:
        score += area(rects[i][1])

    var j = 0
    while j < i:
        if not rects[j][0]:
            j += 1
            continue
        let pieces = cut(rects[i][1], rects[j][1])
        let piece_count = len(pieces)
        if piece_count > 0:
            score -= area(pieces[^1])
            let j_score = rects[j][0]
            rects = rects[0..j-1] & pieces[0.. ^2].mapIt((j_score, it)) & rects[j+1.. ^1]
            j += piece_count-1
            i += piece_count-2
        else:
            j += 1
    i += 1

echo part_one
echo score