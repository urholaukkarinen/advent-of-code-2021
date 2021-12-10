<?php

$pairs = [
    "(" => ")",
    "<" => ">",
    "[" => "]",
    "{" => "}",
];

$score_map = [
    ")" => [3, 1],
    "]" => [57, 2],
    "}" => [1197, 3],
    ">" => [25137, 4],
];

$input = explode("\r\n", file_get_contents("input.txt"));

$part_one = 0;
$part_two_scores = [];

foreach ($input as $row) {
    $stack = [];

    for ($i = 0; $i < strlen($row); $i++){
        $a = $row[$i];

        if (isset($pairs[$a])) {
            array_push($stack, $pairs[$a]);
        } elseif ($a != array_pop($stack)) {
            $part_one += $score_map[$a][0];
        }
    }

    if (!empty($stack)) {
        $score = 0;
        while ($n = array_pop($stack)) {
            $score = $score * 5 + $score_map[$n][1];
        }
        array_push($part_two_scores, $score);
    }
}

sort($part_two_scores);
$part_two = $part_two_scores[count($part_two_scores) / 2];

echo $part_one, "\n";
echo $part_two, "\n";

?>