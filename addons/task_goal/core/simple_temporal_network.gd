# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# simple_temporal_network.gd
# SPDX-License-Identifier: MIT

extends Resource

class_name SimpleTemporalNetwork

var constraints: Array[TemporalConstraint] = []
var stn_matrix: Array[Array] = []
var num_nodes: int = 0
var node_intervals: Array[Vector2i] = []
var node_indices: Dictionary = {}

var row_indices = []
var col_indices = []
var values = []


func to_dictionary() -> Dictionary:
	return {"resource_name": resource_name, "constraints": constraints, "matrix": stn_matrix, "number_of_nodes": num_nodes, "node_intervals": node_intervals}


func get_node_index(node_interval: Vector2i) -> int:
	return node_intervals.find(node_interval)


func _init_matrix(num_nodes):
	row_indices.clear()
	row_indices.resize(num_nodes)
	col_indices.clear()
	col_indices.resize(num_nodes)
	values.clear()
	values.resize(num_nodes)
	for i in range(num_nodes):
		row_indices[i] = 0
		col_indices[i] = 0
		values[i] = INF


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

		update_matrix(from_node, to_node, from_constraint.duration)
	else:
		if not update_matrix_single(from_node):
			print("Failed to update matrix for single from_node")
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
		_init_matrix(num_nodes)  # Pass num_nodes as an argument here
	return node_indices[interval]


func get_value_from_matrix(i: int, j: int) -> float:
	for entry in stn_matrix:
		if entry[0] == i and entry[1] == j:
			return entry[2]
	return INF


# Update the COO matrix by appending new entries instead of modifying existing ones
func update_matrix(i: int, j: int, value: float) -> void:
	for idx in range(stn_matrix.size()):
		if stn_matrix[idx][0] == i and stn_matrix[idx][1] == j:
			stn_matrix[idx][2] = value
			return
	stn_matrix.append([i, j, value])


## This function resets the matrix for two nodes.
func reset_matrix(from_node: int, to_node: int):
	if not stn_matrix:
		return

	# Check if indices are valid.
	if from_node < 0 or from_node + 1 >= stn_matrix.size() or to_node < 0 or to_node + 1 >= stn_matrix.size():
		print("Error: Index out of range.")
		return

	stn_matrix[from_node][from_node + 1] = INF
	stn_matrix[from_node + 1][from_node] = -INF
	stn_matrix[to_node][to_node + 1] = INF
	stn_matrix[to_node + 1][to_node] = -INF


## This function updates the matrix for a single node and returns a boolean value.
func update_matrix_single(from_node: int) -> bool:
	if not stn_matrix:
		return true
	if from_node + 1 >= stn_matrix.size():
		return false

	if typeof(stn_matrix[from_node + 1]) != TYPE_ARRAY:
		stn_matrix[from_node + 1] = []

	return true


func get_temporal_constraint_by_name(constraint_name: String) -> TemporalConstraint:
	for constraint in constraints:
		if constraint.resource_name == constraint_name:
			return constraint
	return null


func propagate_constraints() -> bool:
	var matrix_values = []
	for i in range(num_nodes):
		matrix_values.append([])
		for j in range(num_nodes):
			matrix_values[i].append(get_value_from_matrix(i, j))

	for k in range(num_nodes):
		for i in range(num_nodes):
			var ik_value = matrix_values[i][k]
			if ik_value == INF:
				continue
			for j in range(num_nodes):
				var kj_value = matrix_values[k][j]
				if kj_value != INF:
					var ij_value = matrix_values[i][j]
					if ij_value == INF or ik_value + kj_value < ij_value:
						update_matrix(i, j, ik_value + kj_value)
						matrix_values[i][j] = ik_value + kj_value

	for i in range(num_nodes):
		if matrix_values[i][i] < 0:
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
