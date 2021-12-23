package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

const steps = 50
const pad = steps * 2
const inputW = 100
const inputH = 100
const w = pad*2 + inputW
const h = pad*2 + inputH
const inputFile = "input.txt"

type Img [w][h]int

func drawImg(img Img) {
	for _, row := range img {
		for _, n := range row {
			if n == 1 {
				fmt.Print("#")
			} else {
				fmt.Print(".")
			}
		}
		fmt.Println()
	}
}

func countLightPixels(img Img) int {
	count := 0
	for y := steps; y < h-steps; y++ {
		for x := steps; x < w-steps; x++ {
			if img[y][x] == 1 {
				count += 1
			}
		}
	}
	return count
}

func main() {
	data, _ := ioutil.ReadFile(inputFile)
	parts := strings.Split(string(data), "\n\n")

	var alg [512]int
	for i, c := range parts[0] {
		if c == '#' {
			alg[i] = 1
		}
	}

	var img Img

	for y, line := range strings.Split(parts[1], "\n") {
		for x, c := range line {
			if c == '#' {
				x2 := pad + x
				y2 := pad + y
				img[y2][x2] = 1
			}
		}
	}

	for step := 0; step < steps; step += 1 {
		img_copy := img
		for y := 1; y < h-1; y++ {
			for x := 1; x < w-1; x++ {
				alg_idx := 0
				i := 0
				for y2 := y - 1; y2 <= y+1; y2++ {
					for x2 := x - 1; x2 <= x+1; x2++ {
						alg_idx += img[y2][x2] << (8 - i)
						i += 1
					}
				}
				img_copy[y][x] = alg[alg_idx]
			}
		}
		img = img_copy

		if step == 1 {
			// Part one
			fmt.Println(countLightPixels(img))
		}
	}

	// Part two
	fmt.Println(countLightPixels(img))
}
