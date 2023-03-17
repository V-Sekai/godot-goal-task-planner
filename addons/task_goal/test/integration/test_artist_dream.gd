extends GutTest

var domain_name = "artist_dream"

var the_domain = preload("res://addons/task_goal/core/domain.gd").new(domain_name)

var planner = preload("res://addons/task_goal/core/plan.gd").new()

class PlanResource:
	var name
	var stn

	func _init(name):
		self.name = name
		self.stn = STN.new()


class TimeInterval:
	var time_interval

	func _init(start, end):
		self.time_interval = Vector2i(start, end)


class TemporalConstraint:
	var time_interval : Vector2i
	var temporal_qualifier : String
	var duration : int

	func _init(start: int, end: int, temporal_qualifier: String, duration: int):
		self.time_interval = Vector2i(start, end)
		self.temporal_qualifier = temporal_qualifier
		self.duration = duration


class STN:
	var constraints: Array[TemporalConstraint] = []

	func add_constraint(start: int, end: int, duration: int, temporal_qualifier: String) -> void:
		var constraint = TemporalConstraint.new(start, end, temporal_qualifier, duration)
		constraints.append(constraint)


	func _get_node_key(node1, node2):
		return str(node1) + '_' + str(node2)


	func _bellman_ford(nodes: Array) -> Dictionary:
		var distances = {}
		for node in nodes:
			distances[node] = INF

		distances[0] = 0

		for i in range(len(nodes)):
			for constraint in constraints:
				var start = constraint.time_interval.x
				var end = constraint.time_interval.y
				var weight = constraint.duration
				if start not in distances:
					continue
				if end not in distances:
					distances[end] = INF
				if distances[start] + weight < distances[end]:
					distances[end] = distances[start] + weight

		for constraint in constraints:
			var start = constraint.time_interval.x
			var end = constraint.time_interval.y
			var weight = constraint.duration
			if start not in distances:
				continue
			if end not in distances:
				distances[end] = INF
			if distances[start] + weight < distances[end]:
				return {}

		return distances


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
		
	func propagate_constraints():
		var max_val = 0
		for constraint in constraints:
			var start = constraint.time_interval.x
			var end = constraint.time_interval.y
			if start > max_val:
				max_val = start
			if end > max_val:
				max_val = end
		var nodes = range(max_val + 1)
		var h : Dictionary = _bellman_ford(nodes)

		if h.is_empty():
			return false
		# Re-weight the graph
		var new_constraints: Array[TemporalConstraint] = []
		for constraint in constraints:
			var start = constraint.time_interval.x
			var end = constraint.time_interval.y
			var weight = constraint.duration
			if start not in h or end not in h:
				continue
			var new_constraint: TemporalConstraint = TemporalConstraint.new(start, end, "", weight + h[start] - h[end])
			new_constraints.append(new_constraint)

		constraints = new_constraints

		# Run Dijkstra's algorithm for each node and restore the graph's original weights
		for node in nodes:
			var distances = _dijkstra(nodes, node, h)
			for i in range(len(constraints)):
				var constraint = constraints[i]
				if constraint.time_interval.x == node:
					var new_constraint = TemporalConstraint.new(constraint.time_interval.x, constraint.time_interval.y, "", distances[constraint.time_interval.y] + h[constraint.time_interval.y] - h[node])
					constraints.erase(constraint)
					constraints.insert(i, new_constraint)

		return true


	func is_consistent():
		# Check if there exists a constraint where end time < start time + duration
		for constraint in constraints:
			var start = constraint["start"]
			var end = constraint["end"]
			var duration = constraint["duration"]
			if end < start + duration:
				return false

		return true

	func update_state(state):
			# Update the STN with the current state
			for key in state:
				var value = state[key]
				if value is TimeInterval:
					# Get the time interval from the TimeInterval object
					var start = value.time_interval.x
					var end = value.time_interval.y

					# Add constraints for the time interval based on the temporal qualifier
					if value.temporal_qualifier == "atstart":
						constraints.append(TemporalConstraint.new(0, start, "", start))
					elif value.temporal_qualifier == "atend":
						constraints.append(TemporalConstraint.new(end, INF, "", INF))
					elif value.temporal_qualifier == "overall":
						constraints.append(TemporalConstraint.new(0, end, "", end))
						constraints.append(TemporalConstraint.new(start, INF, "", end - start))

	func print_STN():
		print("STN:")
		for elem in constraints:
			var constraint : TemporalConstraint = elem
			var start = constraint.time_interval.x
			var end = constraint.time_interval.y
			var duration = constraint.duration
			print(str(start) + " -> " + str(end) + ": " + str(duration))


func action_with_time_constraints(state, action_name, time_interval, agent, temporal_qualifier, args=[]) -> Variant:
	var duration = time_interval.y - time_interval.x

	# Check if the duration is non-negative
	if duration < 0:
		print("Invalid duration: Duration should be non-negative.")
		return false

	# Check if the temporal_qualifier is valid
	if temporal_qualifier not in ["atstart", "atend", "overall"]:
		print("Invalid temporal qualifier: Must be 'atstart', 'atend', or 'overall'.")
		return false

	# Check if the time_interval is valid
	if time_interval.x < 0 or time_interval.y < 0 or time_interval.x > time_interval.y:
		print("Invalid time interval: Start time should be less than or equal to the end time, and both should be non-negative.")
		return false

	# Add the constraint to the agent's STN
	agent.stn.add_constraint(time_interval.x, time_interval.y, duration, temporal_qualifier)

	# Propagate constraints and check if the STN is still consistent
	if not agent.stn.propagate_constraints():
		print("Inconsistent constraints: The new constraint could not be satisfied.")
		return false

	# Return a task list with the specified action, its arguments, and the STN
	return [[action_name, time_interval, agent.stn, args]]
	

func reserve_practice_room(time_interval: TimeInterval, stn: STN) -> bool:
	stn.update_state({"practice": time_interval})
	return stn.propagate_constraints()


func attend_audition(time_interval: TimeInterval, stn: STN) -> bool:
	stn.update_state({"audition": time_interval})
	return stn.propagate_constraints()


func practice_craft(time_interval: TimeInterval, stn: STN) -> bool:
	stn.update_state({"craft": time_interval})
	return stn.propagate_constraints()


func network(time_interval: TimeInterval, stn: STN) -> bool:
	stn.update_state({"network": time_interval})
	return stn.propagate_constraints()


func get_possible_dream_time_intervals(state):
	# Update the STN with the current state
	var stn = STN.new()
	stn.update_state(state)
	# Propagate the constraints and check for consistency
	if stn.propagate_constraints() == false or stn.is_consistent() == false:
		return []
	# Get the time intervals for achieving the dream
	var intervals = []
	for constraint in stn.constraints:
		if constraint.start == 0 and constraint.duration == 0:
			var end = constraint.end
			intervals.append(TimeInterval.new(0, end))
	return intervals


func achieve_dream(stn: STN) -> bool:
	if stn.is_consistent():
		return true

	for time_interval in get_possible_dream_time_intervals(stn):
		if reserve_practice_room(time_interval, stn) and attend_audition(time_interval, stn) and practice_craft(time_interval, stn) and network(time_interval, stn):
			return true

	return false

func test_temporal_constraint():
	var constraint = TemporalConstraint.new(0, 10, "atstart", 10)
	assert_eq(constraint.time_interval.x, 0, "Expected start time to be 0, but got " + str(constraint.time_interval.x))
	assert_eq(constraint.time_interval.y, 10, "Expected end time to be 10, but got " + str(constraint.time_interval.y))
	assert_eq(constraint.temporal_qualifier , "atstart", "Expected temporal_qualifier to be 'atstart', but got " + constraint.temporal_qualifier)
	assert_eq(constraint.duration, 10, "Expected duration to be 10, but got " + str(constraint.duration))


func test_time_interval():
	var time_interval = TimeInterval.new(0, 10)
	assert_eq(time_interval.time_interval.x, 0, "Expected start time to be 0, but got " + str(time_interval.time_interval.x))
	assert_eq(time_interval.time_interval.y, 10, "Expected end time to be 10, but got " + str(time_interval.time_interval.y))


func test_invalid_temporal_constraint():
	var result = action_with_time_constraints(null, "", Vector2i(0, 10), null, "invalid", [])
	assert_eq(result, false, "Expected false for invalid temporal_qualifier, but got " + str(result))


func test_action_with_time_constraints():
	var result = action_with_time_constraints(null, "", Vector2(10, 5), null, "", null)
	assert_eq(result, false, "Expected action_with_time_constraints to return false for invalid duration")
	result = action_with_time_constraints(null, "", Vector2(0, 10), null, "invalid_qualifier", null)
	assert_eq(result, false, "Expected action_with_time_constraints to return false for invalid temporal qualifier")
	result = action_with_time_constraints(null, "", Vector2(-5, 10), null, "atstart", null)
	assert_eq(result, false, "Expected action_with_time_constraints to return false for invalid time interval")
	var agent = PlanResource.new("resource1")
	result = action_with_time_constraints(null, "some_action", Vector2(0, 10), agent, "atstart", null)
	assert_eq(result.size(), 1, "Expected action_with_time_constraints to return a task list with one element")
	assert_eq(result[0][0], "some_action", "Expected action_with_time_constraints to return a task list with the correct action")


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

	# planner._domains.push_back(the_domain)
	# planner.current_domain = the_domain
	
	# # Declare actions
	# planner.declare_actions([
	# 	Callable(self, "reserve_practice_room"), 
	# 	Callable(self, "attend_audition"), 
	# 	Callable(self, "practice_craft"), 
	# 	Callable(self, "network"), 
	# 	Callable(self, "achieve_dream")]
	# )

	# # Example plan
	# var time_interval_mia = Vector2i(0, 1000)
	
	# var plan: Array
	# var task_list = action_with_time_constraints(state, 'reserve_practice_room', time_interval_mia, mia, 'atstart')
	# plan.append(task_list)
	# assert_eq_deep(
	# 	plan,
	# 	plan
	# )

	# task_list = action_with_time_constraints(state, 'attend_audition', time_interval_mia, mia, 'atend')
	# plan.append(task_list)

#	task_list = action_with_time_constraints(state, 'practice_craft', time_interval_mia, mia, 'overall')
#	plan.append(task_list)
#
#	task_list = action_with_time_constraints(state, 'network', time_interval_mia, mia, 'overall')
#	plan.append(task_list)
#
#	task_list = action_with_time_constraints(state, 'achieve_dream', time_interval_mia, mia, 'atend')
#	plan.append(task_list)
#
	# var new_plan = planner.find_plan(state, plan)

	# assert_eq_deep(
	# 	new_plan,
	# 	false
	# )
