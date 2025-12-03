package main

import "core:fmt"
import "core:os"
import "core:slice"

index_of :: proc(e: byte, ar: []byte) -> int {
	for b, i in ar {
		if b == e {
			return i
		}
	}
	return -1
}

jolt::proc(line: []byte, n: int) -> int {
  start_n := 0
  s := 0
  for i in 0 ..< n {
    part := line[start_n:len(line) - n + i + 1]
    max_index := slice.max_index(part)
    s = s * 10 + int(part[max_index]) - 48
    start_n += max_index + 1
  }
  return s
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

	score1 := 0
  n1 := 2

  score2 := 0
  n2 := 12

	start := 0
	next_line_idx := index_of('\n', data[start:])
	for next_line_idx > -1 && start < len(data) {
		line := data[start:next_line_idx + start]

    s1 := jolt(line, n1)
    s2 := jolt(line, n2)

    fmt.println(string(line), s1, s2)

    score1 += s1
    score2 += s2

		start += next_line_idx + 1
		next_line_idx = index_of('\n', data[start:])
	}

	fmt.println("part 1 score =", score1)
  fmt.println("part 2 score =", score2)
}
