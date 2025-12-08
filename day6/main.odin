package main

import "core:math"
import "core:strconv"
import "core:fmt"
import "core:os"
import "core:strings"

Operation :: enum {
  PLUS,
  MULT,
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
  lines := make([dynamic]string, 0)
  for line in strings.split_lines(content) {
    if len(line) == 0 {
      continue
    }
    append(&lines, line)
  }

  operations := make([dynamic]Operation, 0)
  i := 0
  for op in strings.split(lines[len(lines)-1], " ") {
    if len(op) == 0 {
      continue
    }
    if op == "+" {
      append(&operations, Operation.PLUS)
    } else if op == "*" {
      append(&operations, Operation.MULT)
    } else {
      fmt.eprintfln("error: operation not permitted: '%s'", op)
    }
    i+=1
  }

  numbers := make([]int, len(operations))

  for line, il in lines[:len(lines)-1] {
    i = 0
    for nb in strings.split(line, " ") {
      if len(nb) == 0 {
        continue
      }
      n := strconv.atoi(nb)
      if il == 0 {
        numbers[i] = n
      }
      else if operations[i] == Operation.PLUS {
        numbers[i] += n
      } else {
        numbers[i] *= n
      }

      i += 1
    }
  }

  score = math.sum(numbers)
  fmt.println("part1:", score)

  columns := make([]int, len(lines[0]))
  for line in lines[:len(lines)-1] {
    for c, i in line {
      if c != ' ' {
        columns[i] *= 10
        columns[i] += int(c) - 48
      }
    }
  }

  i = 0
  for _, i in numbers {
    numbers[i] = 0
    if operations[i] == Operation.MULT {
      numbers[i] = 1
    }
  }
  for n in columns {
    if n == 0 {
      i+=1
    } else if operations[i] == Operation.PLUS {
      numbers[i] += n
    } else {
      numbers[i] *= n
    }
  }

  score = math.sum(numbers)
  fmt.println("part2:", score)
}
