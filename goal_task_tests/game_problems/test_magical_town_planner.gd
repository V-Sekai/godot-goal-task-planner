# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_magical_town_planner.gd
# SPDX-License-Identifier: MIT

extends GutTest

var the_domain = preload("res://goal_task_tests/domains/college_town_domain.gd").new()

var planner = null


func before_each():
	planner = preload("res://addons/task_goal/core/plan.gd").new()
	planner.verbose = 0
	var new_domain = the_domain.duplicate(true)
	planner.domains.push_back(new_domain)
	planner.current_domain = new_domain

	planner.declare_actions(
		[
			Callable(planner.current_domain, "create_room"),
			Callable(planner.current_domain, "place_furniture"),
			Callable(planner.current_domain, "change_layout")
		]
	)
	planner.declare_task_methods(
		"design_room",
		[
			Callable(planner.current_domain, "create_room"),
			Callable(planner.current_domain, "place_furniture")
		]
	)
	planner.declare_task_methods(
		"redesign_apartment", [Callable(planner.current_domain, "change_layout")]
	)


func test_college_town_plan():
	planner.verbose = 3
	var town_state: Dictionary = {}  # TODO
	var result = planner.find_plan(
		town_state.duplicate(true),
		[
			["design_room", "bedroom1", "medium", "modern", "sleep"],
			["design_room", "bedroom2", "small", "vintage", "study"]
		]
	)

	assert_ne_deep(
		result,
		[
			[
				"create_room",
				"bedroom1",
				"medium",
				"modern",
				"sleep",
				{"pivot": [0, 0, 0], "footprint": [5, 5, 3]},
				10
			],
			[
				"place_furniture",
				"bed",
				"bedroom1",
				"north-wall",
				"facing-south",
				{"pivot": [2, 2, 0], "footprint": [3, 2, 1]},
				15
			],
			[
				"create_room",
				"bedroom2",
				"small",
				"vintage",
				"study",
				{"pivot": [6, 0, 0], "footprint": [4, 4, 3]},
				30
			],
			[
				"place_furniture",
				"desk",
				"bedroom2",
				"west-wall",
				"facing-east",
				{"pivot": [7, 2, 0], "footprint": [2, 1, 1]},
				35
			]
		]
	)
