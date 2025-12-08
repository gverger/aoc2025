package main

import "core:slice"
import "core:strconv"
import "core:fmt"
import "core:os"
import "core:strings"

Vec3::struct {
  x,y,z: int
}

dist_squared :: proc(v1, v2: Vec3) -> int {
  return (v1.x - v2.x) * (v1.x-v2.x) + (v1.y - v2.y) * (v1.y-v2.y) + (v1.z - v2.z) * (v1.z-v2.z)
}

part1 :: proc(points: []Vec3) {
  connex_comp := make([]int, len(points))
  for _, i in connex_comp {
    connex_comp[i] = i
  }

  all_min := -1
  score := 0
  for loops in 0..<1000 {
    minp1 := 0
    minp2 := 1
    min_dist := -1
    for p1, i in points {
      for p2, j in points[i+1:] {
        j := j + i + 1
        dist := dist_squared(p1, p2)
        if (min_dist == -1 || dist < min_dist) && all_min < dist {
          min_dist = dist
          minp1 = i
          minp2 = j
        }
      }
    }
    if min_dist == -1 {
      break
    }

    all_min = min_dist
    c1 := connex_comp[minp1]
    c2 := connex_comp[minp2]
    if c1 == c2 {
      continue
    }
    if c1 > c2 {
      c2, c1 = c1, c2
    }
    for c, i in connex_comp {
      if c == c2 {
        connex_comp[i] = c1
      }
    }
  }

  tallied := make(map[int]int)
  for c, i in connex_comp {
    n, ok := tallied[c]
    if !ok {
      n = 0
    }

    tallied[c] = n+1
  }

  values := make([dynamic]int, 0, len(tallied))
  for _, v in tallied {
    append(&values, v)
  }
  slice.reverse_sort(values[:])

  fmt.println(values)
  fmt.println("part1 =", values[0] * values[1] * values[2])
}

part2 :: proc(points: []Vec3) {
  connex_comp := make([]int, len(points))
  for _, i in connex_comp {
    connex_comp[i] = i
  }

  score := 0
  for loops in 0..<len(points)-1 {
    minp1 := 0
    minp2 := 1
    min_dist := -1
    for p1, i in points {
      for p2, j in points[i+1:] {
        j := j + i + 1
        if connex_comp[i] == connex_comp[j] {
          continue
        }
        dist := dist_squared(p1, p2)
        if min_dist == -1 || dist < min_dist {
          min_dist = dist
          minp1 = i
          minp2 = j
        }
      }
    }

    c1 := connex_comp[minp1]
    c2 := connex_comp[minp2]
    if c1 > c2 {
      c2, c1 = c1, c2
    }
    for c, i in connex_comp {
      if c == c2 {
        connex_comp[i] = c1
      }
    }
    score = points[minp1].x * points[minp2].x
  }

  fmt.println("part2 =", score)
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


  points := make([dynamic]Vec3, 0)
  for line in strings.split_lines(content) {
    if len(line) == 0 {
      continue
    }
    args := strings.split(line, ",")
    point := Vec3{
      x = strconv.atoi(args[0]),
      y = strconv.atoi(args[1]),
      z = strconv.atoi(args[2]),
    }

    fmt.println(point)
    append(&points, point)
  }

  part1(points[:])
  part2(points[:])
}
