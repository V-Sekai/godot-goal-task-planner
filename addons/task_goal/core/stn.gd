extends Resource

class_name STN

var nodes: Array[int] = []
var constraints: Array[TemporalConstraint] = []
var stn_matrix: Array = []
var num_nodes: int = 0
var node_intervals: Array[Vector2i] = []

func get_node_index(node_intervals: Array[Vector2i], node_interval: Vector2i) -> int:
	for i in range(node_intervals.size()):
		if node_interval == node_intervals[i]:
			return i
	return -1

func add_temporal_constraint(constraint: TemporalConstraint) -> bool:
	var interval: Vector2i = Vector2i(constraint.time_interval.x, constraint.time_interval.y)
	if interval not in node_intervals:
		node_intervals.append(interval)
		num_nodes += 1
		stn_matrix.resize(num_nodes)
		for i in range(num_nodes):
			var array: Array
			array.resize(num_nodes)
			stn_matrix[i] = array

	var left = get_node_index(node_intervals, Vector2i(constraint.time_interval.x, constraint.time_interval.x))
	var right = get_node_index(node_intervals, Vector2i(constraint.time_interval.y, constraint.time_interval.y))
	if left == -1 or right == -1:
		return false

	var distance = constraint.duration

	# Check if this constraint has already been propagated
	if stn_matrix[left][right] <= distance:
		print("Constraint has already been propagated")
		return false

	# Update the constraint
	stn_matrix[left][right] = distance
	stn_matrix[right][left] = -distance

	# Enforce temporal qualifiers
	match constraint.qualifier:
		TemporalConstraint.TemporalQualifier.AT_START:
			for j in range(right, num_nodes):
				var update_distance = min(stn_matrix[left][j], distance)
				stn_matrix[left][j] = update_distance
				stn_matrix[j][left] = -update_distance

				update_distance = min(stn_matrix[right][j], distance - stn_matrix[left][right])
				stn_matrix[right][j] = update_distance
				stn_matrix[j][right] = -update_distance
			propagate_constraints()

		TemporalConstraint.TemporalQualifier.AT_END:
			for j in range(0, left + 1):
				var update_distance = min(stn_matrix[j][right], -distance)
				stn_matrix[j][right] = update_distance
				stn_matrix[right][j] = -update_distance

				update_distance = min(stn_matrix[j][left], -distance + stn_matrix[left][right])
				stn_matrix[j][left] = update_distance
				stn_matrix[left][j] = -update_distance
			propagate_constraints()

		TemporalConstraint.TemporalQualifier.OVERALL:
			for j in range(num_nodes):
				var update_distance = min(stn_matrix[j][right], stn_matrix[j][left] + distance)
				stn_matrix[j][right] = update_distance
				stn_matrix[right][j] = -update_distance

				update_distance = min(stn_matrix[j][left], stn_matrix[j][right] - distance)
				stn_matrix[j][left] = update_distance
				stn_matrix[left][j] = -update_distance
			propagate_constraints()

	constraints.append(constraint)
	return true


func _get_node_key(node1, node2):
	return str(node1) + '_' + str(node2)

func get_temporal_constraint_by_name(resource: PlanResource, constraint_name: String) -> TemporalConstraint:
	for constraint in resource.stn.constraints:
		if constraint.resource_name == constraint_name:
			return constraint
	return null

var LARGE_NUM = 1000000

func _dijkstra(nodes, source, h):
	var visited = {}
	var distances = {}
	for node in nodes:
		distances[node] = INF
	distances[source] = 0

	while len(visited) < len(nodes):
		# Find the unvisited node with the smallest distance
		var min_distance = INF
		var current_node = null
		for node in nodes:
			if node not in visited and distances[node] < min_distance:
				min_distance = distances[node]
				current_node = node

		if current_node == null:
			break

		# Update the distances of the neighbors of the current node
		for neighbor in nodes:
			var key = _get_node_key(current_node, neighbor)
			for constraint in constraints:
				var start: int = constraint.time_interval.x
				var end: int = constraint.time_interval.y
				var weight = constraint.duration
				if start == current_node and end == neighbor:
					var new_distance = distances[current_node] + weight - h[current_node] + h[neighbor]
					if new_distance < distances[neighbor]:
						distances[neighbor] = new_distance

		visited[current_node] = true

	return distances

func bellman_ford() -> Dictionary:
	var distance = {}
	var predecessor = {}

	# Initialize distances to infinity and predecessor to None for all nodes
	for node in node_intervals:
		distance[node] = INF
		predecessor[node] = null

	# Set distance from 0 to 0
	distance[0] = 0

	# Relax edges |V| - 1 times
	for i in range(nodes.size() - 1):
		var updated_nodes = []
		for constraint in constraints:
			var u = constraint.time_interval.x
			var v = constraint.time_interval.y
			var w = constraint.duration
			if distance.keys().has(u) and distance.keys().has(v) and distance[u] + w < distance[v]:
				distance[v] = distance[u] + w
				predecessor[v] = u
				updated_nodes.append(v)

		# If no nodes were updated in this iteration, we can stop early
		if len(updated_nodes) == 0:
			break

	# Check for negative-weight cycles
	for constraint in constraints:
		var u = constraint.time_interval.x
		var v = constraint.time_interval.y
		var w = constraint.duration
		if distance.keys().has(u) and distance.keys().has(v) and distance[u] + w < distance[v]:
			print("Graph contains a negative-weight cycle")
			return {}

	# Fill in the distance and predecessor dictionaries with INF and null, respectively, for unreachable nodes
	for node in nodes:
		if node not in distance:
			distance[node] = INF
		if node not in predecessor:
			predecessor[node] = null

	return distance

func propagate_constraints() -> bool:
	var updated = false
	for i in range(constraints.size()):
		var constraint = constraints[i]
		var left = get_node_index(node_intervals, constraint.time_interval.x)
		var right = get_node_index(node_intervals, constraint.time_interval.y)
		var distance = constraint.duration

		# Check if this constraint has already been propagated
		if stn_matrix[left][right] <= distance:
			continue

		# Update the constraint
		stn_matrix[left][right] = distance
		stn_matrix[right][left] = -distance

		# Enforce temporal qualifiers
		match constraint.temporal_qualifier:
			TemporalConstraint.TemporalQualifier.AT_START:
				for j in range(right, num_nodes):
					if stn_matrix[left][j] > distance:
						stn_matrix[left][j] = distance
						stn_matrix[j][left] = -distance
						updated = true
					if stn_matrix[right][j] > distance:
						stn_matrix[right][j] = distance - stn_matrix[left][right]
						stn_matrix[j][right] = -stn_matrix[right][j]
						updated = true
			TemporalConstraint.TemporalQualifier.AT_END:
				for j in range(0, left + 1):
					if stn_matrix[j][right] > -distance:
						stn_matrix[j][right] = -distance
						stn_matrix[right][j] = -stn_matrix[j][right]
						updated = true
					if stn_matrix[j][left] > -distance:
						stn_matrix[j][left] = -distance + stn_matrix[left][right]
						stn_matrix[left][j] = -stn_matrix[j][left]
						updated = true
			TemporalConstraint.TemporalQualifier.OVERALL:
				for j in range(num_nodes):
					if stn_matrix[j][right] > stn_matrix[j][left] + distance:
						stn_matrix[j][right] = stn_matrix[j][left] + distance
						stn_matrix[right][j] = -stn_matrix[j][right]
						updated = true
					if stn_matrix[j][left] > stn_matrix[j][right] - distance:
						stn_matrix[j][left] = stn_matrix[j][right] - distance
						stn_matrix[left][j] = -stn_matrix[j][left]
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
	# Update the STN with the current state
	for key in state:
		var value = state[key]
		if value is TemporalConstraint:
			# Add constraints for the time interval based on the temporal qualifier
			if value.temporal_qualifier == "atstart":
				var constraint = TemporalConstraint.new(value.time_interval.x, value.duration, value.temporal_qualifier, value.resource_name)
				constraints.append(constraint)
				propagate_constraints()
			elif value.temporal_qualifier == "atend":
				var constraint = TemporalConstraint.new(value.time_interval.y - value.duration, value.duration, value.temporal_qualifier, value.resource_name)
				constraints.append(constraint)
				propagate_constraints()
			elif value.temporal_qualifier == "overall":
				constraints.append(TemporalConstraint.new(0, value.get_end(), value.temporal_qualifier, value.resource_name))
				constraints.append(TemporalConstraint.new(value.time_interval.x, INF, value.temporal_qualifier, value.resource_name))
				propagate_constraints()


func get_debug() -> String :
	var output: String
	for elem in constraints:
		var constraint : TemporalConstraint = elem
		var start = constraint.time_interval.x
		var end = constraint.time_interval.y
		var duration = constraint.duration
		output = output + "STN Constraint -> Start %s -> End %s -> Duration %s\n" % [str(start), str(end), str(duration)]
	return output
