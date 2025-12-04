package main

import "core:fmt"
import "core:os"

grid :: struct {
	rows:    int,
	columns: int,
	data:    [dynamic]bool,
}

vector2 :: struct {
	x, y: int,
}

index_of :: proc(e: byte, ar: []byte) -> int {
	for b, i in ar {
		if b == e {
			return i
		}
	}
	return -1
}

grid_size :: proc(data: []byte) -> (rows, columns: int) {
	start := 0
	next_line_idx := index_of('\n', data[start:])
	for next_line_idx > -1 && start < len(data) {
		line := data[start:next_line_idx + start]

		columns = len(line)
		rows += 1

		start += next_line_idx + 1
		next_line_idx = index_of('\n', data[start:])
	}

	return
}

create_grid :: proc(rows: int, columns: int) -> grid {
	return {columns = columns, rows = rows, data = make([dynamic]bool, columns * rows)}
}

index_at :: proc(g: grid, x, y: int) -> int {
	assert(in_grid(g, x, y))
	return x + y * g.columns
}

in_grid :: proc(g: grid, x, y: int) -> bool {
	return x >= 0 && x < g.columns && y >= 0 && y < g.rows
}

cell_at :: proc(g: grid, x, y: int, default: bool = false) -> bool {
	return g.data[index_at(g, x, y)]
}

update_at :: proc(g: grid, x, y: int, value: bool) {
	g.data[index_at(g, x, y)] = value
}

count_neighbors :: proc(g: grid, x, y: int, directions: []vector2) -> int {
	count := 0
	for d in directions {
		nx := x + d.x
		ny := y + d.y

		if in_grid(g, nx, ny) && cell_at(g, nx, ny) {
			count += 1
		}
	}
	return count
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

	nb_rows, nb_cols := grid_size(data)

	g := create_grid(nb_rows, nb_cols)


	start := 0
	next_line_idx := index_of('\n', data[start:])
	y := 0
	for next_line_idx > -1 && start < len(data) {
		line := data[start:next_line_idx + start]
		x := 0

		for c in line {
			if c == '.' {
				update_at(g, x, y, false)
			} else if c == '@' {
				update_at(g, x, y, true)
			} else {
				fmt.println("?")
				return
			}
			x += 1
		}

		start += next_line_idx + 1
		next_line_idx = index_of('\n', data[start:])
		y += 1
	}

	directions := []vector2 {
		{x = -1, y = -1},
		{x = -1, y = 0},
		{x = -1, y = 1},
		{x = 0, y = -1},
		{x = 0, y = 1},
		{x = 1, y = -1},
		{x = 1, y = 0},
		{x = 1, y = 1},
	}

	g_after := create_grid(g.rows, g.columns)

	score := 0
	updating := true

	for updating {
		updating = false
		s := 0

		for row in 0 ..< g.rows {
			for col in 0 ..< g.columns {
				if cell_at(g, col, row) {
					if count_neighbors(g, col, row, directions) < 4 {
						update_at(g_after, col, row, false)
						updating = true
						// fmt.print("@")
						s += 1
					} else {
						// fmt.print("X")
						update_at(g_after, col, row, true)
					}
				} else {
					// fmt.print(" ")
					update_at(g_after, col, row, false)
				}
			}
		}
		fmt.println("delete:", s)
		score += s
		g, g_after = g_after, g
	}

	fmt.println("score=", score)
}
