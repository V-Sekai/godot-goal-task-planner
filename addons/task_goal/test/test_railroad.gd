# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# test_railroad.gd
# SPDX-License-Identifier: MIT

extends GutTest

var domain_name := "railroad_htn"
var the_domain := preload("../core/domain.gd").new("plan")
var planner := preload("../core/plan.gd").new()

func move_train_1(state: Dictionary) -> Dictionary:
	print("Moving train 1...")
	# Update state to reflect the movement of train 1
	return state

func move_train_2(state: Dictionary) -> Dictionary:
	print("Moving train 2...")
	# Update state to reflect the movement of train 2
	return state

func move_train_3(state: Dictionary) -> Dictionary:
	print("Moving train 3...")
	# Update state to reflect the movement of train 3
	return state

func move_train_4(state: Dictionary) -> Dictionary:
	print("Moving train 4...")
	# Update state to reflect the movement of train 4
	return state

func move_train_5(state: Dictionary) -> Dictionary:
	print("Moving train 5...")
	# Update state to reflect the movement of train 5
	return state

func move_train_6(state: Dictionary) -> Dictionary:
	print("Moving train 6...")
	# Update state to reflect the movement of train 6
	return state

func make_train_movement(state: Dictionary) -> Array:
	return [
		["move_train_1"],
		["move_train_2"],
		["move_train_3"],
		["move_train_4"],
		["move_train_5"],
		["move_train_6"]
	]

func test_railroad() -> void:
	var state0 := {
		"train_1": true,
		"train_2": true,
		"train_3": true,
		"train_4": true,
		"train_5": true,
		"train_6": true
	}

	planner._domains.push_back(the_domain)
	planner.current_domain = the_domain

	planner.declare_actions([
		Callable(self, "move_train_1"),
		Callable(self, "move_train_2"),
		Callable(self, "move_train_3"),
		Callable(self, "move_train_4"),
		Callable(self, "move_train_5"),
		Callable(self, "move_train_6")
	])
	planner.declare_task_methods(
		"make_train_movement",
		[
			Callable(self, "make_train_movement")
		]
	)

	# Initialize the state
	var state1 := state0.duplicate(true)

	# Set the expected result
	var expected := [
		["move_train_1"],
		["move_train_2"],
		["move_train_3"],
		["move_train_4"],
		["move_train_5"],
		["move_train_6"]
	]

	var plan := planner.find_plan(state1.duplicate(true), [["make_train_movement"]])

	# Check if the plan matches the expected result
	assert_eq(plan, expected)
