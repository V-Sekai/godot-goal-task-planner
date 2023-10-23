# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# test_sandwich.gd
# SPDX-License-Identifier: MIT

extends GutTest

var domain_name := "sandwich_htn"
var the_domain := preload("../core/domain.gd").new("plan")
var planner := preload("../core/plan.gd").new()

func take_lettuce(state: Dictionary) -> Dictionary:
	print("Taking lettuce...")
	state["lettuce"] -= 1
	return state

func take_tomato(state: Dictionary) -> Dictionary:
	print("Taking tomato...")
	state["tomato"] -= 1
	return state


func take_cheese(state: Dictionary) -> Dictionary:
	print("Taking cheese...")
	state["cheese"] -= 1
	return state


func take_bread(state: Dictionary) -> Dictionary:
	print("Taking bread...")
	state["bread"] -= 1
	return state


func assemble_sandwich(state: Dictionary) -> Dictionary:
	print("Assembling sandwich...")
	if state["lettuce"] >= 1 and state["tomato"] >= 1 and state["cheese"] >= 1 and state["bread"] >= 2:
		state["sandwich"] += 1
		state["lettuce"] -= 1
		state["tomato"] -= 1
		state["cheese"] -= 1
		state["bread"] -= 2
	return state

func make_complete_sandwich(state: Dictionary) -> Array:
	return [
		["take_tomato"],
		["take_cheese"],
		["take_bread"],
		["take_lettuce"],
		["assemble_sandwich"]
	]

func test_sandwich() -> void:
	var state0 := {
		"bread": 2,
		"cheese": 1,
		"lettuce": 1,
		"tomato": 1,
		"sandwich": 0
	}

	planner._domains.push_back(the_domain)
	planner.current_domain = the_domain
	
	planner.declare_actions([
		Callable(self, "take_lettuce"),
		Callable(self, "take_tomato"),
		Callable(self, "assemble_sandwich"),
		Callable(self, "take_cheese"),
		Callable(self, "take_bread"),
	])
	planner.declare_task_methods(
		"make_sandwich",
		[
			Callable(self, "make_complete_sandwich"),
		]
	)

	# Initialize the state
	var state1 := state0.duplicate(true)

	# Set the expected result
	var expected := [
		["take_tomato"],
		["take_cheese"],
		["take_bread"],
		["take_lettuce"],
		["assemble_sandwich"],
	]

	# Find a plan to make a sandwich
	var plan := planner.find_plan(state1.duplicate(true), [["make_sandwich"]])
	

	# Check if the plan matches the expected result
	assert_eq(plan, expected)
