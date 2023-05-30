extends Resource

class_name SimpleTemporalNetwork

var constraints: Array = []
var stn_matrix: Array = []
var num_nodes: int = 0
var node_intervals: Array = []


func get_node_index(node_interval: Vector2i) -> int:
	return node_intervals.find(node_interval)


func add_temporal_constraint(constraint: TemporalConstraint) -> bool:
	var interval: Vector2i = constraint.time_interval
	if interval not in node_intervals:
		node_intervals.append(interval)
		num_nodes += 1
		stn_matrix.resize(num_nodes)
		for i in range(num_nodes):
			if stn_matrix[i] == null:
				stn_matrix[i] = []
			stn_matrix[i].resize(num_nodes)

	var node: int = get_node_index(interval)
	if node == -1 or node + 1 >= num_nodes:
		return false

	var distance = constraint.duration

	if stn_matrix[node][node + 1] <= distance:
		print("Constraint has already been propagated")
		return true

	stn_matrix[node][node + 1] = distance
	stn_matrix[node + 1][node] = -distance

	propagate_constraints()
	constraints.append(constraint)
	return true
	

func get_temporal_constraint_by_name(constraint_name: String) -> TemporalConstraint:
	for constraint in constraints:
		if constraint.resource_name == constraint_name:
			return constraint
	return null


func propagate_constraints() -> bool:
	var updated = false
	for constraint in constraints:
		var node = get_node_index(constraint.time_interval)
		if node == -1:
			continue

		var distance = constraint.duration

		if stn_matrix[node][node + 1] <= distance:
			continue

		stn_matrix[node][node + 1] = distance
		stn_matrix[node + 1][node] = -distance

		for j in range(num_nodes):
			var update_distance = min(stn_matrix[j][node + 1], stn_matrix[j][node] + distance)
			if update_distance < stn_matrix[j][node + 1]:
				stn_matrix[j][node + 1] = update_distance
				stn_matrix[node + 1][j] = -update_distance
				updated = true
			
			update_distance = min(stn_matrix[j][node], stn_matrix[j][node + 1] - distance)
			if update_distance < stn_matrix[j][node]:
				stn_matrix[j][node] = update_distance
				stn_matrix[node][j] = -update_distance
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
			add_temporal_constraint(constraint)

func get_feasible_intervals(start_time: int, end_time: int, new_constraint: TemporalConstraint) -> Array:
	var feasible_intervals = []
	
	for i in range(start_time, end_time - new_constraint.duration + 1):
		var temp_constraint = TemporalConstraint.new(i, i + new_constraint.duration, new_constraint.temporal_qualifier, new_constraint.resource_name)
		if is_consistent_with(temp_constraint):
			feasible_intervals.append(temp_constraint)
	
	return feasible_intervals

func is_consistent_with(constraint: TemporalConstraint) -> bool:
	var temp_stn = SimpleTemporalNetwork.new()
	temp_stn.constraints = constraints.duplicate()
	temp_stn.stn_matrix = stn_matrix.duplicate()
	temp_stn.num_nodes = num_nodes
	temp_stn.node_intervals = node_intervals.duplicate()

	return temp_stn.add_temporal_constraint(constraint) and temp_stn.is_consistent()

