/// After generating fish generations for the first few dozen days
/// I noticed that same subsequences repeat over and over again
/// If F(n) gives the number of fish after n days,
/// F(n) = F(n-9) + F(n-7)

open System.IO

/// Read input file into a sequence of integers
let input = 
    (File.ReadAllText "input.txt").Split [|','|]
    |> Seq.ofArray
    |> Seq.map int

/// Generate counts for N days
let rec genCounts days prevCounts =
    match (List.length prevCounts) with
    | i when i > days -> prevCounts
    | i -> 
        let count = if i < 9 then 1UL else (prevCounts[i-7]+prevCounts[i-9])
        genCounts days (List.append prevCounts [count])

/// Calculate count for given sequence after N days
let countAfterDays sequence days =
    let counts = genCounts days []
    sequence
    |> Seq.map (fun n -> counts[days-n+1] + counts[days-n-1])
    |> Seq.sum

let printSolution days =
    countAfterDays input days
    |> printfn "%A"

// Part one
printSolution 80

// Part two
printSolution 256