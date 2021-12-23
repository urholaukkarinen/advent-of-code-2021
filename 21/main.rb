
def start_positions()
    return File.read("input.txt").split("\n").map { |line| line[-1].to_i }
end

def part_one()
    positions = start_positions()
    scores = [0, 0]
    dice = 0
    rolls = 0

    while true do
        for i in 0..(positions.length()-1)
            move = 0
            for _ in 0..2
                rolls += 1
                dice += 1
                move += dice
            end

            positions[i] = ((positions[i] + move) - 1) % 10 + 1
            scores[i] += positions[i]
            if scores[i] >= 1000
                puts scores.min * rolls
                return
            end
        end
    end
end

def part_two()
    $counts = [1, 3, 6, 7, 6, 3, 1]
    $wins = [0, 0]

    def roll(player, move, scores, positions, count)
        positions[player] = ((positions[player] + move) - 1) % 10 + 1
        scores[player] += positions[player]

        if scores[player] >= 21
            $wins[player] += count
            return
        end

        for i in 0..6
            roll((player+1)%2, i+3, scores.dup, positions.dup, count * $counts[i])
        end
    end

    positions = start_positions()
    for i in 0..6
        roll(0, i+3, [0, 0], positions.dup, $counts[i])
    end
    puts $wins.max
end

part_one()
part_two()
