package aoc2025

import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:math"

Problem :: struct {
    part1: proc(s: string) -> int,
    part2: proc(s: string) -> int
}

problems :: [?]Problem {
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
                sep := strings.index(range, "-")
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