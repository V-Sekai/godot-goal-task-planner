# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_magical_town_planner.gd
# SPDX-License-Identifier: MIT

extends GutTest

var the_domain = preload("res://goal_task_tests/domains/college_town_domain.gd").new()

var planner = null


func create_room(
	state: Dictionary,
	room_name: String,
	size: String,
	style: String,
	purpose: String,
	pivot_dict: Dictionary,
	footprint_dict: Dictionary,
	time: int
) -> Dictionary:
	var room = {
		"size": size,
		"style": style,
		"purpose": purpose,
	}
	var furniture = []
	var footprint = {"pivot": Vector3i(footprint_dict["pivot"]), "footprint": Vector3i(footprint_dict["footprint"])}

	if not state.has("rooms"):
		state["rooms"] = {}
	if not state.has("furniture"):
		state["furniture"] = {}

	state["rooms"][room_name] = "rooms_" + room_name
	state["rooms_" + room_name] = room
	state["furniture"][room_name] = "furniture_" + room_name
	state["furniture_" + room_name] = furniture
	state["footprints_" + room_name] = footprint
	state["pivots_" + room_name] = Vector3i(pivot_dict["pivot"])

	return state


func place_furniture(
	state,
	furniture: String,
	room_name: String,
	wall: String,
	direction: String,
	position: Dictionary
) -> Variant:
	var furniture_item = {
		"item": furniture,
		"wall": wall,
		"direction": direction,
		"position": position,
	}

	state["rooms"][room_name]["furniture"].append(furniture_item)

	return state


func task_design_room(
	state: Dictionary, room_name: String, size: String, style: String, purpose: String
) -> Array:
	return [
		[
			"create_room",
			room_name,
			size,
			style,
			purpose,
			Vector3i(0, 0, 0),
			Vector3i(5, 5, 3),
			10
		],
	]


func task_change_layout(state, new_layout: Dictionary) -> Variant:
	state["layout"] = new_layout

	return state


func before_each():
	planner = preload("res://addons/task_goal/core/plan.gd").new()
	planner.verbose = 3
	var new_domain = the_domain.duplicate(true)
	planner.domains.push_back(new_domain)
	planner.current_domain = new_domain
	new_domain.simple_temporal_networks = {"Mia": SimpleTemporalNetwork.new()}
	planner.declare_actions(
		[
			Callable(self, "create_room"),
			Callable(self, "place_furniture"),
			Callable(self, "change_layout")
		]
	)
	planner.declare_task_methods("design_room", [Callable(self, "task_design_room")])
	planner.declare_task_methods(
		"redesign_apartment", [Callable(planner.current_domain, "task_change_layout")]
	)


func test_college_town_plan():
	planner.verbose = 3
	var town_state: Dictionary = {}

	planner.current_domain.types = {
		"rooms": ["rooms_bedroom1", "rooms_bedroom2"],
		"furniture": ["furniture_bedroom1", "furniture_bedroom2"],
		"footprints": ["footprints_bedroom1", "footprints_bedroom2"],
		"pivots": ["pivots_bedroom1", "pivots_bedroom2"],
	}

	var result = (
		planner
		. find_plan(town_state,
			[
				["design_room", "bedroom1", "medium", "modern", "sleep"],
				#["design_room", "bedroom2", "small", "vintage", "study"]
			]
		)
	)

	assert_eq_deep(
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
			#[
			#"create_room",
			#"bedroom2",
			#"small",
			#"vintage",
			#"study",
			#{"pivot": [6, 0, 0], "footprint": [4, 4, 3]},
			#30
			#],
			#[
			#"place_furniture",
			#"desk",
			#"bedroom2",
			#"west-wall",
			#"facing-east",
			#{"pivot": [7, 2, 0], "footprint": [2, 1, 1]},
			#35
			#]
		]
	)
