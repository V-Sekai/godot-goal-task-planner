# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_magical_town_planner.gd
# SPDX-License-Identifier: MIT

extends GutTest

var building_city_data = []

var the_domain = preload("res://goal_task_tests/domains/college_town_domain.gd").new()

var planner = null

var data = {}

func create_room(
	state: Dictionary,
	mesh_name: String,
	_pivot_dict: Dictionary,
	_footprint_dict: Dictionary,
	_time: int
) -> Variant:
	# Verify that the mesh exists within the data and check for adjacency
	var valid_mesh = false
	var adjacent_meshes = []
	var mesh_type = ""
	
	# Determine the type of mesh and collect valid adjacent meshes
	for city_item in building_city_data:
		if city_item["MeshName"] == mesh_name:
			valid_mesh = true
			adjacent_meshes = city_item["AdjacentMeshes"]
			mesh_type = "City"
			break

	if not valid_mesh:  # If not found in building items, check room items
		for room_item in data.room_item_data:
			if room_item["MeshName"] == mesh_name:
				valid_mesh = true
				adjacent_meshes = room_item["AdjacentMeshes"]
				mesh_type = "Room"
				break

	if not valid_mesh:
		return false

	# Create the room data structure
	var room = {
		"mesh": mesh_name,
		"adjacent_meshes": adjacent_meshes,
		#"pivot": Vector3i(pivot_dict["pivot"]),
		#"footprint": Vector3i(footprint_dict["footprint"]),
		"type": mesh_type
	}

	# Add the room to the state dictionary
	state[mesh_name] = room

	# Mark the room as visited when it's created
	state["visited"][mesh_name] = true

	return state

func get_adjacent_mesh(mesh_name: String) -> Array:	
	for item in building_city_data:
		if item["MeshName"] == mesh_name:
			return item["AdjacentMeshes"]
	return []

func m_create_room(state: Dictionary, mesh_name: String, _create: bool) -> Variant:
	var adjacent_meshes = get_adjacent_mesh(mesh_name)
	var pivot_dict = {}
	var footprint_dict = {}
	var plan = [["create_room", mesh_name, pivot_dict, footprint_dict, 0]]
	
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
	data = load("res://goal_task_tests/game_problems/city_item.gd").new()
	building_city_data = data.building_item_data + data.city_item_data

func test_visit_all_locations_respecting_adjacency():
	planner.verbose = 0
	var state: Dictionary = {
		"visited": {}
	}

	for city_item in building_city_data:
		state["visited"][city_item["MeshName"]] = false
		
	# Sort city items deterministically by their mesh names
	building_city_data.sort_custom(func(a, b):
		return a["MeshName"] < b["MeshName"]
	)
	var goals = []
	for city_item in building_city_data:
		var goal_state_city = { "visited": { city_item["MeshName"]: true }}
		goals.append(Multigoal.new("visit_city_%s" % city_item["MeshName"], goal_state_city))
		break
	
	var result: Variant = planner.find_plan(state, goals)
	assert_eq(not result is bool, true)

	var printed_plans = {}

	for plan in result:
		if not printed_plans.has(plan[1]):
			gut.p("Plan %s" % [plan[1]])
			printed_plans[plan[1]] = true

	assert_eq(building_city_data.size(), result.size())

func test_bidirectional_adjacencies():
	var adjacency_map = {}  # A dictionary to hold each mesh and its adjacencies for quick lookup
	for item in building_city_data:
		adjacency_map[item["MeshName"]] = item["AdjacentMeshes"]
	
	var errors = []  # A list to collect any discrepancies found
	for mesh_name in adjacency_map.keys():
		var adjacencies = adjacency_map[mesh_name]
		for adj in adjacencies:
			if adj in adjacency_map and mesh_name not in adjacency_map[adj]:
				gut.p("%s is not listed as adjacent in %s" % [mesh_name, adj])
				errors.append(mesh_name)

func test_footprint_is_vector3():
	for item in building_city_data:
		if item.has("Footprint") and item["Footprint"] is Vector3:
			gut.p("%s does not have a Vector3 footprint" % item["MeshName"])
			assert_eq(true, item["Footprint"] is Vector3)

func test_dimension_is_vector3():
	for item in data.room_item_data:
		if item.has("Dimensions") and item["Dimensions"] is Vector3:
			gut.p("%s does not have a Vector3 dimension" % item["MeshName"])
			assert_eq(true, item["Dimensions"] is Vector3)
