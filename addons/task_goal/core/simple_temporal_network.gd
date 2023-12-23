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

var outgoing_edges: Dictionary = {}

func add_temporal_constraint(from_constraint: TemporalConstraint, to_constraint: TemporalConstraint = null, min_gap: float = 0, max_gap: float = 0) -> bool:
	if not validate_constraints(from_constraint, to_constraint, min_gap, max_gap):
		print("Failed to validate constraints")
		return false

	add_constraints_to_list(from_constraint, to_constraint)

	var from_node: TemporalConstraint = process_constraint(from_constraint)
	if not from_node:
		print("Failed to process from_constraint")
		return false
	var to_node: TemporalConstraint = null
	if to_constraint != null:
		to_node = process_constraint(to_constraint)
		if not to_node:
			print("Failed to process to_constraint")
			return false

		# Add the constraint to the list of outgoing edges for the from_node
		if from_node in outgoing_edges:
			outgoing_edges[from_node].append(to_node)
		else:
			outgoing_edges[from_node] = [to_node]

	# Update the constraints list with the processed nodes
	var index_from = constraints.find(from_constraint)
	if index_from != -1:
		constraints[index_from] = from_node
	else:
		constraints.append(from_node)

	if to_constraint != null:
		var index_to = constraints.find(to_constraint)
		if index_to != -1:
			constraints[index_to] = to_node
		else:
			constraints.append(to_node)

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

	if to_constraint != null and to_constraint.duration > (to_constraint.time_interval.y - to_constraint.time_interval.x):
		print("Duration is longer than time interval for to_constraint")
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
	if typeof(min_gap) != TYPE_FLOAT or min_gap < 0 or (typeof(max_gap) != TYPE_FLOAT and max_gap != float('inf')):
		print("Invalid gap values")
		return false

	return true


## This function adds the constraints to the list.
func add_constraints_to_list(from_constraint: TemporalConstraint, to_constraint: TemporalConstraint):
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
		constraints_str += str(c.to_dictionary()) + ", "
	if not constraints.size():
		return true

	constraints.sort_custom(TemporalConstraint.sort_func)
	for i in range(constraints.size()):
		for j in range(i+1, constraints.size()):
			if constraints[i].time_interval.y > constraints[j].time_interval.x and constraints[i].time_interval.x < constraints[j].time_interval.y:
				print("Overlapping constraints: " + str(constraints[i].to_dictionary()) + " and " + str(constraints[j].to_dictionary()))
				return false
		var decompositions = enumerate_decompositions(constraints[i])
		if decompositions.is_empty():
			print("No valid decompositions for constraint: " + str(constraints[i].to_dictionary()))
			return false
	
	return true
	
	
# Algorithm to return all the possible instantiations of a given path decomposition tree.
func enumerate_decompositions(vertex: TemporalConstraint) -> Array[Array]:
	#print("Enumerating decompositions for vertex: " + str(vertex.to_dictionary()))
	if not vertex is TemporalConstraint:
		print("Error: vertex must be an instance of TemporalConstraint.")
		return [[]]
	# Initialize empty leafs vector
	var leafs: Array[Array] = [[]]
	
	# If vertex is a leaf then
	if is_leaf(vertex):
		# Add vertex to leafs
		leafs.append([vertex])
	else:
		# If vertex is OR then
		if is_or(vertex):
			# For all children c of vertex do
			for child: TemporalConstraint in get_children(vertex):
				# Enumerate decompositions of child and add to leafs
				leafs += enumerate_decompositions(child)
		else:
			# Initialize empty op vector
			var op: Array[Array]
			
			# For all children c of vertex do
			for child: TemporalConstraint in get_children(vertex):
				# Enumerate decompositions of child and add to op
				op += enumerate_decompositions(child)
			
			# Leafs = cartesian product(op)
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
			var constraint = TemporalConstraint.new(value.time_interval.x, value.time_interval.y, value.duration, value.temporal_qualifier, value.resource_name)
			add_temporal_constraint(constraint)


func is_consistent_with(constraint: TemporalConstraint) -> bool:
	if not constraint is TemporalConstraint:
		print("Constraint is not a TemporalConstraint instance")
		return false

	var temp_stn = self.duplicate()
	return temp_stn.add_temporal_constraint(constraint) and temp_stn.is_consistent()
