package main

import "core:fmt"
import "core:os"
import "core:slice"

index_of_byte :: proc(e: byte, ar: []byte) -> int {
	for b, i in ar {
		if b == e {
			return i
		}
	}

	return -1
}

index_of :: proc {
	index_of_byte,
}

main :: proc() {
	if len(os.args) < 2 {
		fmt.println("Missing argument: input file")
		return
	}

	data, ok := os.read_entire_file_from_filename(os.args[1])

	if !ok {
		os.exit(1)
	}

	defer delete(data)

	score := 0

	start := 0
	next_line_idx := index_of('\n', data[start:])
	line := data[start:next_line_idx + start]
	// fmt.println(string(line))
	t := index_of('S', line)
	current_tachyons := make([]int, len(line))
	next_tachyons := make([]int, len(line))
	current_tachyons[t] = 1

	start += next_line_idx + 1
	next_line_idx = index_of('\n', data[start:])
	for start < len(data) {
		// for t in current_tachyons {
		// 	if t > 0 {
		// 		fmt.print("|")
		// 	} else {
		// 		fmt.print(" ")
		// 	}
		// }
		// fmt.println()

		line = data[start:next_line_idx + start]
		// fmt.println(string(line))
		slice.fill(next_tachyons, 0)

		for t, i in current_tachyons {
			if t == 0 {
				continue
			}
			if line[i] == '^' {
				score += 1
				if i > 0 {
					next_tachyons[i - 1] += current_tachyons[i]
				}
				if i < len(next_tachyons) - 1 {
					next_tachyons[i + 1] += current_tachyons[i]
				}
			} else {
				next_tachyons[i] += current_tachyons[i]
			}
		}

		start += next_line_idx + 1
		next_line_idx = index_of('\n', data[start:])
		copy(current_tachyons, next_tachyons)
	}

	fmt.println("part1 =", score)
	score = 0
	for t in current_tachyons {
		score += t
	}
	fmt.println("part2 =", score)
}
