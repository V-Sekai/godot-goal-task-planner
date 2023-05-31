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


func add_temporal_constraint(constraint: TemporalConstraint) -> bool:
	constraints.append(constraint)
	print("Adding constraint:", constraint.to_dictionary())  # Add this line to print the input constraint
	var interval: Vector2i = constraint.time_interval
	if interval not in node_indices:
		node_indices[interval] = num_nodes
		node_intervals.append(interval)
		num_nodes += 1
		_init_matrix()
	var node: int = node_indices[interval]
	if node == -1:
		print("Failed to add constraint:", constraint.to_dictionary(), "Node:", node)
		return false

	var distance = constraint.duration
	print("Node:", node)
	print("Distance:", distance)
	print("STN Matrix before updating:", stn_matrix)

	if node + 1 >= stn_matrix.size():  # Add this check to ensure the index is within bounds
		return false

	if typeof(stn_matrix[node + 1]) != TYPE_ARRAY:
		stn_matrix[node + 1] = []

	stn_matrix[node][node + 1] = distance
	stn_matrix[node + 1][node] = -distance

	if not propagate_constraints():  # Check if the propagation was successful
		print("Failed to add constraint:", constraint.to_dictionary(), "Node:", node)
		stn_matrix[node][node + 1] = INF
		stn_matrix[node + 1][node] = -INF
		return false

	print("Adding constraint: %s" % constraint.to_dictionary())
	constraints.append(constraint)  # Move this line after the propagation check
	for c in constraints:
		print("Constraints after adding: %s" % c.to_dictionary())

	print("STN Matrix after updating:", stn_matrix)

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
				if stn_matrix[i][k] != INF and stn_matrix[k][j] != INF:
					if stn_matrix[i][j] == INF or stn_matrix[i][k] + stn_matrix[k][j] < stn_matrix[i][j]:
						stn_matrix[i][j] = stn_matrix[i][k] + stn_matrix[k][j]

	for i in range(num_nodes):
		if stn_matrix[i][i] != INF and stn_matrix[i][i] < 0:
			print("Negative diagonal value at index", i)  # Add this line to print the problematic index
			return false

	return true
	

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


func is_consistent_with(constraint: TemporalConstraint) -> bool:
	var temp_stn = SimpleTemporalNetwork.new()
	temp_stn.constraints = constraints.duplicate()
	temp_stn.stn_matrix = stn_matrix.duplicate()
	temp_stn.num_nodes = num_nodes
	temp_stn.node_intervals = node_intervals.duplicate()

	return temp_stn.add_temporal_constraint(constraint) and temp_stn.is_consistent()
