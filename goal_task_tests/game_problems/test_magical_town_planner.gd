# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_magical_town_planner.gd
# SPDX-License-Identifier: MIT

extends GutTest

var building_city_data = []

var the_domain = preload ("res://goal_task_tests/domains/college_town_domain.gd").new()

var planner = null

func add_node(state: Dictionary, node):
	if !state["graph"].has(node):
		state["graph"][node] = []

func add_edge(state: Dictionary, node1, node2, weight):
	add_node(state, node1)
	add_node(state, node2)
	# Ensure the weight is non-negative
	weight = max(0, weight)
	state["graph"][node1].append({"node": node2, "weight": weight})
	state["graph"][node2].append({"node": node1, "weight": weight})

func find_smallest(nodes, visited):
	var smallest = null
	for node in nodes:
		if smallest == null or nodes[node] < nodes[smallest]:
			if node not in visited:
				smallest = node
	return smallest

class PriorityQueue:
	var _data = []

	func push(item, priority):
		# Insert the item at the correct position to maintain sorted order.
		for i in range(_data.size()):
			if _data[i].priority > priority:
				_data.insert(i, {"item": item, "priority": priority})
				return
		# If the item has the lowest priority, append it at the end.
		_data.append({"item": item, "priority": priority})

	func pop():
		# Remove and return the item with the highest priority (lowest value).
		return _data.pop_front().item

	func is_empty():
		return _data.is_empty()

func mostly_minimal_spanning_tree(state: Dictionary, start):
	if state["graph"].is_empty():
		return {}

	var visited = []
	var distances = {}
	for node in state["graph"].keys():
		distances[node] = INF

	# Initialize the distance of the start node to 0
	distances[start] = 0

	# Initialize the priority queue with the start node
	var pq = PriorityQueue.new()
	pq.push(start, 0)

	while !pq.is_empty():
		var smallest = pq.pop()

		if smallest not in visited:
			visited.append(smallest)

			for neighbour in state["graph"][smallest]:
				var alt_distance = distances[smallest] + neighbour["weight"]
				if alt_distance < distances[neighbour["node"]]:
					distances[neighbour["node"]] = alt_distance
					pq.push(neighbour["node"], alt_distance)

	return distances

func create_room_with_mostly_minimal_spanning_tree(state: Dictionary, mesh_name: String, pivot_offset: Vector3, dimensions: Vector3, mesh_type: String, adjacent_meshes: Array, _time: int) -> Variant:
	var room = {
		"mesh": mesh_name,
		"adjacent_meshes": adjacent_meshes,
		"dimensions": dimensions,
		"pivot": pivot_offset,
		"type": mesh_type
	}
	
	state[mesh_name] = room
	state["visited"][mesh_name] = true

	update_mmst(state, mesh_name, adjacent_meshes)
	state["mmst"] = mostly_minimal_spanning_tree(state, mesh_name)
	return state

func get_adjacent_mesh(mesh_name: String) -> Array:
	for item in building_city_data:
		if item["MeshName"] == mesh_name:
			return item["AdjacentMeshes"]
	return []

func update_mmst(state: Dictionary, new_mesh: String, adjacent_meshes: Array):
	# Add the new mesh to the graph
	add_node(state, new_mesh)

	# Add edges between the new mesh and its adjacent meshes.
	for adj_mesh in adjacent_meshes:
		if state.has(adj_mesh):
			# The weight can be calculated as the distance between the two rooms.
			var weight = state[new_mesh]["pivot"].distance_to(state[adj_mesh]["pivot"])
			add_edge(state, new_mesh, adj_mesh, weight)

	# Recalculate the MMST starting from the new mesh.
	state["mmst"] = mostly_minimal_spanning_tree(state, new_mesh)

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

func m_create_room_with_create_room_with_mostly_minimal_spanning_tree(state: Dictionary, mesh_name: String, _create: bool) -> Variant:
	var adjacent_meshes = get_adjacent_mesh(mesh_name)

	# Calculate the pivot based on the dimensions of the room
	var dimensions = Vector3()
	var mesh_type = ""
	for city_item in building_city_data:
		if city_item["MeshName"] == mesh_name:
			dimensions = city_item["Dimensions"]
			mesh_type = city_item["Type"]
			break
	var pivot = dimensions / 2.0
	var plan = []
	if state.has(mesh_name):
		pivot = adjust_pivot_if_needed(state[mesh_name], pivot)
		plan.append(["create_room_with_mostly_minimal_spanning_tree", mesh_name, pivot, dimensions, mesh_type, adjacent_meshes, 0])
	else:
		plan.append(["create_room_with_mostly_minimal_spanning_tree", mesh_name, dimensions / 2.0, dimensions, mesh_type, adjacent_meshes, 0])

	if adjacent_meshes.is_empty():
		return plan

	for adjacent_mesh_name in adjacent_meshes:
		if not state["visited"].has(adjacent_mesh_name):
			plan.append(Multigoal.new("visit_city_%s" % adjacent_mesh_name, {"visited": {adjacent_mesh_name: true}}))
		elif not state["visited"][adjacent_mesh_name]:
			plan.append(Multigoal.new("visit_city_%s" % adjacent_mesh_name, {"visited": {adjacent_mesh_name: true}}))
	return plan

func before_each():
	planner = preload ("res://addons/task_goal/core/plan.gd").new()
	planner.verbose = 3
	var new_domain = the_domain.duplicate(true)
	planner.domains.push_back(new_domain)
	planner.current_domain = new_domain
	planner.declare_actions(
		[
			Callable(self, "create_room_with_mostly_minimal_spanning_tree"),
			Callable(self, "place_furniture"),
		]
	)
	planner.declare_unigoal_methods("visited", [Callable(self, "m_create_room_with_create_room_with_mostly_minimal_spanning_tree")])
	planner.declare_multigoal_methods([planner.m_split_multigoal])
	var data: RefCounted = load("res://goal_task_tests/game_problems/city_item.gd").new()
	building_city_data = data.building_item_data + data.city_item_data + data.room_item_data

func _mesh_name_compare(a, b):
	return a["MeshName"] < b["MeshName"]

func test_visit_all_locations_respecting_adjacency():
	planner.verbose = 0
	var state: Dictionary = {
		"visited": {},
		"mmst": {},
		"graph": {}
	}

	for city_item in building_city_data:
		state["visited"][city_item["MeshName"]] = false
		
	# Sort city items deterministically by their mesh names
	building_city_data.sort_custom(_mesh_name_compare)
	var goals = []
	for city_item in building_city_data:
		var goal_state_city = {"visited": {city_item["MeshName"]: true}}
		goals.append(Multigoal.new("visit_city_%s" % city_item["MeshName"], goal_state_city))
		break
	
	var result: Variant = planner.find_plan(state, goals)
	assert_eq(not result is bool, true)

	var printed_plans = {}

	for plan in result:
		gut.p("Plan %s" % [plan])

	var total_visited = 0
	for city in state["visited"]:
		if state["visited"][city]:
			total_visited += 1

	gut.p("Total visited: %s" % [total_visited])
	assert_eq(total_visited, len(building_city_data))
	
func test_dimensions_is_vector3():
	for item in building_city_data:
		assert_eq(true, item.has("Dimensions") and item["Dimensions"] is Vector3)

func test_empty_input():
	var state: Dictionary = {
		"graph": {},
		"visited": {}
	}
	var result = mostly_minimal_spanning_tree(state, "")
	assert_eq(result, {})

func test_single_node():
	var state: Dictionary = {
		"graph": {"A": []},
		"visited": {}
	}
	var result = mostly_minimal_spanning_tree(state, "A")
	assert_eq(result, {"A": 0})
	gut.p(result)

func test_disconnected_graph():
	var state: Dictionary = {
		"graph": {
			"A": [{"node": "B", "weight": 1}],
			"B": [{"node": "A", "weight": 1}],
			"C": []
		},
		"visited": {}
	}
	var result = mostly_minimal_spanning_tree(state, "A")
	assert_eq(result, {"A": 0, "B": 1, "C": INF})
	gut.p(result)

func test_negative_weights():
	var state: Dictionary = {
		"graph": {},
		"visited": {}
	}
	add_edge(state, "A", "B", -1)
	var result = mostly_minimal_spanning_tree(state, "A")
	assert_eq(result, {"A": 0, "B": 0})
	gut.p(result)

func test_complex_graph():
	var state: Dictionary = {
		"graph": {
			"A": [{"node": "B", "weight": 1}, {"node": "C", "weight": 2}],
			"B": [{"node": "A", "weight": 1}, {"node": "D", "weight": 3}],
			"C": [{"node": "A", "weight": 2}, {"node": "D", "weight": 1}],
			"D": [{"node": "B", "weight": 3}, {"node": "C", "weight": 1}]
		},
		"visited": {}
	}
	var result = mostly_minimal_spanning_tree(state, "A")
	assert_eq(result, {"A": 0, "B": 1, "C": 2, "D": 3})
	gut.p(result)

func test_cyclic_graph():
	var state: Dictionary = {
		"graph": {
			"A": [{"node": "B", "weight": 1}, {"node": "C", "weight": 2}],
			"B": [{"node": "A", "weight": 1}, {"node": "C", "weight": 3}],
			"C": [{"node": "A", "weight": 2}, {"node": "B", "weight": 3}]
		},
		"visited": {}
	}
	var result = mostly_minimal_spanning_tree(state, "A")
	assert_eq(result, {"A": 0, "B": 1, "C": 2})
	gut.p(result)

func print_ascii_graph(graph: Dictionary):
	var ascii_art = ""
	for node in graph.keys():
		ascii_art += node + ":\n"
		for edge in graph[node]:
			ascii_art += "--(" + str(edge["weight"]) + ")--" + edge["node"] + "\n"
		ascii_art += "\n"
	gut.p(ascii_art)

func test_college_campus_graph():
	var state: Dictionary = {
		"graph": {
			"Library": [{"node": "Cafeteria", "weight": 2}, {"node": "Classroom1", "weight": 1}],
			"Cafeteria": [{"node": "Library", "weight": 2}, {"node": "Gym", "weight": 3}],
			"Classroom1": [{"node": "Library", "weight": 1}, {"node": "Classroom2", "weight": 1}],
			"Classroom2": [{"node": "Classroom1", "weight": 1}, {"node": "Gym", "weight": 2}],
			"Gym": [{"node": "Cafeteria", "weight": 3}, {"node": "Classroom2", "weight": 2}]
		},
		"visited": {}
	}
	print_ascii_graph(state["graph"])
	var result = mostly_minimal_spanning_tree(state, "Library")
	assert_eq(result, {"Library": 0, "Cafeteria": 2, "Classroom1": 1, "Classroom2": 2, "Gym": 4})
	gut.p(result)
