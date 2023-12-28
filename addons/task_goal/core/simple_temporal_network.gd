# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# simple_temporal_network.gd
# SPDX-License-Identifier: MIT

extends Resource

class_name SimpleTemporalNetwork

var constraints: Array[TemporalConstraint] = []
var num_nodes: int = 0
var node_intervals: Array[Vector2i] = []
var node_indices: Dictionary = {}

var node_index_cache = {}


func _to_string() -> String:
	if resource_name.is_empty():
		return "SimpleTemporalNetwork"
	return resource_name


func get_node_index(time_point: int) -> int:
	if time_point in node_index_cache:
		return node_index_cache[time_point]

	for interval in node_intervals:
		if interval.x <= time_point and time_point <= interval.y:
			var index = node_indices[interval]
			node_index_cache[time_point] = index
			return index

	print("Time point not found in any interval")
	return -1


var outgoing_edges: Dictionary = {}


func check_overlap(new_constraint: TemporalConstraint) -> bool:
	for constraint in constraints:
		if constraint.resource_name == new_constraint.resource_name:
			if (
				(constraint.time_interval.x < new_constraint.time_interval.y)
				and (new_constraint.time_interval.x < constraint.time_interval.y)
			):
				return true
	return false


func add_temporal_constraint(
	from_constraint: TemporalConstraint,
	to_constraint: TemporalConstraint = null,
	min_gap: float = 0,
	max_gap: float = 0
) -> bool:
	if not validate_constraints(from_constraint, to_constraint, min_gap, max_gap):
		print("Failed to validate constraints")
		return false

	if check_overlap(from_constraint) or (to_constraint != null and check_overlap(to_constraint)):
		return false

	add_constraints_to_list(from_constraint, to_constraint)

	var from_node: TemporalConstraint = process_constraint(from_constraint)
	if not from_node:
		print("Failed to process from_constraint")
		return false

	var to_node = null
	if to_constraint != null:
		to_node = process_constraint(to_constraint)
		if not to_node:
			print("Failed to process to_constraint")
			return false
		outgoing_edges[from_node] = outgoing_edges.get(from_node, []) + [to_node]

	update_constraints_list(from_constraint, from_node)
	if to_constraint != null:
		update_constraints_list(to_constraint, to_node)

	return true


func update_constraints_list(constraint: TemporalConstraint, node: TemporalConstraint) -> void:
	var index = constraints.find(constraint)
	if index != -1:
		constraints[index] = node
	else:
		constraints.append(node)


## This function validates the constraints and returns a boolean value.
func validate_constraints(from_constraint, to_constraint, min_gap: float, max_gap: float) -> bool:
	if (
		not from_constraint
		or not from_constraint.get("time_interval")
		or not from_constraint.get("duration")
	):
		print("Invalid from_constraint %s" % from_constraint)
		return false

	if (
		from_constraint["duration"]
		> (from_constraint["time_interval"][1] - from_constraint["time_interval"][0])
	):
		print("Duration is longer than time interval for from_constraint %s" % from_constraint)
		return false

	# If to_constraint is not null, check its properties
	if to_constraint:
		if not to_constraint.get("time_interval") or not to_constraint.get("duration"):
			print("Invalid to_constraint %s" % to_constraint)
			return false

		if (
			to_constraint["duration"]
			> (to_constraint["time_interval"][1] - to_constraint["time_interval"][0])
		):
			print("Duration is longer than time interval for to_constraint %s" % to_constraint)
			return false

	# Check if min_gap and max_gap are valid
	if (
		typeof(min_gap) != TYPE_FLOAT
		or min_gap < 0
		or (typeof(max_gap) != TYPE_FLOAT and max_gap != INF)
	):
		print("Invalid gap values")
		return false

	return true


## This function adds the constraints to the list.
func add_constraints_to_list(
	from_constraint: TemporalConstraint, to_constraint: TemporalConstraint
):
	if from_constraint:
		constraints.append(from_constraint)
	if to_constraint:
		constraints.append(to_constraint)


func process_constraint(constraint: TemporalConstraint) -> TemporalConstraint:
	var interval: Vector2i = constraint.time_interval
	if interval not in node_indices:
		node_indices[interval] = num_nodes
		node_intervals.append(interval)
		num_nodes += 1

	# Find the index of the original constraint in the constraints list
	var index = constraints.find(constraint)

	# Replace the original constraint with the processed constraint
	if index != -1:
		constraints[index] = constraint

	return constraint


func get_temporal_constraint_by_name(constraint_name: String) -> TemporalConstraint:
	for constraint in constraints:
		if constraint.resource_name == constraint_name:
			return constraint
	return null


func is_consistent() -> bool:
	var constraints_str: String
	for c in constraints:
		constraints_str += str(c) + ", "
	if not constraints.size():
		return true

	constraints.sort_custom(TemporalConstraint.sort_func)
	for i in range(constraints.size()):
		for j in range(i + 1, constraints.size()):
			if (
				constraints[i].time_interval.y > constraints[j].time_interval.x
				and constraints[i].time_interval.x < constraints[j].time_interval.y
			):
				print(
					(
						"Overlapping constraints: "
						+ str(constraints[i])
						+ " and "
						+ str(constraints[j])
					)
				)
				return false
		var decompositions = enumerate_decompositions(constraints[i])
		if decompositions.is_empty():
			print("No valid decompositions for constraint: " + str(constraints[i]))
			return false

	return true


func enumerate_decompositions(vertex: TemporalConstraint) -> Array[Array]:
	if not vertex is TemporalConstraint:
		print("Error: vertex must be an instance of TemporalConstraint.")
		return [[]]
	var leafs: Array[Array] = [[]]

	if is_leaf(vertex):
		leafs.append([vertex])
	else:
		if is_or(vertex):
			for child: TemporalConstraint in get_children(vertex):
				leafs += enumerate_decompositions(child)
		else:
			var op: Array[Array]
			for child: TemporalConstraint in get_children(vertex):
				op += enumerate_decompositions(child)
			leafs = cartesian_product(op)
	return leafs


func is_leaf(vertex: TemporalConstraint) -> bool:
	# A vertex is a leaf if it has no outgoing edges
	return not vertex in outgoing_edges or outgoing_edges[vertex].is_empty()


func is_or(vertex: TemporalConstraint) -> bool:
	# A vertex is an OR if it has more than one outgoing edge
	return vertex in outgoing_edges and outgoing_edges[vertex].size() > 1


func get_children(vertex: TemporalConstraint) -> Array[TemporalConstraint]:
	# The children of a vertex are the destinations of its outgoing edges
	if vertex in outgoing_edges:
		var children: Array[TemporalConstraint] = []
		for child_vertex in outgoing_edges[vertex]:
			children.append(child_vertex)
		return children
	else:
		return []


# Helper function to calculate the cartesian product of an array of arrays
func cartesian_product(arrays: Array[Array]) -> Array[Array]:
	var result: Array[Array] = [[]]

	for arr in arrays:
		var temp: Array[Array] = [[]]

		for res in result:
			for item in arr:
				temp.append(res + [item])

		result = temp

	return result


func update_state(state: Dictionary) -> void:
	for key in state:
		var value = state[key]
		if value is TemporalConstraint:
			var constraint = TemporalConstraint.new(
				value.time_interval.x,
				value.time_interval.y,
				value.duration,
				value.temporal_qualifier,
				value.resource_name
			)
			add_temporal_constraint(constraint)
