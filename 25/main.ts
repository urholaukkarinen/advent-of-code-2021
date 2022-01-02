const text = await Deno.readTextFile("input.txt");
let prev = text.replaceAll("\n", "").split('');
const width = text.indexOf("\n");
const height = prev.length / width;


let steps = 0;
let changed = true;

while (changed) {
    changed = false;
    const next = [...prev];

    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            if (prev[y * width + x] == '>') {
                if (x < width-1 && prev[y * width + x + 1] == '.') {
                    next[y * width + x] = '.';
                    next[y * width + x + 1] = '>';
                    changed = true;
                } else if (x == width-1 && prev[y*width] == '.') {
                    next[y * width + x] = '.';
                    next[y * width] = '>';
                    changed = true;
                }
            }
        }
    }

    prev = [...next];

    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            if (prev[y * width + x] == 'v') {
                if (y < height-1 && prev[(y+1) * width + x] == '.') {
                    next[y * width + x] = '.';
                    next[(y+1) * width + x] = 'v';
                    changed = true;
                } else if (y == height-1 && prev[x] == '.') {
                    next[y * width + x] = '.';
                    next[x] = 'v';
                    changed = true;
                }
            }
        }
    }

    prev = next;

    steps += 1;
}

console.log(steps);