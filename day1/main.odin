package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:strconv"
import "core:strings"

state :: struct {
	position: int,
	score:    int,
}

first_part_update :: proc(current: state, clicks: int) -> state {
	position := current.position
	score := current.score

	position += clicks
	for position < 0 {
		position += 100
	}
	for position > 99 {
		position -= 100
	}
	if position == 0 {
		score += 1
	}

	return {position = position, score = score}
}

second_part_update :: proc(current: state, clicks: int) -> state {
	position := current.position
	score := current.score
	clicks := clicks

  score += abs(clicks) / 100
	if clicks >= 100 {
		clicks = clicks %% 100
	} else if clicks <= -100 {
		clicks = -((-clicks) %% 100)
	}

	position += clicks
	if position >= 100 {
		score += 1
	} else if position <= 0 && current.position > 0 {
    score += 1
  }
  position = position %% 100

	return {position = position, score = score}
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

	it := string(data)

  first_state := state {
    position = 50,
    score    = 0,
  }

  second_state := state {
    position = 50,
    score    = 0,
  }

	for line in strings.split_lines_iterator(&it) {
		if len(line) == 0 {
			continue
		}

		operator: int
		clicks := strconv.atoi(line[1:])

		if line[0] == 'L' {
			operator = -1
		} else if line[0] == 'R' {
			operator = 1
		} else {
			fmt.println("ERROR:", line)
			return
		}

		old_state := second_state
    first_state = first_part_update(first_state, operator * clicks)
		second_state = second_part_update(second_state, operator * clicks)
	}

	fmt.printfln("First  part: score=%d\tposition=%d", first_state.score, first_state.position)
  fmt.printfln("Second part: score=%d\tposition=%d", second_state.score, second_state.position)

}
