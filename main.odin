package aoc2025

import "core:fmt"
import "core:time"
import "core:log"
import "core:strconv"
import vmem "core:mem/virtual"
import os "core:os/os2"

main :: proc() {
    context.logger = log.create_console_logger()
    problems := problems
    if len(os.args) > 1 {
        for arg in os.args {
            day, ok := strconv.parse_int(arg)
            if ok {
                if day < len(problems) + 1 do run(problems[len(problems)-day], day)
                else do log.errorf("Day %v is not implemented", day)
            }
        }
    } else {
        #reverse for problem, i in problems do run(problem, len(problems) - i)
    }
}

run :: proc(p: Problem, day: int) {
    arena: vmem.Arena
    arena_err := vmem.arena_init_growing(&arena)
    ensure(arena_err == nil)
    arena_alloc := vmem.arena_allocator(&arena)
    context.allocator = arena_alloc
    defer vmem.arena_destroy(&arena)
    
    input_path := fmt.aprintf("inputs/day%v%v.txt", day, ODIN_DEBUG ? "ex" : "")
    data, err := os.read_entire_file_from_path(input_path, context.allocator)
    if err != nil {
        fmt.printfln("Failed to read %v data for day %v", ODIN_DEBUG ? "example" : "input", day)
        return
    }
    input := string(data)
    fmt.println("Day", day)
    run_part(p, 1, input)
    run_part(p, 2, input)
    fmt.println()
}

run_part :: proc(p:  Problem, part: int, input: string) {
    fn: proc(string) -> int
    ensure(part == 1 || part == 2)
    switch part {
        case 1: fn = p.part1
        case 2: fn = p.part2
    }

    fmt.print("    Part", part)
    if fn == nil {
        fmt.println(": Not implemented")
        return
    } else if ODIN_DEBUG {
        fmt.println()
    }
    now := time.now()
    result := fn(input)
    time := time.since(now)
    fmt.println("\n        - Answer:", result)
    fmt.println("        - Time:", time)
}