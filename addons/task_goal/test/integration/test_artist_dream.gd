extends GutTest

var domain_name = "artist_dream"

var the_domain = preload("res://addons/task_goal/core/domain.gd").new(domain_name)

var planner = preload("res://addons/task_goal/core/plan.gd").new()

class PlanResource:
	extends Resource
	var stn : STN

	func _init(name):
		self.set_name(name)
		self.stn = STN.new()

	func get_feasible_intervals(start_time: int, end_time: int, duration: int) -> Array[TemporalConstraint]:
		stn.print_STN()
		
		# Propagate constraints to ensure consistency
		stn.propagate_constraints()
	
		var feasible_intervals: Array[TemporalConstraint] = []
		
		print(stn.constraints)

		for other_constraint in stn.constraints:
			var interval = other_constraint.time_interval
	
			var feasible_interval_start : int = max(interval.x, start_time)
			print("Feasible interval start: %d" % [feasible_interval_start])
			var feasible_interval_end: int = min(interval.y - duration, end_time)
			print("Feasible interval end: %d" % [feasible_interval_end])
			if feasible_interval_end < feasible_interval_start:
				continue
	
			if feasible_interval_end >= feasible_interval_start:
				var feasible_interval: TemporalConstraint = TemporalConstraint.new(feasible_interval_start, feasible_interval_end - feasible_interval_start, TemporalQualifier.OVERALL, "feasible interval")
				feasible_intervals.append(feasible_interval)
	
		if feasible_intervals.size() == 0:
			return []
		else:
			return feasible_intervals


enum TemporalQualifier {
	AT_START,
	AT_END,
	OVERALL,
}


class TemporalConstraint:
	extends Resource
	var time_interval: Vector2i
	var duration: int
	var temporal_qualifier: TemporalQualifier
	var direct_successors: Array

	func _init(start: int, duration: int, qualifier: TemporalQualifier, resource: String):
		time_interval = Vector2i(start, start + duration)
		self.duration = duration
		temporal_qualifier = qualifier
		resource_name = resource
		direct_successors = []

	func to_string() -> String:
		return "Constraint Name: %s Time Interval: %s Duration: %s Temporal Qualifier: %s" % [resource_name, time_interval, duration, temporal_qualifier]

	func add_direct_successor(successor_index: int, time_difference: int) -> void:
		direct_successors.append({"index": successor_index, "time_difference": time_difference})

	func deep_equal(other: Object) -> bool:
		if other is TemporalConstraint:
			return self.time_interval == other.time_interval and \
					self.duration == other.duration and \
					self.qualifier == other.qualifier and \
					self.description == other.description
		return false

class STN:
	extends Resource
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
				array.fill(0)
				stn_matrix[i] = array
	
		print("Node intervals:", node_intervals)
	
		var left = get_node_index(node_intervals, Vector2i(constraint.time_interval.x, constraint.time_interval.x))
		var right = get_node_index(node_intervals, Vector2i(constraint.time_interval.y, constraint.time_interval.y))
		if left == -1 or right == -1:
			return false
	
		print("Left:", left, "Right:", right)
	
		var distance = constraint.duration
	
		# Check if this constraint has already been propagated
		if stn_matrix[left][right] <= distance:
			print("Constraint has already been propagated")
			return false
	
		# Update the constraint
		stn_matrix[left][right] = distance
		stn_matrix[right][left] = -distance
	
		print("STN matrix after updating constraint:", stn_matrix)
	
		# Enforce temporal qualifiers
		match constraint.qualifier:
			TemporalQualifier.AT_START:
				for j in range(right, num_nodes):
					if stn_matrix[left][j] > distance:
						stn_matrix[left][j] = distance
						stn_matrix[j][left] = -distance
						propagate_constraints()
					if stn_matrix[right][j] > distance:
						stn_matrix[right][j] = distance - stn_matrix[left][right]
						stn_matrix[j][right] = -stn_matrix[right][j]
						propagate_constraints()
			TemporalQualifier.AT_END:
				for j in range(0, left + 1):
					if stn_matrix[j][right] > -distance:
						stn_matrix[j][right] = -distance
						stn_matrix[right][j] = -stn_matrix[j][right]
						propagate_constraints()
					if stn_matrix[j][left] > -distance:
						stn_matrix[j][left] = -distance + stn_matrix[left][right]
						stn_matrix[left][j] = -stn_matrix[j][left]
						propagate_constraints()
			TemporalQualifier.OVERALL:
				for j in range(num_nodes):
					if stn_matrix[j][right] > stn_matrix[j][left] + distance:
						stn_matrix[j][right] = stn_matrix[j][left] + distance
						stn_matrix[right][j] = -stn_matrix[j][right]
						propagate_constraints()
					if stn_matrix[j][left] > stn_matrix[j][right] - distance:
						stn_matrix[j][left] = stn_matrix[j][right] - distance
						stn_matrix[left][j] = -stn_matrix[j][left]
						propagate_constraints()
	
		print("STN matrix after enforcing qualifiers:", stn_matrix)
	
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
				TemporalQualifier.AT_START:
					for j in range(right, num_nodes):
						if stn_matrix[left][j] > distance:
							stn_matrix[left][j] = distance
							stn_matrix[j][left] = -distance
							updated = true
						if stn_matrix[right][j] > distance:
							stn_matrix[right][j] = distance - stn_matrix[left][right]
							stn_matrix[j][right] = -stn_matrix[right][j]
							updated = true
				TemporalQualifier.AT_END:
					for j in range(0, left + 1):
						if stn_matrix[j][right] > -distance:
							stn_matrix[j][right] = -distance
							stn_matrix[right][j] = -stn_matrix[j][right]
							updated = true
						if stn_matrix[j][left] > -distance:
							stn_matrix[j][left] = -distance + stn_matrix[left][right]
							stn_matrix[left][j] = -stn_matrix[j][left]
							updated = true
				TemporalQualifier.OVERALL:
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


	func print_STN():
		print("STN:")
		for elem in constraints:
			var constraint : TemporalConstraint = elem
			var start = constraint.time_interval.x
			var end = constraint.time_interval.y
			var duration = constraint.duration
			print(str(start) + " -> " + str(end) + ": " + str(duration))


func test_get_feasible_intervals_new_constraint() -> void:
	# Create a new STN
	var stn = STN.new()

	# Create a new PlanResource and add the STN to it
	var resource = PlanResource.new("Resource")
	resource.stn = stn

	# Add some constraints to the STN
	resource.stn.add_temporal_constraint(TemporalConstraint.new(0, 10, TemporalQualifier.OVERALL, "dummy constraint"))
	resource.stn.add_temporal_constraint(TemporalConstraint.new(15, 15, TemporalQualifier.OVERALL, "dummy constraint"))
	resource.stn.add_temporal_constraint(TemporalConstraint.new(20, 5, TemporalQualifier.OVERALL, "dummy constraint"))
	
	var start_time = 5
	var end_time = 35
	var duration = end_time - start_time
	# Get feasible intervals for a new constraint
	var feasible_intervals = resource.get_feasible_intervals(start_time, duration, 10)

	# Print the actual feasible intervals
	print("Actual feasible intervals: ", feasible_intervals)

	# Test that the number of feasible intervals is correct
	assert_eq(feasible_intervals.size(), 1, "Expected one feasible interval")

	# Test that the feasible interval is correct
	var expected_interval = TemporalConstraint.new(15, 10, TemporalQualifier.OVERALL, "feasible interval")
	if feasible_intervals.size():
		assert_eq(feasible_intervals[0], expected_interval, "Expected feasible interval not found")

	# Print the expected feasible interval
	print("Expected feasible interval: ", expected_interval)


func test_propagate_non_overlapping_constraints():
	var mia = PlanResource.new("Mia")
	# Add initial temporal constraints
	mia.stn.add_temporal_constraint(TemporalConstraint.new(0, 25, TemporalQualifier.OVERALL, "dummy constraint"))

	# Add temporal constraint for task
	var task_name = "Task 1"
	var start_time = 5
	var duration = 10
	var task_constraints = TemporalConstraint.new(start_time, duration, TemporalQualifier.OVERALL, task_name)
	mia.stn.add_temporal_constraint(task_constraints)

	# Check that task constraints were added to STN
	var task_constraints_added = false
	for constraint in mia.stn.constraints:
		if constraint.resource_name == task_name:
			task_constraints_added = true
			break

	assert_eq(task_constraints_added, true, "Expected task constraints to be added to STN")

	# Check that the duration of the task constraint was propagated correctly
	var constraint_task_name = mia.stn.get_temporal_constraint_by_name(mia, task_name)

	if constraint_task_name:
		var propagated_duration = constraint_task_name.duration
		assert_eq(propagated_duration, duration, "Expected duration to be propagated correctly")

		var temporal_constraint : TemporalConstraint =  mia.stn.get_temporal_constraint_by_name(mia, task_name)
		# Check that the start time of the task constraint was propagated correctly
		var propagated_start_time = temporal_constraint.time_interval.x
		assert_eq(propagated_start_time, start_time, "Expected start time to be propagated correctly")

	# Check that STN is consistent after propagating constraints
	assert_eq(mia.stn.is_consistent(), true, "Expected STN to be consistent after propagating constraints")

func test_propagate_constraints():
	var mia = PlanResource.new("Mia")
	# Add initial temporal constraints
	mia.stn.add_temporal_constraint(TemporalConstraint.new(0, 25, TemporalQualifier.OVERALL, "dummy constraint"))

	# Add temporal constraint for task
	var task_name = "Task 1"
	var start_time = 5
	var duration = 10
	var task_constraints = TemporalConstraint.new(start_time, duration, TemporalQualifier.OVERALL, task_name)
	mia.stn.add_temporal_constraint(task_constraints)

	# Check that task constraints were added to STN
	var task_constraints_added = false
	for constraint in mia.stn.constraints:
		if constraint.resource_name == task_name:
			task_constraints_added = true
			break

	assert_eq(task_constraints_added, true, "Expected task constraints to be added to STN")

	# Check that the duration of the task constraint was propagated correctly
	var constraint_task_name = mia.stn.get_temporal_constraint_by_name(mia, task_name)

	if constraint_task_name:
		var propagated_duration = constraint_task_name.duration
		assert_eq(propagated_duration, duration, "Expected duration to be propagated correctly")

		var temporal_constraint : TemporalConstraint = mia.stn.get_temporal_constraint_by_name(mia, task_name)
		# Check that the start time of the task constraint was propagated correctly
		var propagated_start_time = temporal_constraint.time_interval.x
		assert_eq(propagated_start_time, start_time, "Expected start time to be propagated correctly")

	# Check that STN is consistent after propagating constraints
	assert_eq(mia.stn.is_consistent(), true, "Expected STN to be consistent after propagating constraints")


func test_task_duration_shorter_than_feasible_intervals():
	var mia = PlanResource.new("Mia")
	mia.stn.add_temporal_constraint(TemporalConstraint.new(10, 20, TemporalQualifier.OVERALL, "dummy constraint"))

	var start_time = 5
	var end_time = 15
	var duration = 5
	var task_constraints: Array[TemporalConstraint] = [
		TemporalConstraint.new(start_time, duration, TemporalQualifier.OVERALL, "Feasible interval [10, 15]")
	]

	var feasible = mia.get_feasible_intervals(start_time, end_time, duration)
	assert_eq(feasible.size(), 0, "Expected no feasible intervals")


func method_with_time_constraints(state, action_name, time_interval : TemporalConstraint, agent, args=[]) -> Variant:
	# Check if agent is not null
	if agent == null:
		print("Invalid agent: agent cannot be null.")
		return false

	var duration = time_interval.duration

	# Check if the duration is non-negative
	if duration < 0:
		print("Invalid duration: Duration should be non-negative.")
		return false

	# Check if the temporal_qualifier is valid
	if time_interval.temporal_qualifier not in [TemporalQualifier.AT_START, TemporalQualifier.AT_END, TemporalQualifier.OVERALL]:
		print("Invalid temporal qualifier: Must be 'atstart', 'atend', or 'overall'.")
		return false

	# Check if the time_interval is valid
	if time_interval.time_interval.x < 0 or time_interval.duration < 0 or time_interval.time_interval.y < time_interval.time_interval.x:
		print("Invalid time interval: Start time should be less than or equal to the end time, and both should be non-negative.")
		return false

	# Add the constraint to the agent's STN
	agent.stn.add_temporal_constraint(TemporalConstraint.new(time_interval.time_interval.x, time_interval.duration, time_interval.temporal_qualifier, time_interval.resource_name))

	# Propagate constraints and check if the STN is still consistent
	if not agent.stn.is_consistent():
		print("Inconsistent constraints: The new constraint could not be satisfied.")
		return false

	# Return a task list with the specified action, its arguments, and the STN
	return [action_name, time_interval, agent.stn]


func reserve_practice_room(state, time_interval: TemporalConstraint, stn: STN) -> Variant:
	# Update the state to show that the practice room is reserved
	state['shared_resource']['practice_room'] = 'reserved'
	state['task_status']['reserve_room'] = 'done'
	# Add the time interval to the STN and propagate the constraints
	stn.update_state({"practice": time_interval})
	if not stn.is_consistent():
		return false
	return []


func attend_audition(state, time_interval: TemporalConstraint, stn: STN) -> Variant:
	# Update the state to show that the audition has been attended
	state['task_status']['audition'] = 'attended'
	# Add the time interval to the STN and propagate the constraints
	stn.update_state({"audition": time_interval})
	if not stn.propagate_constraints():
		return false
	return []


func practice_craft(state, time_interval: TemporalConstraint, stn: STN) -> Variant:
	# Update the state to show that the practice has been done
	state['task_status']['practice'] = 'done'
	# Add the time interval to the STN and propagate the constraints
	stn.update_state({"craft": time_interval})
	if not stn.propagate_constraints():
		return false
	return []


func network(state, time_interval: TemporalConstraint, stn: STN) -> Variant:
	# Update the state to show that networking has been done
	state['task_status']['networking'] = 'done'
	# Add the time interval to the STN and propagate the constraints
	stn.update_state({"network": time_interval})
	if not stn.propagate_constraints():
		return false
	return []


func test_time_interval():
	var time_interval = TemporalConstraint.new(0, 10, TemporalQualifier.OVERALL, "0 to 10")
	assert_eq(time_interval.time_interval.x, 0, "Expected start time to be 0, but got " + str(time_interval.time_interval.x))
	assert_eq(time_interval.time_interval.y, 10, "Expected end time to be 10, but got " + str(time_interval.time_interval.y))


func test_invalid_temporal_constraint():
	var result = method_with_time_constraints(null, "", TemporalConstraint.new(0, 10, TemporalQualifier.OVERALL, "Invalid temporal qualifier"), null, [])
	assert_eq(result, false, "Expected false for invalid temporal_qualifier, but got " + str(result))

func test_add_temporal_constraint():
	var mia = PlanResource.new("Mia")

	# Add some initial constraints
	mia.stn.add_temporal_constraint(TemporalConstraint.new(0, 10, TemporalQualifier.OVERALL, "constraint"))
	mia.stn.add_temporal_constraint(TemporalConstraint.new(15, 30, TemporalQualifier.OVERALL, "constraint"))
	mia.stn.add_temporal_constraint(TemporalConstraint.new(20, 25, TemporalQualifier.OVERALL, "constraint"))

	# Add a new constraint and check that it is present in the STN
	var new_constraint = TemporalConstraint.new(5, 15, TemporalQualifier.OVERALL, "constraint")
	mia.stn.add_temporal_constraint(new_constraint)
	
	mia.stn.print_STN()

	var found_new_constraint = false
	for constraint in mia.stn.constraints:
		if constraint.deep_equal(new_constraint):
			found_new_constraint = true
			break

	assert_true(found_new_constraint)


func test_method_with_time_constraints():
	var result = method_with_time_constraints(null, "", TemporalConstraint.new(10, 5, TemporalQualifier.OVERALL, "Invalid duration"), null, [])
	assert_eq(result, false, "Expected method_with_time_constraints to return false for invalid duration")
	result = method_with_time_constraints(null, "", TemporalConstraint.new(-5, 10, TemporalQualifier.OVERALL, "Invalid time interval"), null, [])
	assert_eq(result, false, "Expected method_with_time_constraints to return false for invalid time interval")
	var agent = PlanResource.new("resource1")
	result = method_with_time_constraints(null, "some_action", TemporalConstraint.new(0, 10, TemporalQualifier.AT_START, "Zero task list elements"), agent, [])
	if result == null:
		return
	assert_eq(result.size(), 3, "Expected method_with_time_constraints to return a task list with elements")
	if result.size():
		assert_eq(result[0], "some_action", "Expected method_with_time_constraints to return a task list with the correct action")


func get_possible_dream_time_intervals(stn: STN) -> Array[TemporalConstraint]:
	# Determine the minimum and maximum possible start times
	var min_start = INF
	var max_start = 0
	for constraint in stn.constraints:
		var start = constraint.time_interval.x
		if start < min_start:
			min_start = start
		if start > max_start:
			max_start = start

	# Generate all possible time intervals within the minimum and maximum start times
	var time_intervals : Array[TemporalConstraint] = []
	for start_time in range(min_start, max_start + 1):
		var end_time = start_time + 24
		var time_interval = TemporalConstraint.new(start_time, end_time - start_time, TemporalQualifier.OVERALL, "")
		if stn.is_valid_constraint(time_interval):
			time_intervals.append(time_interval)

	return time_intervals

func achieve_dream(state, resource) -> Variant:
	var stn = resource.stn
	var feasible_intervals = resource.get_feasible_intervals(0, INF, 1)

	var start_time: int = 0
	var end_time: int = 0
	var duration: int = 0
	for interval in feasible_intervals:
		start_time = interval.time_interval.x
		end_time = interval.time_interval.y
		duration = end_time - start_time

		# Clear STN
		stn.constraints.clear()

		# Add constraints for the interval
		stn.add_temporal_constraint(start_time, duration, "overall")
		stn.add_temporal_constraint(start_time, 1, "atstart")

		# Add constraints for the remaining tasks
		stn.add_temporal_constraint(start_time + 15, 1, "atstart")

		stn.add_temporal_constraint(start_time + 25, 5, "atstart")

		# Propagate constraints and check if consistent
		if stn.propagate_constraints() and stn.is_consistent():
			# Update state and return task list
			state['shared_resource']['practice_room'] = 'unavailable'
			state['task_status']['reserve_practice_room'] = 'done'
			return [
				["attend_audition", TemporalConstraint.new(start_time + 15, 1, TemporalQualifier.AT_START, "attend_audition"), resource.stn],
				["practice_craft", TemporalConstraint.new(start_time + 15, 10, TemporalQualifier.OVERALL, "practice_craft"), resource.stn],
				["network", TemporalConstraint.new(start_time + 25, 5, TemporalQualifier.AT_START, "network"), resource.stn],
				["achieve_dream", TemporalConstraint.new(start_time + 30, INF, TemporalQualifier.OVERALL, "achieve_dream"), resource.stn]
			]

	# No feasible intervals found
	return false



func _ready():
	# Declare agents
	var mia = PlanResource.new("Mia")
	var sebastian = PlanResource.new("Sebastian")

	# State representation
	var state = {
		'location': {
			'Mia': 'home',
			'Sebastian': 'home',
		},
		'task_status': {
			'reserve_room': 'not_done',
			'audition': 'not_attended',
			'practice': 'not_done',
			'networking': 'not_done',
			'achieve_dream': 'not_done',
		},
		'shared_resource': {
			'practice_room': 'available',
		},
	}

	planner._domains.push_back(the_domain)
	planner.current_domain = the_domain

	# # Declare actions
	planner.declare_actions([
		Callable(self, "reserve_practice_room"),
		Callable(self, "attend_audition"),
		Callable(self, "practice_craft"),
		Callable(self, "network"),
		Callable(self, "achieve_dream")]
	)

	planner.declare_task_methods(
		"travel",
		[
			Callable(self, "do_nothing"),
			Callable(self, "travel_by_foot"),
			Callable(self, "travel_by_taxi")
		]
	)

	planner.declare_task_methods("achieve_dream", [
		Callable(self, "achieve_dream")
	])

#	var plan = planner.find_plan(state, [["achieve_dream", mia]])
#
#	assert_eq(
#		plan,
#		false,
#		"Expected method_with_time_constraints to return achieve_dream"
#	)
#
