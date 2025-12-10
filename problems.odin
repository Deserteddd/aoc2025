package aoc2025

import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:math"
import "core:slice"

Problem :: struct {
    part1: proc(s: string) -> int,
    part2: proc(s: string) -> int
}

problems :: [?]Problem {
    // Day 5
    {
        part1 = proc(input: string) -> (result: int) {
            split := strings.split(input, "\r\n\r\n")
            id_in_range :: proc(id: int, ranges: string) -> bool {
                ranges_ptr := ranges
                for range in strings.split_lines_iterator(&ranges_ptr) {
                    dash := strings.index_rune(range, '-')
                    lower, lower_ok := strconv.parse_int(range[0:dash]); assert(lower_ok) 
                    upper, upper_ok := strconv.parse_int(range[dash+1:]); assert(upper_ok)
                    if id >= lower && id <= upper {
                        return true
                    }

                }
                return false
            }
            id_ptr := split[1]
            for i in strings.split_lines_iterator(&id_ptr) {
                id, ok := strconv.parse_int(i); assert(ok)
                if id_in_range(id, split[0]) do result += 1
            }

            return
        },
        part2 = proc(input: string) -> (result: int) {
            input_ptr := input
            ranges: [dynamic][2]int
            for range in strings.split_lines_iterator(&input_ptr) {
                if range == "" do break
                dash := strings.index_rune(range, '-')
                lower, lower_ok := strconv.parse_int(range[0:dash]); assert(lower_ok) 
                upper, upper_ok := strconv.parse_int(range[dash+1:]); assert(upper_ok)
                append(&ranges, [2]int{lower, upper})
            }
            merge_ranges :: proc(ranges: ^[dynamic][2]int) {
                slice.sort_by(ranges[:], proc(i, j: [2]int) -> bool {
                    return i.x < j.x
                })
                for i in 0..<len(ranges)-1 {
                    if ranges[i].y >= ranges[i+1].x-1 {
                        ranges[i].y = ranges[i+1].x
                        if ranges[i].y < ranges[i+1].y do ranges[i].y = ranges[i+1].y
                        ordered_remove(ranges, i+1)
                        merge_ranges(ranges)
                        break
                    }
                }
            }
            merge_ranges(&ranges)
            for i, index in ranges {
                fmt.println(index,"/",len(ranges))
                for j in i.x..=i.y do result += 1
            }
            return result
        }
    },
    // Day 4
    {
        part1 = proc(input: string) -> (result: int) {
            w, h: int
            for c, i in input {
                if c == '\n' {
                    w = i
                    h = len(input) / w
                    break
                }
            }
            for y in 0..<h {
                for x in 0..<w-1 {
                    elem := input[y*(w+1) + x]
                    adjacent_indices := [8]int {
                        y*(w+1) + x + 1,
                        y*(w+1) + x - 1,
                        (y-1)*(w+1) + x,
                        (y+1)*(w+1) + x,
                        (y+1)*(w+1) + x+1,
                        (y+1)*(w+1) + x-1,
                        (y-1)*(w+1) + x+1,
                        (y-1)*(w+1) + x-1
                    }
                    adjancies: int
                    if elem == '@' {
                        for ai in adjacent_indices {
                            if ai >= 0 && ai < len(input) {
                                if input[ai] == '@' do adjancies += 1
                            }
                        }
                        if adjancies < 4 do result += 1
                    }
                }
            }
            return
        },
        part2 = proc(input: string) -> (result: int) {
            part1_recursive :: proc(input: string) -> int {
                w, h: int
                for c, i in input {
                    if c == '\n' {
                        w = i
                        h = len(input) / w
                        break
                    }
                }
                input_builder_buf := make([]byte, len(input))
                index: int
                removed: int
                for y in 0..<h {
                    for x in 0..<w-1 {
                        if input[y*(w+1) + x] == '@' {
                            adjacent_indices := [8]int {
                                y*(w+1) + x + 1,
                                y*(w+1) + x - 1,
                                (y-1)*(w+1) + x,
                                (y+1)*(w+1) + x,
                                (y+1)*(w+1) + x+1,
                                (y+1)*(w+1) + x-1,
                                (y-1)*(w+1) + x+1,
                                (y-1)*(w+1) + x-1
                            }
                            adjancies: int
                            for ai in adjacent_indices {
                                if ai >= 0 && ai < len(input) {
                                    if input[ai] == '@' do adjancies += 1
                                }
                            }
                            if adjancies < 4 {
                                input_builder_buf[index] = '.'
                                removed += 1
                            } else {
                                input_builder_buf[index] = '@'
                            }
                        } else {
                            input_builder_buf[index] = '.'
                        } 
                        index += 1
                    }
                    if index < len(input) {
                        input_builder_buf[index] = '\r'
                        input_builder_buf[index + 1] = '\n'
                        index += 2
                    }
                }
                updated_grid := string(input_builder_buf)
                if removed > 0 do return removed + part1_recursive(updated_grid)
                else do return removed
            }
            return part1_recursive(input)
        }
    },
    // Day 3
    {
        part1 = proc(input: string) -> (result: int) {
            input_ptr := input
            find_max_joltage :: proc(bank: string) -> (max_joltage: int, index: int) {
                for battery, i in bank {
                    joltage := int(battery) - 48
                    if joltage > max_joltage {
                        max_joltage = joltage
                        index = i
                    }
                }
                return
            }
            for bank in strings.split_lines_iterator(&input_ptr) {
                max_joltage, max_joltage_index := find_max_joltage(bank)
                second_joltage: int
                if max_joltage_index == len(bank)-1 {
                    second_joltage = max_joltage
                    max_joltage, max_joltage_index = find_max_joltage(bank[0:len(bank)-1])
                } else {
                    second_joltage, _ = find_max_joltage(bank[max_joltage_index+1:])
                }
                result += max_joltage*10+second_joltage
            }
            return 
        },
        part2 = proc(input: string) -> (result: int) {
            find_max_joltage :: proc(bank: string, joltages: ^[dynamic]int) {
                if len(joltages) == 12 do return
                max_joltage, index: int
                slots_to_fill := 11 - len(joltages)
                space := len(bank) - slots_to_fill
                if len(joltages) == 11 do space = len(bank)
                for i in 0..<space{
                    joltage := int(bank[i]) - 48
                    if joltage > max_joltage {
                        max_joltage = joltage
                        index = i
                    }
                }
                append(joltages, max_joltage)
                remainder := bank[index+1:]
                find_max_joltage(remainder, joltages)
                return
            }
            input_ptr := input
            for bank in strings.split_lines_iterator(&input_ptr) {
                joltages: [dynamic]int
                find_max_joltage(bank, &joltages)
                joltage_builder: strings.Builder
                strings.builder_init(&joltage_builder)
                for joltage in joltages do strings.write_int(&joltage_builder, joltage)
                joltage_str := strings.to_string(joltage_builder)
                assert(len(joltage_str) == 12)
                joltage, ok := strconv.parse_int(joltage_str); assert(ok)
                result += joltage
            }
            return
        }   
    },
    // Day 2
    {
        part1 = proc(input: string) -> (result: int) {
            valid_id :: proc(id: int) -> bool {
                i, id_len: int = 1, 0
                for {
                    if id/i == 0 do break
                    i *= 10
                    id_len += 1
                }
                if id_len%2 != 0 do return true
                half_len := 1

                for _ in 0..<id_len/2 do half_len *= 10

                start := id / half_len
                end := id % half_len
                return start != end
            }

            input_ptr := input
            for range in strings.split_iterator(&input_ptr, ",") {
                sep := strings.index_rune(range, '-')
                lower, lower_ok := strconv.parse_int(range[0:sep]); assert(lower_ok)
                upper, upper_ok := strconv.parse_int(range[sep+1:]); assert(upper_ok)
                for id in lower..=upper do result += int(!valid_id(id))*id
            }
            return
        },

        part2 = proc(input: string) -> (result: int) {
            valid_id :: proc(id: int) -> bool {
                // Very slow due to aprint memory allocation
                id_str := fmt.aprint(id)
                for i in 0..<len(id_str) {
                    substr := id_str[0:i]
                    if strings.count(id_str, substr)*len(substr) == len(id_str) do return false
                }
                return true
            }
            input_ptr := input
            for range in strings.split_iterator(&input_ptr, ",") {
                sep := strings.index(range, "-")
                lower, lower_ok := strconv.parse_int(range[0:sep]); assert(lower_ok)
                upper, upper_ok := strconv.parse_int(range[sep+1:]); assert(upper_ok)
                for id in lower..=upper do result += int(!valid_id(id))*id
            }
            return
        }
    },
    // Day 1
    {
        part1 = proc(input: string) -> (result: int) {
            input_ptr := input
            position := 50
            for s in strings.split_lines_iterator(&input_ptr) {
                n, ok := strconv.parse_int(s[1:]); assert(ok)
                _, position = math.floor_divmod(s[0] == 'L' ? position - n : position + n, 100)
                result += int(position == 0)
            }
            return
        },
        part2 = proc(input: string) -> (result: int) {
            input_ptr := input
            position := 50
            for s in strings.split_lines_iterator(&input_ptr) {
                n, ok := strconv.parse_int(s[1:]); assert(ok)
                step := 1
                if s[0] == 'L' do step = -1
                for _ in 0..<n {
                    position += step
                    if position == -1 do position = 99
                    else if position == 100 do position = 0
                    result += int(position == 0)
                }
            }
            return
        }
    }
}