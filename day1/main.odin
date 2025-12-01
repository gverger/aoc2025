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

naive_second_part_update :: proc(current: state, clicks: int) -> state {
	position := current.position
	score := current.score

	if clicks > 0 {
		for i := 0; i < clicks; i += 1 {
			position += 1
			if position == 100 {
				position = 0
				score += 1
			}
		}
	} else if clicks < 0 {
		for i := 0; i < -clicks; i += 1 {
			position -= 1
			if position == 0 {
				score += 1
			}
			if position == -1 {
				position = 99
			}
		}
	}

	return {position = position, score = score}
}

second_part_update :: proc(current: state, clicks: int) -> state {
	position := current.position
	score := current.score
	clicks := clicks

	if clicks >= 100 {
		score += clicks / 100
		clicks = clicks %% 100
	} else if clicks <= -100 {
		score += (-clicks) / 100
		clicks = -((-clicks) %% 100)
	}

	position += clicks
	if position >= 100 {
		position -= 100
		score += 1
	} else if position < 0 {
		position += 100
		if current.position > 0 {
			score += 1
    }
  } else if position == 0 {
    score += 1
  }

	return {position = position, score = score}
}

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			} else {
				fmt.println("=== no allocation problem")
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

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

	state := state {
		position = 50,
		score    = 0,
	}

	for line in strings.split_lines_iterator(&it) {
		if len(line) == 0 {
			continue
		}

		operator := 1
		clicks := strconv.atoi(line[1:])

		if line[0] == 'L' {
			operator = -1
		} else if line[0] == 'R' {
			operator = 1
		} else {
			fmt.println("ERROR:", line)
			return
		}

		// state = first_part_update(state, operator * clicks)
		old_state := state
		sstate := second_part_update(old_state, operator * clicks)
		state = naive_second_part_update(old_state, operator * clicks)
		if state != sstate {
			fmt.printfln(
				"%s\tpos=%d\toperator=%d\tclicks=%d,update=%d",
				line,
				old_state.position,
				operator,
				clicks,
				state.score - old_state.score,
			)
			fmt.printfln("correct:%v\twrong:%v", state, sstate)
		}
	}

	fmt.printfln("score=%d\tposition=%d", state.score, state.position)

}
