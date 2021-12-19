#[derive(Copy, Clone, Debug)]
enum Cell {
    Single(u32, usize),
    Pair((u32, u32), usize),
}

impl Cell {
    fn layer(&self) -> usize {
        match self {
            Cell::Single(_, layer) | Cell::Pair(_, layer) => *layer
        }
    }

    fn layer_mut(&mut self) -> &mut usize {
        match self {
            Cell::Single(_, layer) | Cell::Pair(_, layer) => layer
        }
    }

    fn first(&self) -> u32 {
        match self {
            Cell::Single(a, _) => *a,
            Cell::Pair((a, _), _) => *a
        }
    }

    fn first_mut(&mut self) -> &mut u32 {
        match self {
            Cell::Single(a, _) => a,
            Cell::Pair((a, _), _) => a
        }
    }

    fn last_mut(&mut self) -> &mut u32 {
        match self {
            Cell::Single(a, _) => a,
            Cell::Pair((_, b), _) => b
        }
    }
}

impl From<(&[u32], usize)> for Cell {
    fn from((digits, layer): (&[u32], usize)) -> Self {
        if digits.len() == 1 {
            Cell::Single(digits[0], layer)
        } else {
            Cell::Pair((digits[0], digits[1]), layer)
        }
    }
}

fn parse(line: &str) -> Vec<Cell> {
    let mut layer : usize = 0;
    let mut vals = Vec::with_capacity(2);
    let mut cells : Vec<Cell> = Vec::new();

    for c in line.chars() {
        if let Some(digit) = c.to_digit(10) {
            vals.push(digit);
        } else if c == '[' {
            if !vals.is_empty() {
                cells.push((vals.as_slice(), layer).into());
                vals.clear();
            }
            layer += 1;
        } else if c == ']' {
            if !vals.is_empty() {
                cells.push((vals.as_slice(), layer - (vals.len() - 1)).into());
                vals.clear();
            }
            layer -= 1;
        }
    }

    cells
}

fn explode_once(cells: &mut Vec<Cell>) -> bool {
    for i in 0..cells.len() {
        if let Cell::Pair((a, b), 4) = cells[i] {
            cells[i] = Cell::Single(0, 4);

            let mut remove = false;
            if i > 0 {
                *cells[i-1].last_mut() += a;

                if let Cell::Single(prev, 4) = cells[i-1] {
                    cells[i-1] = Cell::Pair((prev, 0), 3);
                    remove = true;
                }
            }

            if i < cells.len() - 1 {
                *cells[i+1].first_mut() += b;

                if !remove {
                    if let Cell::Single(next, 4) = cells[i+1] {
                        cells[i+1] = Cell::Pair((0, next), 3);
                        remove = true;
                    }
                }
            }

            if remove {
                cells.remove(i);
            }

            return true;
        }
    }

    false
}

fn split_once(cells: &mut Vec<Cell>) -> bool {
    for i in 0..cells.len() {
        match cells[i] {
            Cell::Single(n, l) if n >= 10 => {
                let a = n / 2;
                let b = n - a;
                cells[i] = Cell::Pair((a, b), l);
                return true;
            },
            Cell::Pair((n1, n2), l) if n1 >= 10 => {
                let a = n1 / 2;
                let b = n1 - a;
                cells[i] = Cell::Single(n2, l+1);
                cells.insert(i, Cell::Pair((a, b), l+1));
                return true;
            },
            Cell::Pair((n1, n2), l) if n2 >= 10 => {
                let a = n2 / 2;
                let b = n2 - a;
                cells[i] = Cell::Single(n1, l+1);
                cells.insert(i+1, Cell::Pair((a, b), l+1));
                return true;
            }
            _ => {}
        }
    }

    false
}

fn sum(first: &[Cell], second: &[Cell]) -> Vec<Cell> {
    let mut cells = first.to_vec();
    cells.extend(second);

    for cell in &mut cells {
        *cell.layer_mut() += 1;
    }

    while explode_once(&mut cells) || split_once(&mut cells) {}

    cells
}

fn to_magnitude(mut cells: Vec<Cell>) -> u32 {
    while cells.len() > 1 {
        for i in 0..cells.len() {
            
            if let Cell::Pair((a, b), l) = cells[i] {
                cells[i] = Cell::Single(a*3 + b*2, l);
            }

            if i > 0 && cells[i-1].layer() == cells[i].layer() {
                cells[i] = Cell::Pair((cells[i-1].first(), cells[i].first()), cells[i].layer()-1);
                cells.remove(i-1);
                break;
            }
        }
    }

    match cells[0] {
        Cell::Single(n, _) => n,
        Cell::Pair((a, b), _) => a*3 + b*2
    }
}

fn parse_input() -> Vec<Vec<Cell>> {
    std::fs::read_to_string("input.txt").unwrap()
        .split("\n")
        .map(|line| parse(line)).collect::<Vec<_>>()
}

fn part_one() {
    let magnitude = to_magnitude(parse_input().into_iter().reduce(|a, b| sum(&a, &b)).unwrap());
    println!("{}", magnitude);
}

fn part_two() {
    let numbers = parse_input();
    let mut largest_magnitude = 0;
    for i in 0..numbers.len() {
        for j in (i+1)..numbers.len() {
            largest_magnitude = u32::max(largest_magnitude, u32::max(
                to_magnitude(sum(&numbers[j], &numbers[i])),
                to_magnitude(sum(&numbers[i], &numbers[j]))));
        }
    }
    println!("{}", largest_magnitude);
}

fn main() {
    part_one();
    part_two();
}
