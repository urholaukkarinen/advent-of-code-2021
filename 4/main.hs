{-# LANGUAGE OverloadedStrings #-}

import Data.List (transpose)
import Data.Text (Text, pack, splitOn, unpack)

type Board = [[Int]]

toInt :: String -> Int
toInt n = read n :: Int

-- Take puzzle input and return the numbers to draw
getNumbers :: [Text] -> [Int]
getNumbers = map (toInt . unpack) . splitOn "," . head

-- Add board transposes
withTransposes :: [[Board]] -> [[Board]]
withTransposes = map (\boards -> boards ++ map transpose boards)

-- Take puzzle input and return the boards
getBoards :: [Text] -> [[Board]]
getBoards = withTransposes . map ((: []) . (map (map toInt . words . unpack) . splitOn "\n")) . drop 1

takeUntil :: (a -> Bool) -> [a] -> [a]
takeUntil _ [] = []
takeUntil p (x : xs) =
  x :
  if not (p x)
    then takeUntil p xs
    else []

winning :: Board -> Bool
winning = any null

hasWinner :: [[Board]] -> Bool
hasWinner = any (any winning)

noWinner :: [[Board]] -> Bool
noWinner = not . hasWinner

withoutWinners :: [[Board]] -> [[Board]]
withoutWinners = filter (not . any winning)

winner :: [[Board]] -> Board
winner = head . head . filter (not . null) . map (filter winning)

deleteAll :: Int -> Board -> Board
deleteAll a = map (filter (/= a))

applyNumber :: Int -> [[Board]] -> [[Board]]
applyNumber a = map (map (deleteAll a))

applyNextNumber :: ([[Board]], [Int]) -> ([[Board]], [Int])
applyNextNumber (boards, []) = (boards, [])
applyNextNumber (boards, numbers) = (applyNumber (head numbers) boards, tail numbers)

applyNumbers :: [Int] -> [[Board]] -> [([[Board]], [Int])]
applyNumbers numbers boards = takeUntil (\(_, nums) -> null nums) (iterate applyNextNumber (boards, numbers))

applyNumbersUntilNextWinner :: [Int] -> [[Board]] -> [([[Board]], [Int])]
applyNumbersUntilNextWinner numbers boards = takeUntil (\(a, nums) -> hasWinner a) (applyNumbers numbers boards)

getNextWinner :: [Int] -> [[Board]] -> (Board, [[Board]], [Int])
getNextWinner numbers boards = do
  let (latestBoards, remainingNumbers) = last (applyNumbersUntilNextWinner numbers boards)
  if noWinner latestBoards
    then ([], withoutWinners latestBoards, remainingNumbers)
    else (winner latestBoards, withoutWinners latestBoards, remainingNumbers)

getLastWinner :: Board -> [Int] -> [[Board]] -> (Board, [Int])
getLastWinner previousWinner numbers boards = do
  let (currentWinner, remainingBoards, remainingNumbers) = getNextWinner numbers boards
  if null currentWinner
    then (previousWinner, numbers)
    else getLastWinner currentWinner remainingNumbers remainingBoards

getResult :: [Int] -> (Board, [Int]) -> Int
getResult numbers (board, remainingNumbers) = sum (map sum board) * (numbers !! ((length numbers - length remainingNumbers) - 1))

main :: IO ()
main = do
  text <- readFile "input.txt"
  let input = splitOn "\n\n" (pack text)
  let boards = getBoards input
  let allNumbers = getNumbers input

  -- Part one
  let (firstWinningBoard, _, remainingNumbers) = getNextWinner allNumbers boards
  print (getResult allNumbers (firstWinningBoard, remainingNumbers))

  -- Part two
  print (getResult allNumbers (getLastWinner [] allNumbers boards))
