extends Resource

class_name SimpleTemporalNetwork

var nodes: Array[int] = []
var constraints: Array[TemporalConstraint] = []
var stn_matrix: Array = []
var num_nodes: int = 0
var node_intervals: Array[Vector2i] = []


func get_node_index(node_interval: Vector2i) -> int:
	return node_intervals.find(node_interval)


func add_temporal_constraint(constraint: TemporalConstraint) -> bool:
	var interval: Vector2i = constraint.time_interval
	if interval not in node_intervals:
		node_intervals.append(interval)
		num_nodes += 1
		for i in range(num_nodes):
			stn_matrix.append(Array().resize(num_nodes))

	var node_left_right = get_node_index(interval)
	var left = node_left_right.x
	var right = node_left_right.y
	if left == -1 or right == -1:
		return false

	var distance = constraint.duration

	if stn_matrix[left][right] <= distance:
		print("Constraint has already been propagated")
		return false

	stn_matrix[left][right] = distance
	stn_matrix[right][left] = -distance

	if constraint.qualifier in [TemporalConstraint.TemporalQualifier.AT_START, TemporalConstraint.TemporalQualifier.AT_END, TemporalConstraint.TemporalQualifier.OVERALL]:
		propagate_constraints()

	constraints.append(constraint)
	return true


func get_temporal_constraint_by_name(resource: PlanResource, constraint_name: String) -> TemporalConstraint:
	for constraint in resource.simple_temporal_network.constraints:
		if constraint.resource_name == constraint_name:
			return constraint
	return null


func propagate_constraints() -> bool:
	var updated = false
	for constraint in constraints:
		var node_vertex = get_node_index(constraint.time_interval)
		var left = node_vertex.x
		var right = node_vertex.y
		var distance = constraint.duration

		if stn_matrix[left][right] <= distance:
			continue

		stn_matrix[left][right] = distance
		stn_matrix[right][left] = -distance

		if constraint.temporal_qualifier in [TemporalConstraint.TemporalQualifier.AT_START, TemporalConstraint.TemporalQualifier.AT_END, TemporalConstraint.TemporalQualifier.OVERALL]:
			for j in range(num_nodes):
				var update_distance = min(stn_matrix[j][right], stn_matrix[j][left] + distance)
				stn_matrix[j][right] = update_distance
				stn_matrix[right][j] = -update_distance

				update_distance = min(stn_matrix[j][left], stn_matrix[j][right] - distance)
				stn_matrix[j][left] = update_distance
				stn_matrix[left][j] = -update_distance
			updated = true

	return updated


func is_consistent() -> bool:
	for i in range(constraints.size()):
		for j in range(i+1, constraints.size()):
			var c1 = constraints[i]
			var c2 = constraints[j]
			if c1.time_interval.x < c2.time_interval.y and c2.time_interval.x < c1.time_interval.y:
				if c1.time_interval.x < c2.time_interval.x:
					if c2.time_interval.x + c2.duration <= c1.time_interval.y:
						continue
				else:
					if c1.time_interval.x + c1.duration <= c2.time_interval.y:
						continue
				print("Inconsistent constraints: " + c1.to_string() + " and " + c2.to_string())
				return false
	return true


func update_state(state: Dictionary) -> void:
	for key in state:
		var value = state[key]
		if value is TemporalConstraint:
			var constraint = TemporalConstraint.new(value.time_interval.x, value.duration, value.temporal_qualifier, value.resource_name)
			constraints.append(constraint)
			propagate_constraints()
