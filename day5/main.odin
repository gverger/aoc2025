package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:strconv"
import "core:strings"


Interval :: struct {
	first: int,
	last:  int,
}

in_interval :: proc(n: int, interval: Interval) -> bool {
	return n >= interval.first && n <= interval.last
}

has_overlap :: proc(interval1, interval2: Interval) -> bool {
	return(
		(interval1.first <= interval2.first && interval1.last >= interval2.first) ||
		(interval2.first <= interval1.first && interval2.last >= interval1.first) \
	)
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

	content := string(data)

	score := 0
	intervals := make([dynamic]Interval, 0)

	parts := strings.split(content, "\n\n")
	assert(len(parts) == 2)

	for interval in strings.split_lines(parts[0]) {
		if len(interval) == 0 {
			break
		}
		bounds := strings.split_n(interval, "-", 2)
		start := strconv.atoi(bounds[0])
		finish := strconv.atoi(bounds[1])
		append(&intervals, Interval{first = start, last = finish})
	}

	for id in strings.split_lines(parts[1]) {
		if len(id) == 0 {
			break
		}
		id := strconv.atoi(id)

		for interval in intervals {
			if in_interval(id, interval) {
				score += 1
				break
			}
		}
	}
	fmt.println("fresh among ids =", score)

	merged := make([dynamic]Interval, 0, len(intervals))
	for interval, i in intervals {
		overlaps := make([dynamic]int, 0)
		for interval2, j in merged {
			if has_overlap(interval, interval2) {
				append(&overlaps, j)
			}
		}

		intv := Interval {
			first = interval.first,
			last  = interval.last,
		}
		for idx in overlaps {
			o := merged[idx]
			intv = Interval {
				first = math.min(intv.first, o.first),
				last  = math.max(intv.last, o.last),
			}
		}
		#reverse for idx in overlaps {
			remove_range(&merged, idx, idx+1)
		}
		append(&merged, intv)
	}

  score2 := 0
  for interval in merged {
    score2 += interval.last - interval.first + 1
  }

  fmt.println("total nb of fresh=", score2)

}
