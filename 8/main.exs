# Each segment can be represented as a byte where
# a == 0x1, b == 0x2, c == 0x3 and so on.
# The patterns can then be compared and manipulated
# with bitwise operations, e.g. nine == three | four

use Bitwise

defmodule App do
    # Convert pattern string to bitmask,
    # e.g. "abd" -> 0b0001011
    def to_bitmask(val) do
        val
        |> String.to_charlist
        |> Enum.map(fn c -> 1 <<< (c-97) end)
        |> Enum.sum
    end

    # Count the number of segments in a pattern
    # using a lookup table
    @lookup [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
    def segment_count(bitmask) do
        Enum.at(@lookup, bitmask &&& 0xf) + Enum.at(@lookup, (bitmask >>> 4 &&& 0xf))
    end

    # Find a pattern with given count after XORring with given mask
    def find_with_segment_count(patterns, count, mask \\ 0x00) do
        patterns |> Enum.find(fn pattern -> App.segment_count(bxor(pattern, mask)) == count end)
    end

    # Sort patterns based on the digit they represent
    def sort_patterns(patterns) do
        eight = 0x7F
        seven = App.find_with_segment_count(patterns, 3)
        three = App.find_with_segment_count(patterns, 2, seven)
        four = App.find_with_segment_count(patterns, 4)
        one = seven &&& four
        six = App.find_with_segment_count(patterns, 1, bxor(one, eight))
        nine = (three ||| four)
        five = bxor(~~~nine, six) &&& eight
        zero = (~~~four ||| one ||| ~~~three) &&& eight
        two = (bxor(three, one) ||| ~~~five) &&& eight

        [zero, one, two, three, four, five, six, seven, eight, nine]
    end

    # Get the output digits for a row
    def row_output_digits(row) do
        {patterns, output} = row
        patterns = App.sort_patterns(patterns)

        output
        |> Enum.map(fn item -> Enum.find_index(patterns, fn x -> x == item end) end)
    end

    # Converts puzzle input to a list of four-digit values
    def prepare_input() do
        File.read!("input.txt")
        |> String.replace([" | ", "\n"], " ")
        |> String.split(" ")
        |> Enum.map(fn n -> n |> App.to_bitmask end)
        |> Enum.chunk_every(14)
        |> Enum.map(fn row -> Enum.split(row, 10) |> App.row_output_digits end)
        |> List.flatten
    end

    def part_one(digits) do
        digits
        |> Enum.count(fn n -> Enum.member?([1,4,7,8], n) end)
        |> IO.inspect
    end

    def part_two(digits) do
        digits
        |> Enum.with_index
        |> Enum.map(fn {n, i} -> 10**(3-(rem(i, 4))) * n end)
        |> Enum.sum
        |> IO.inspect
    end

    def solve() do
        digits = App.prepare_input()
        digits |> App.part_one
        digits |> App.part_two
    end
end

App.solve()
