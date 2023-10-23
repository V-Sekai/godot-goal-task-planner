# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# simple_temporal_network.gd
# SPDX-License-Identifier: MIT

extends Resource

class_name SimpleTemporalNetwork

var constraints: Array[TemporalConstraint] = []
var stn_matrix: Array[Array] = []
var num_nodes: int = 0
var node_intervals: Array[Vector2i] = []
var node_indices: Dictionary = {} 

func to_dictionary()  -> Dictionary:
	return { "resource_name": resource_name, "constraints": constraints, "matrix": stn_matrix, "number_of_nodes": num_nodes, "node_intervals": node_intervals }


func get_node_index(node_interval: Vector2i) -> int:
	return node_intervals.find(node_interval)


func _init_matrix() -> void:
	stn_matrix.resize(num_nodes)
	for i in range(num_nodes):
		if stn_matrix[i] == null:
			stn_matrix[i] = []
		stn_matrix[i].resize(num_nodes)
		for j in range(num_nodes):
			if i == j:
				stn_matrix[i][j] = 0
			else:
				stn_matrix[i][j] = INF

func add_temporal_constraint(from_constraint: TemporalConstraint, to_constraint: TemporalConstraint = null, min_gap: float = 0, max_gap: float = 0) -> bool:
	if not from_constraint is TemporalConstraint:
		return false

	if to_constraint != null and not to_constraint is TemporalConstraint:
		return false

	if not min_gap is float or min_gap < 0:
		return false

	if not max_gap is float or max_gap < 0:
		return false
	
	constraints.append(from_constraint)
	constraints.append(to_constraint)

	var from_interval: Vector2i = from_constraint.time_interval
	if from_interval not in node_indices:
		node_indices[from_interval] = num_nodes
		node_intervals.append(from_interval)
		num_nodes += 1
		_init_matrix()
	var from_node: int = node_indices[from_interval]
	if from_node == -1:
		return false

	if to_constraint != null:
		var to_interval: Vector2i = to_constraint.time_interval
		if to_interval not in node_indices:
			node_indices[to_interval] = num_nodes
			node_intervals.append(to_interval)
			num_nodes += 1
			_init_matrix()
		var to_node: int = node_indices[to_interval]
		if to_node == -1:
			return false

		var distance: float = from_constraint.duration

		if from_node + 1 >= stn_matrix.size() or to_node + 1 >= stn_matrix.size():
			return false

		if typeof(stn_matrix[from_node + 1]) != TYPE_ARRAY:
			stn_matrix[from_node + 1] = []
		if typeof(stn_matrix[to_node + 1]) != TYPE_ARRAY:
			stn_matrix[to_node + 1] = []

		stn_matrix[from_node][from_node + 1] = max(distance, stn_matrix[from_node][from_node + 1])
		stn_matrix[from_node + 1][from_node] = -stn_matrix[from_node][from_node + 1]
		stn_matrix[to_node][to_node + 1] = min(-distance, stn_matrix[to_node][to_node + 1])
		stn_matrix[to_node + 1][to_node] = -stn_matrix[to_node][to_node + 1]

		if not propagate_constraints():
			stn_matrix[from_node][from_node + 1] = INF
			stn_matrix[from_node + 1][from_node] = -INF
			stn_matrix[to_node][to_node + 1] = INF
			stn_matrix[to_node + 1][to_node] = -INF
			return false
	else:
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
	for k in range(num_nodes):
		for i in range(num_nodes):
			for j in range(num_nodes):
				if i in stn_matrix and k in stn_matrix[i] and stn_matrix[i][k] != INF and k in stn_matrix and j in stn_matrix[k] and stn_matrix[k][j] != INF:
					if stn_matrix[i][j] == INF or stn_matrix[i][k] + stn_matrix[k][j] < stn_matrix[i][j]:
						stn_matrix[i][j] = stn_matrix[i][k] + stn_matrix[k][j]

	for i in range(num_nodes):
		if stn_matrix[i][i] != INF and stn_matrix[i][i] < 0:
			print("Negative diagonal value at index %s" % i)
			return false

	return true
	

func is_consistent() -> bool:
	var skip = false
	for i in range(constraints.size()):
		if skip:
			skip = false
			continue
		for j in range(i+1, constraints.size()):
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
	var temp_stn = SimpleTemporalNetwork.new()
	temp_stn.constraints = constraints.duplicate()
	temp_stn.stn_matrix = stn_matrix.duplicate()
	temp_stn.num_nodes = num_nodes
	temp_stn.node_intervals = node_intervals.duplicate()

	return temp_stn.add_temporal_constraint(constraint) and temp_stn.is_consistent()
