import std.stdio, std.string, std.ascii, std.algorithm, std.conv;

void main() {
    Cave cave = Cave.load("input.txt");

    // Part one
    writeln(cave.paths(1).length);

    // Part two
    writeln(cave.paths(2).length);
}

class Cave {
    private string[][string] edges;

    static Cave load(string filename) {
        Cave cave = new Cave();

        foreach (segment; File(filename)
        .byLine(KeepTerminator.no, "\r\n")
        .map!(l => l.split("-"))) {
            string start = to!string(segment[0]);
            string end = to!string(segment[1]);

            cave.add_segment(start, end);
        }

        return cave;
    }

    private void add_segment(string from, string to) {
        this.add_edge(from, to);
        if (from != "start") {
            this.add_edge(to, from);
        }
    }

    private void add_edge(string from, string to) {
        this.edges.update(from, {
            return [to];
        }, (ref string[] a){
            return a ~ [to];
        });
    }

    string[][] paths(int max_small_visits) {
        return traverse("start", [], null, max_small_visits);
    }

    private string[][] traverse(string node, string[] path, int[string] visited, int max_small_visits) {
        if (node == "end") {
            return [path];
        }

        string[][] paths = [];
        path ~= [node];
        visited[node] += 1;

        foreach (next; this.edges[node]) {
            auto v = max_small_visits;
            
            if (isLower(next[0])) {
                v -= visited.get(next, 0);
                if (v <= 0) {
                    continue;
                }
            }

            paths ~= traverse(next, path.dup, visited.dup, v);
        }

        return paths;
    }
}