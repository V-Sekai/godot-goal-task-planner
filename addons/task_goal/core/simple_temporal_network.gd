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

func to_dictionary() -> Dictionary:
	return {"resource_name": resource_name, "constraints": constraints, "number_of_nodes": num_nodes, "node_intervals": node_intervals}


func get_node_index(time_point: int) -> int:
	if time_point in node_index_cache:
		return node_index_cache[time_point]
	else:
		for interval in node_intervals:
			if interval.x <= time_point and time_point <= interval.y:
				var index = node_indices[interval]
				node_index_cache[time_point] = index
				return index
		print("Time point not found in any interval")
		return -1
	

func add_temporal_constraint(from_constraint: TemporalConstraint, to_constraint: TemporalConstraint = null, min_gap: float = 0, max_gap: float = 0) -> bool:
	if not validate_constraints(from_constraint, to_constraint, min_gap, max_gap):
		print("Failed to validate constraints")
		return false

	add_constraints_to_list(from_constraint, to_constraint)

	var from_node: int = process_constraint(from_constraint)
	if from_node == -1:
		print("Failed to process from_constraint")
		return false

	if to_constraint != null:
		var to_node: int = process_constraint(to_constraint)
		if to_node == -1:
			print("Failed to process to_constraint")
			return false

	return true


## This function validates the constraints and returns a boolean value.
func validate_constraints(from_constraint, to_constraint, min_gap: float, max_gap: float) -> bool:
	# Check if from_constraint exists and has the necessary properties
	if not from_constraint:
		print("from_constraint is None")
		return false
		
	if not from_constraint.get("time_interval"):
		print("from_constraint does not have 'time_interval': %s" % from_constraint.to_dictionary())
		return false

	if not from_constraint.get("duration"):
		print("from_constraint does not have 'duration': %s" % from_constraint.to_dictionary())
		return false

	# Check if to_constraint exists and has the necessary properties
	if to_constraint:
		if not to_constraint.get("time_interval"):
			print("to_constraint does not have 'time_interval': %s" % from_constraint.to_dictionary())
			return false

		if not to_constraint.get("duration"):
			print("to_constraint does not have 'duration': %s" % from_constraint.to_dictionary())
			return false

	# Check if min_gap and max_gap are valid
	if typeof(min_gap) != TYPE_FLOAT or min_gap < 0 or typeof(max_gap) != TYPE_FLOAT or max_gap < 0:
		print("Invalid gap values")
		return false

	return true


## This function adds the constraints to the list.
func add_constraints_to_list(from_constraint: TemporalConstraint, to_constraint: TemporalConstraint):
	if from_constraint:
		constraints.append(from_constraint)
	if to_constraint:
		constraints.append(to_constraint)


## This function processes the constraint and returns the node index.
func process_constraint(constraint: TemporalConstraint) -> int:
	var interval: Vector2i = constraint.time_interval
	if interval not in node_indices:
		node_indices[interval] = num_nodes
		node_intervals.append(interval)
		num_nodes += 1
	return node_indices[interval]


func get_temporal_constraint_by_name(constraint_name: String) -> TemporalConstraint:
	for constraint in constraints:
		if constraint.resource_name == constraint_name:
			return constraint
	return null


func propagate_constraints() -> bool:
	var matrix_values = {}
	for i in range(num_nodes):
		matrix_values[i] = {}
		for j in range(num_nodes):
			matrix_values[i][j] = INF if i != j else 0

	for constraint in constraints:
		var from_node = get_node_index(constraint.time_interval.x)  # Use start time as from_node
		var to_node = get_node_index(constraint.time_interval.y)  # Use end time as to_node
		var weight = constraint.duration
		if from_node in matrix_values and to_node in matrix_values[from_node]:
			matrix_values[from_node][to_node] = min(matrix_values[from_node][to_node], weight)

	for k in range(num_nodes):
		for i in range(num_nodes):
			for j in range(num_nodes):
				if matrix_values[i][k] != INF and matrix_values[k][j] != INF:
					matrix_values[i][j] = min(matrix_values[i][j], matrix_values[i][k] + matrix_values[k][j])

	for i in range(num_nodes):
		if i in matrix_values[i] and matrix_values[i][i] < 0:
			print("Negative diagonal value at index %s" % i)
			return false

	return true
	

func is_consistent() -> bool:
	if not constraints.size():
		return true

	var skip = false
	for i in range(constraints.size()):
		if skip:
			skip = false
			continue
		for j in range(i + 1, constraints.size()):
			var c1 := constraints[i]
			if c1 == null:
				return false
			var c2 := constraints[j]
			if c2 == null:
				return false
			if c1.time_interval.x < c2.time_interval.y and c2.time_interval.x < c1.time_interval.y:
				if c1.time_interval.x < c2.time_interval.x:
					if c2.time_interval.x + c2.duration <= c1.time_interval.y:
						skip = true
						break
				else:
					if c1.time_interval.x + c1.duration <= c2.time_interval.y:
						skip = true
						break
				print("Inconsistent constraints: " + str(c1.to_dictionary()) + " and " + str(c2.to_dictionary()))
				return false
	return true


func update_state(state: Dictionary) -> void:
	for key in state:
		var value = state[key]
		if value is TemporalConstraint:
			var constraint = TemporalConstraint.new(value.time_interval.x, value.time_interval.y, value.duration, value.temporal_qualifier, value.resource_name)
			add_temporal_constraint(constraint)


func is_consistent_with(constraint: TemporalConstraint) -> bool:
	if not constraint is TemporalConstraint:
		print("Constraint is not a TemporalConstraint instance")
		return false

	var temp_stn = self.duplicate()
	return temp_stn.add_temporal_constraint(constraint) and temp_stn.is_consistent()
