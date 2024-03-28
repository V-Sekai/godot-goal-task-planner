# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_magical_town_planner.gd
# SPDX-License-Identifier: MIT

extends GutTest

var block_data = []

var the_domain = preload("res://goal_task_tests/domains/college_town_domain.gd").new()

var planner = null


func create_room(
	state: Dictionary,
	mesh_name: String,
	pivot_offset: Vector3,
	dimensions: Vector3,
	mesh_type: String,
	adjacent_meshes: Array,
	_time: int
) -> Variant:
	# Create the room data structure
	var room = {
		"mesh": mesh_name,
		"adjacent_meshes": adjacent_meshes,
		"dimensions": dimensions,
		"pivot": pivot_offset,
		"type": mesh_type
	}

	# Add the room to the state dictionary
	state[mesh_name] = room

	# Mark the room as visited when it's created
	state["visited"][mesh_name] = true

	return state


func get_adjacent_mesh(mesh_name: String) -> Array:	
	for item in block_data:
		if item["MeshName"] == mesh_name:
			return item["AdjacentMeshes"]
	return []


func is_pivot_in_room(pivot: Vector3, room: Dictionary) -> bool:
	if not room.has("pivot") or not room.has("dimensions"):
		printerr("Error: Room dictionary does not have expected structure.")
		return false
	var room_position = room["pivot"]
	var dimensions = room["dimensions"]
	
	# Calculate the AABB of the room
	var min_point = room_position - dimensions / 2
	var max_point = room_position + dimensions / 2
	
	# Check if the pivot is inside the AABB
	return min_point.x <= pivot.x and pivot.x <= max_point.x and min_point.y <= pivot.y and pivot.y <= max_point.y and min_point.z <= pivot.z and pivot.z <= max_point.z


func adjust_pivot_if_needed(room: Dictionary, pivot: Vector3) -> Vector3:
	if is_pivot_in_room(pivot, room):
		pivot += room["dimensions"]
	return pivot


func m_create_room(state: Dictionary, mesh_name: String, _create: bool) -> Variant:
	var adjacent_meshes = get_adjacent_mesh(mesh_name)

	# Calculate the pivot based on the dimensions of the room
	var dimensions = Vector3()
	var mesh_type = ""
	for city_item in block_data:
		if city_item["MeshName"] == mesh_name:
			dimensions = city_item["Dimensions"]
			mesh_type = city_item["Type"]
			break
	var pivot = dimensions / 2.0
	var plan = []
	if state.has(mesh_name):
		pivot = adjust_pivot_if_needed(state[mesh_name], pivot)
		plan.append(["create_room", mesh_name, pivot, dimensions, mesh_type, adjacent_meshes, 0])
	else:
		plan.append(["create_room", mesh_name, dimensions / 2.0, dimensions, mesh_type, adjacent_meshes, 0])
	
	if adjacent_meshes.is_empty():
		return plan
	
	for adjacent_mesh_name in adjacent_meshes:
		if not state["visited"].has(adjacent_mesh_name):
			plan.append(Multigoal.new("visit_city_%s" % adjacent_mesh_name, {"visited": {adjacent_mesh_name: true}}))
		elif not state["visited"][adjacent_mesh_name]:
			plan.append(Multigoal.new("visit_city_%s" % adjacent_mesh_name, {"visited": {adjacent_mesh_name: true}}))
	return plan

func before_each():
	planner = preload("res://addons/task_goal/core/plan.gd").new()
	planner.verbose = 3
	var new_domain = the_domain.duplicate(true)
	planner.domains.push_back(new_domain)
	planner.current_domain = new_domain
	# new_domain.simple_temporal_networks = {"Mia": SimpleTemporalNetwork.new()}
	planner.declare_actions(
		[
			Callable(self, "create_room"),
			Callable(self, "place_furniture"),
		]
	)
	planner.declare_unigoal_methods("visited", [Callable(self, "m_create_room")])
	planner.declare_multigoal_methods([planner.m_split_multigoal])
	var data: RefCounted = load("res://goal_task_tests/game_problems/city_item.gd").new()
	block_data = data.game_blocks

func test_visit_all_locations_respecting_adjacency():
	planner.verbose = 0
	var state: Dictionary = {
		"visited": {}
	}

	for city_item in block_data:
		state["visited"][city_item["MeshName"]] = false
		
	# Sort city items deterministically by their mesh names
	block_data.sort_custom(func(a, b):
		return a["MeshName"] < b["MeshName"]
	)
	var goals = []
	for city_item in block_data:
		var goal_state_city = { "visited": { city_item["MeshName"]: true }}
		goals.append(Multigoal.new("visit_city_%s" % city_item["MeshName"], goal_state_city))
		break
	
	var result: Variant = planner.find_plan(state, goals)
	assert_eq(not result is bool, true)

	var printed_plans = {}

	for plan in result:
		if not printed_plans.has(plan[1]):
			gut.p("Plan %s" % [plan])
			printed_plans[plan[1]] = true


func test_bidirectional_adjacencies():
	var adjacency_map = {}  # A dictionary to hold each mesh and its adjacencies for quick lookup
	for item in block_data:
		adjacency_map[item["MeshName"]] = item["AdjacentMeshes"]
	
	for mesh_name in adjacency_map.keys():
		var adjacencies = adjacency_map[mesh_name]
		for adj in adjacencies:
			if adj in adjacency_map and mesh_name not in adjacency_map[adj]:
				gut.p("%s is not listed as adjacent in %s" % [mesh_name, adj])

func test_dimensions_is_vector3():
	for item in block_data:
		assert_eq(true, item.has("Dimensions") and item["Dimensions"] is Vector3)
