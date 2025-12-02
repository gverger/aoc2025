package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

number :: [?]int{2, 3, 5, 7, 11, 13, 17}

nb_digits :: proc(n: int) -> int {
	if n == 0 {
		return 1
	}

	digits := 0
	n := n
	for n > 0 {
		n /= 10
		digits += 1
	}

	return digits
}

pow :: proc(n, p: int) -> int {
	result := 1
	for _ in 0 ..< p do result *= n
	return result
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

		for i := start; i <= finish; i += 1 {
			d := nb_digits(i)
			for div := 2; div <= d; div += 1 {
				if d % div != 0 {
					continue
				}
				cut := pow(10, d / div)
				low := i %% cut
				current := i / cut
				all_equal := true
				for current > 0 {
					next := current %% cut
					if next != low {
						all_equal = false
						break
					}
					low = next
					current = current / cut
				}

				if all_equal {
					// fmt.println("found", i)
					score += i
					break
				}
			}
		}
	}
	fmt.println("score:", score)
}
