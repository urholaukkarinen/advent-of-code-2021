class Main {
    static public function main():Void {
        var solver = new Solver("input.txt");

        var dotsAfterFirstFold = 0;
        while (solver.foldNext()) {
            if (dotsAfterFirstFold == 0) {
                dotsAfterFirstFold = solver.numberOfDots();
            }
        }

        // Part one
        Sys.println(dotsAfterFirstFold);
        // Part two
        solver.print();
    }
}

class Solver {
    var grid:Array<Array<Int>>;
    var width:Int;
    var height:Int;
    var folds:Array<String>;

    public function new(file:String) {
        var data = sys.io.File.getContent(file).split("\r\n\r\n").map(s -> s.split("\r\n"));
        var dots = [];
        var width = 0;
        var height = 0;

        for (item in data[0]) {
            var dot = item.split(",").map(s -> Std.parseInt(s));
            var x = dot[0];
            var y = dot[1];
            width = Std.int(Math.max(x + 1, width));
            height = Std.int(Math.max(y + 1, height));
            dots.push([x, y]);
        }

        var grid = [for (_ in 0...width) [for (_ in 0...height) 0]];
        for (dot in dots) {
            grid[dot[0]][dot[1]] = 1;
        }

        this.grid = grid;
        this.width = width;
        this.height = height;
        this.folds = data[1];
        this.folds.reverse();
    }

    public function foldNext():Bool {
        if (this.folds.length == 0) {
            return false;
        }

        var item = this.folds.pop();
        var fold = item.split("=");
        var pos = Std.parseInt(fold[1]);

        if (fold[0].substr(-1) == "y") {
            this.foldVertical(pos);
        } else {
            this.foldHorizontal(pos);
        }

        return true;
    }

    function foldHorizontal(x:Int) {
        for (y2 in 0...this.height) {
            for (x2 in 1...(this.width - x)) {
                this.grid[x - x2][y2] = Std.int(Math.max(this.grid[x - x2][y2], this.grid[x + x2][y2]));
                this.grid[x + x2][y2] = 0;
            }
        }
        this.width = x;
    }

    function foldVertical(y:Int) {
        for (x2 in 0...this.width) {
            for (y2 in 1...(this.height - y)) {
                this.grid[x2][y - y2] = Std.int(Math.max(this.grid[x2][y - y2], this.grid[x2][y + y2]));
                this.grid[x2][y + y2] = 0;
            }
        }
        this.height = y;
    }

    public function numberOfDots():Int {
        var count = 0;
        for (col in this.grid) {
            for (cell in col) {
                count += cell;
            }
        }
        return count;
    }

    public function print() {
        for (y in 0...this.height) {
            for (x in 0...this.width) {
                if (this.grid[x][y] > 0) {
                    Sys.print("#");
                } else {
                    Sys.print(" ");
                }
            }
            Sys.println("");
        }
    }
}
