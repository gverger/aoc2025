package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:strconv"
import "core:strings"

primes := [?]int{2, 3, 5, 7, 11, 13, 17, 19, 23, 29}

nb_digits :: proc(v: int) -> int {
	n := 1
	v := v
	if (v >= 1e16) {n += 16; v /= 1e16}
	if (v >= 1e8) {n += 8; v /= 1e8}
	if (v >= 1e4) {n += 4; v /= 1e4}
	if (v >= 1e2) {n += 2; v /= 1e2}
	if (v >= 1e1) {n += 1; v /= 1e1}
	return n
}

pow :: proc(n, p: int) -> int {
	result := 1
	for _ in 0 ..< p do result *= n
	return result
}

invalid :: proc(n: int, cut: int) -> bool {
	low := n %% cut
	current := n / cut
	for current > 0 {
		next := current %% cut
		if next != low {
			return false
		}
		low = next
		current = current / cut
	}
	return true
}

nb_invalid :: proc(start, finish: int) -> int {
	// fmt.println("======", start, finish, "======")
	d := nb_digits(start)

	score := 0
	for div in primes {
		if div > d {
			break
		}
		if d % div != 0 {
			continue
		}
		cut := pow(10, d / div)

		top_cut := pow(10, d - d / div)
		next_part := start / top_cut
		if next_part == 0 {
			break
		}
		top := 0
		for p := 0; p < div; p += 1 {
			top = top * pow(10, d / div) + next_part
		}
		s := start
		if top > start {
			s = top
		} else if top < start {
			top := 0
			for p := 0; p < div; p += 1 {
				top = top * pow(10, d / div) + next_part + 1
			}
			if top > start {
				s = top
			}
		}

		// fmt.printfln("start (%d): %d", div, s)

		for i := s; i <= finish; i += 1 {
			if invalid(i, cut) {
				already_found := false
				for div2 in primes {
					if div2 >= div {
						break
					}
					if d % div2 != 0 {
						continue
					}
					cut2 := pow(10, d / div2)
					if invalid(i, cut2) {
						// fmt.println("already found", i)
						already_found = true
						break
					}
				}
				if !already_found {
					// fmt.println("found", i)
					score += i
				}

				next_part := (i + 1) %% cut
				if next_part == 0 {
					break
				}
				top := 0
				for p := 0; p < div; p += 1 {
					top = top * pow(10, d / div) + next_part
				}
				// fmt.printfln("found (%d): %d %d %d", div, i, next_part, top)
				i = top - 1
			}
		}
	}

	return score
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

	defer delete(data, context.allocator)

	line := string(data)

	score := 0
	for interval in strings.split(line, ",") {
		bounds := strings.split_n(interval, "-", 2)
		start := strconv.atoi(bounds[0])
		finish := strconv.atoi(bounds[1])

		start_digits := nb_digits(start)
		finish_digits := nb_digits(finish)

		for d := start_digits; d <= finish_digits; d += 1 {
			s := math.max(start, pow(10, d - 1))
			f := math.min(finish, pow(10, d) - 1)
			score += nb_invalid(s, f)
		}

	}
	fmt.println("score:", score)
}
