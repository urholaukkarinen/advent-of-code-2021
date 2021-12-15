from heapq import heappop, heappush


with open("input.txt") as f:
    data = [list(map(int, list(row))) for row in f.read().split("\n")]


def neighbors(x, y, w, h):
    if x > 0:
        yield x-1, y
    if y > 0:
        yield x, y-1
    if x < w-1:
        yield x+1, y
    if y < h-1:
        yield x, y+1


def find(mul):
    to_visit = [(0, 0, 0)]
    best_risks = dict()

    w = len(data[0])
    h = len(data)

    mw = w * mul
    mh = h * mul

    while to_visit:
        (risk, x, y) = heappop(to_visit)

        if x == mw-1 and y == mh-1:
            return risk

        for nx, ny in neighbors(x, y, mw, mh):
            nr = risk + \
                (((data[ny % h][nx % w] +
                   (nx // w) + (ny // h)-1) % 9)+1)

            if nr < best_risks.get((nx, ny), 1e10):
                best_risks[(nx, ny)] = nr
                heappush(to_visit, (nr, nx, ny))


# Part one
print(find(1))
# Part two
print(find(5))
