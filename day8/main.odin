package main

import "core:slice"
import "core:strconv"
import "core:fmt"
import "core:os"
import "core:strings"

Node :: struct {
  parent: int,
  size: int,
}

Forest :: []Node

create_forest :: proc(nb_sets: int) -> Forest {
  f := make(Forest, nb_sets)
  for i in 0..<nb_sets {
    f[i].parent = i
    f[i].size = 1
  }
  return f
}

forest_find :: proc(forest: Forest, n: int) -> int {
  root := n
  f := forest

  for f[root].parent != root {
    root = f[root].parent
  }

  n := n
  for f[n].parent != root {
    parent := f[n].parent
    f[n].parent = root
    n = parent
  }

  return root
}

// return true if union has been performed, i.e. x and y where not in the same set
forest_union :: proc(forest: Forest, x, y: int) -> bool {
  x := forest_find(forest, x)
  y := forest_find(forest, y)

  if x == y {
    return false
  }

  if forest[x].size < forest[y].size {
    x, y = y, x
  }

  forest[y].parent = x
  forest[x].size += forest[y].size

  return true
}

Vec3::struct {
  x,y,z: int
}

dist_squared :: proc(v1, v2: Vec3) -> int {
  return (v1.x - v2.x) * (v1.x-v2.x) + (v1.y - v2.y) * (v1.y-v2.y) + (v1.z - v2.z) * (v1.z-v2.z)
}

Edge :: struct {
  a, b: int,
  square_dist: int,
}

part1 :: proc(points: []Vec3, limit: int) {
  f := create_forest(len(points))

  edges := make([dynamic]Edge, 0)
  for p1, i in points {
    for p2, j in points[i+1:] {
      append(&edges, Edge{a=i, b=j+i+1, square_dist=dist_squared(p1,p2)})
    }
  }

  slice.sort_by(edges[:], proc(i, j: Edge) -> bool { return i.square_dist <= j.square_dist })

  for i in 0..<limit {
    if i >= len(edges) {
      break
    }
    e := edges[i]
    forest_union(f, e.a, e.b)
  }

  values := make([dynamic]int, 0, len(f))
  for n,i in f {
    if forest_find(f, i) == i {
      append(&values, n.size)
    }
  }
  if len(values) < 3 {
    fmt.println("less that 3 connected components, here is the sizes of each:", values)
    return
  }

  slice.reverse_sort(values[:])

  fmt.println("part1 =", values[0] * values[1] * values[2])
}

part2 :: proc(points: []Vec3) {
  f := create_forest(len(points))

  edges := make([dynamic]Edge, 0)
  for p1, i in points {
    for p2, j in points[i+1:] {
      append(&edges, Edge{a=i, b=j+i+1, square_dist=dist_squared(p1,p2)})
    }
  }

  slice.sort_by(edges[:], proc(i, j: Edge) -> bool { return i.square_dist <= j.square_dist })

  score := 0
  for e in edges {
    done := forest_union(f, e.a, e.b)
    if done {
      score = points[e.a].x * points[e.b].x
    }
  }

  fmt.println("part2 =", score)
}

main :: proc() {
  if len(os.args) < 3 {
    fmt.println("Missing argument: ex: ./day8 input.txt 1000")
    return
  }

  data, ok := os.read_entire_file_from_filename(os.args[1])

  limit := strconv.atoi(os.args[2])

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

    append(&points, point)
  }

  part1(points[:], limit)
  part2(points[:])
}
