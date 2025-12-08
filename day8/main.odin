package main

import "core:slice/heap"
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

forest_find :: proc(f: Forest, n: int) -> int {
  n := n

  for f[n].parent != n {
    f[n].parent = f[f[n].parent].parent
    n = f[n].parent
  }

  return n
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

greater_dist :: proc(i, j: Edge) -> bool { return i.square_dist >= j.square_dist }

part1 :: proc(points: []Vec3, limit: int) {
  f := create_forest(len(points))

  all_edges := make([dynamic]Edge, 0, len(points)*(len(points)-1)/2)
  for p1, i in points {
    for p2, j in points[i+1:] {
      append(&all_edges, Edge{a=i, b=j+i+1, square_dist=dist_squared(p1,p2)})
    }
  }
  edges := all_edges[:]
  heap.make(edges, greater_dist)

  for _ in 0..<limit {
    heap.pop(edges, greater_dist)
    e := edges[len(edges)-1]
    forest_union(f, e.a, e.b)

    edges = edges[:len(edges)-1]
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

  all_edges := make([dynamic]Edge, 0, len(points)*(len(points)-1)/2)
  for p1, i in points {
    for p2, j in points[i+1:] {
      append(&all_edges, Edge{a=i, b=j+i+1, square_dist=dist_squared(p1,p2)})
    }
  }
  edges := all_edges[:]
  heap.make(edges, greater_dist)

  score := 0
  nb_edges := 0
  for len(edges) > 0 {
    heap.pop(edges, greater_dist)
    e := edges[len(edges)-1]
    done := forest_union(f, e.a, e.b)
    if done {
      nb_edges += 1
      if nb_edges >= len(points) - 1 {
        score = points[e.a].x * points[e.b].x
        break
      }
    }
    edges = edges[:len(edges)-1]
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
