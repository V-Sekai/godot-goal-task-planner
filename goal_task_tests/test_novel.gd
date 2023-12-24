# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_simple_nine_squares.gd
# SPDX-License-Identifier: MIT

extends GutTest

var domain_name = "isekai_anime"
var the_domain = preload("res://addons/task_goal/core/domain.gd").new(domain_name)

var planner = preload("res://addons/task_goal/core/plan.gd").new()


func distance(x: String, y: String) -> float:
	var result = dist.get([x, y])
	if result == null:
		return INF
	if result > 0:
		return result
	result = dist.get([y, x])
	if result == null:
		return INF
	if result > 0:
		return result
	return INF


func is_a(variable, type) -> bool:
	return variable in types[type]


func do_mia_close_door(state, location, status) -> Variant:
	var person = "Mia"
	if is_a(person, "character") and is_a(location, "location") and is_a(location, "door"):
		if state["door"][location] == 'closed':
			if the_domain.verbose > 0:
				print("Door at location: %s is already closed" % location)
			return []
		else:
			if the_domain.verbose > 0:
				print("Attempting to change door status at location: %s to %s" % [location, status])
			var actions = []
			actions.append(["travel", person, location])
			actions.append(["close_door", person, location, "closed"])
			actions.append(["idle", person, 0])
			return actions
	else:
		if the_domain.verbose > 0:
			print("Cant close door %s %s:" % [person, location])
	return false

func do_close_door(state, person, location, status, goal_time) -> Variant:
	if is_a(person, "character") and is_a(location, "location") and is_a(location, "door"):
		if state["door"][location] == "closed":
			if the_domain.verbose > 0:
				print("Door at location: %s is already closed" % location)
			return []
		elif state["door"][location] == "opened":
			print("Goal time: %s" % goal_time)
			if the_domain.verbose > 0:
				print("Attempting to change door status at location: %s to %s" % [location, status])
			var actions = []
			actions.append(["travel", person, location])
			actions.append(["close_door", person, location, "closed"])
			actions.append(["idle", person, goal_time])
			if goal_time >= state["time"][person]:
				actions.append(["idle", person, goal_time])
			return actions
	else:
		if the_domain.verbose > 0:
			print("Cant close door %s %s:" % [person, location])
	return false


func close_door(state, person, location, status) -> Variant:
	if is_a(location, "location") and is_a(person, "character") and state["loc"][person] == location:
		if state["door"][location] == "opened":
			state["door"][location] = status
			if the_domain.verbose > 0:
				print("The door at location %s has been closed." % [location])
			return state
	return false

func idle(state, person, goal_time) -> Variant:
	if is_a(person, "character"):
		var current_time = state["time"][person]
		if current_time > goal_time:
			if the_domain.verbose > 0:
				print("idle warning: Current time is greater than goal time. Adjusting goal time.")
			goal_time = current_time
		var _idle_time = goal_time - current_time
		if _idle_time <= 0:
			if the_domain.verbose > 0:
				print("idle warning: Idle time is less than or equal to 0. Adjusting idle time.")
			_idle_time = 1
		var constraint_name = "%s_idle_until_%s" % [person, goal_time]
		var constraint = TemporalConstraint.new(current_time, goal_time, _idle_time, TemporalConstraint.TemporalQualifier.AT_END, constraint_name)
		if state["stn"][person].add_temporal_constraint(constraint):
			if the_domain.verbose > 0:
				print("idle called")
			state["time"][person] = goal_time
			return state
		else:
			if the_domain.verbose > 0:
				print("idle error: Failed to add temporal constraint %s" % constraint.to_dictionary())
	return false

func do_idle(state, person, goal_time) -> Variant:
	if is_a(person, "character"):
		if the_domain.verbose > 0:
			print("Current time for %s: %s" % [person, state["time"][person]])
			print("Goal time: %s" % goal_time)
		if goal_time >= state["time"][person]:
			return [["idle", person, goal_time]]
		else:
			if the_domain.verbose > 0:
				print("Error: Goal time is less than current time: %s" % goal_time)
	return false

func walk(state, p, x, y, goal_time) -> Variant:
	if state["loc"][p] != x:
		print("Walk error: Character is not at the expected location ", x)
		return
	if is_a(p, "character") and is_a(x, "location") and is_a(y, "location") and x != y:
		var current_location = state.loc[p]
		if current_location == x:
			var current_time = state.time[p]
			if current_time < goal_time:
				current_time = goal_time
			var _travel_time = travel_time(x, y, "foot")
			var arrival_time = current_time + _travel_time
			var constraint_name = "%s_walk_from_%s_to_%s" % [p, x, y]
			var constraint = TemporalConstraint.new(current_time, arrival_time, _travel_time, TemporalConstraint.TemporalQualifier.AT_END, constraint_name)
			if state["stn"][p].add_temporal_constraint(constraint):
				state.loc[p] = y
				state["time"][p] = arrival_time
				return state
			else:
				if the_domain.verbose > 0:
					print("walk error: Failed to add temporal constraint %s" % constraint.to_dictionary())
		else:
			print("walk error: Character is not at the expected location %s" % current_location)
	return false

func travel_time(x, y, mode) -> int:
	var _distance = distance(x, y)
	if mode == "foot":
		return _distance / 1
	elif mode == "car":
		return _distance / 5
	else:
		print("Error: Invalid mode of transportation")
		return -1


func do_nothing(state, p, y) -> Variant:
	if is_a(p, "character"):
		state["time"][p] += y
		return []
	return false


func travel_by_foot(state, p, destination) -> Variant:
	if is_a(p, "character") and is_a(destination, "location"):
		var current_location = state.loc[p]
		if current_location == destination:
			return [["idle", p, state["time"][p]]]
		elif current_location != null:
			return [["find_path", p, destination]]
	return false


var memo = {}

var prev = {}


func find_path(state, p, destination) -> Variant:
	var current_location = state["loc"][p]
	var pq = [[0, current_location]]  # Initialize priority queue with current location and distance as 0

	var dist = {}
	var prev = {}
	for loc in types["location"]:
		dist[loc] = INF  # Set initial distances to infinity
		prev[loc] = null  # Set initial previous locations to null
	dist[current_location] = 0

	while pq.size() > 0:
		pq.sort()
		var top = pq.pop_front()  # In Dijkstra's, we use a priority queue and pop the smallest element
		var d = top[0]
		var u = top[1]

		if d != dist[u]:
			continue

		for loc in types["location"]:
			if loc == u or distance(u, loc) == INF:
				continue
			var travel_time_to_loc = travel_time(u, loc, "foot")
			if dist[u] + travel_time_to_loc < dist[loc]:
				dist[loc] = dist[u] + travel_time_to_loc
				prev[loc] = u  # Update the previous location
				pq.push_back([dist[loc], loc])

	if not dist.has(destination):
		return false

	# If a path exists, reconstruct it by following the previous locations from the destination to the start
	var path = []
	var uu = destination
	while uu != null:
		if prev[uu] != null and prev[uu] != uu:
			var travel_time = travel_time(prev[uu], uu, "foot")  # Calculate the travel time between two consecutive locations
			path.push_front(["walk", p, prev[uu], uu, travel_time])  # Insert at the beginning to reverse the path
		uu = prev[uu]

	return path


func compare_goal_times(a, b) -> bool:
	return a[1] > b[1]


func path_has_location(path, location) -> bool:
	for step in path:
		if step[3] == location:  # Check the destination of each step
			if the_domain.verbose > 0:
				print("Location %s found in path" % location)
			return true
	if the_domain.verbose > 0:
		print("Location %s not found in path" % location)
	return false


# func fight(state, character, enemy):
# func interact(state, character, npc):
# func craft(state, character, item):
# func level_up(state, character):

@export var types = {
	"character": ["Mia", "Frank", "Chair"],
	"location": ["home_Mia", "home_Frank", "cinema", "station", "mall", "park", "restaurant", "school", "office", "gym", "library", "hospital", "beach", "supermarket", "museum", "zoo", "airport"],
	"door": ["home_Mia", "home_Frank", "cinema", "station", "mall", "park", "restaurant", "school", "office", "gym", "library", "hospital", "beach", "supermarket", "museum", "zoo", "airport"],
	"vehicle": ["car1", "car2"],
	"owe": [],
	"stn": [],
}

@export var state0: Dictionary = {"loc": {"Mia": "home_Mia", "Chair": "home_Mia", "Frank": "home_Frank", "car1": "cinema", "car2": "station"}, "cash": {"Mia": 30, "Frank": 35}, "owe": {"Mia": 0, "Frank": 0}, "time": {"Mia": 0, "Frank": 0, "Chair": 0}, "stn": {"Mia": SimpleTemporalNetwork.new(), "Frank": SimpleTemporalNetwork.new(), "Chair": SimpleTemporalNetwork.new()}, "door": {}}

@export var dist: Dictionary = {
	["home_Mia", "cinema"]: 12,
	["cinema", "home_Mia"]: 12,
	["home_Frank", "cinema"]: 4,
	["cinema", "home_Frank"]: 4,
	["station", "home_Mia"]: 1,
	["station", "home_Frank"]: 10,
	["station", "cinema"]: 12,
	["home_Mia", "station"]: 12,
	["home_Mia", "mall"]: 8,
	["home_Frank", "mall"]: 10,
	["home_Frank", "hospital"]: 20,
	["hospital", "home_Frank"]: 20,
	["mall", "cinema"]: 7,
	["home_Mia", "park"]: 5,
	["park", "restaurant"]: 5,
	["restaurant", "school"]: 6,
	["school", "office"]: 7,
	["office", "gym"]: 8,
	["gym", "library"]: 9,
	["library", "hospital"]: 10,
	["hospital", "beach"]: 11,
	["beach", "supermarket"]: 12,
	["supermarket", "park"]: 13,
	["park", "museum"]: 13,
	["museum", "zoo"]: 14,
	["zoo", "airport"]: 15,
	["airport", "home_Mia"]: 16,
	["airport", "home_Frank"]: 17,
}

var goal1 = Multigoal.new("goal1", {"loc": {"Mia": "airport"}, "time": {"Mia": 59}})

var goal2 = Multigoal.new("goal2", {"loc": {"Mia": "supermarket"}, "time": {"Mia": 15}})


func before_each() -> void:
	for location in types["location"]:
		state0["door"][location] = "opened"
	planner.verbose = 0
	planner._domains.push_back(the_domain)
	planner.current_domain = the_domain
	planner.declare_actions([Callable(self, "wait_for_everyone"), Callable(self, "close_door"), Callable(self, "walk"), Callable(self, "do_nothing"), Callable(self, "idle")])

	planner.declare_unigoal_methods("loc", [Callable(self, "travel_by_foot")])
	planner.declare_unigoal_methods("time", [Callable(self, "do_idle")])
	planner.declare_unigoal_methods("door", [Callable(self, "do_mia_close_door")])
	planner.declare_task_methods("travel", [Callable(self, "travel_by_foot"), Callable(self, "find_path")])
	planner.declare_task_methods("find_path", [Callable(self, "find_path")])
	planner.declare_task_methods("do_close_door", [Callable(self, "do_close_door")])
	planner.declare_multigoal_methods([planner.m_split_multigoal])


func test_isekai_anime() -> void:
	planner.current_domain = the_domain

	var expected = [["walk", "Mia", "home_Mia", "park", 5], ["walk", "Mia", "park", "museum", 13], ["walk", "Mia", "museum", "zoo", 14], ["walk", "Mia", "zoo", "airport", 15], ["idle", "Mia", 59]]
	var result = planner.find_plan(state0.duplicate(true), [goal1])
	assert_eq_deep(result, expected)


func test_visit_all_the_doors() -> void:
	var door_goals = []
	for location in types["location"]:
		var task = ["travel", "Mia", location]
		gut.p(task)
		door_goals.append(task)
	var result = planner.find_plan(state0.duplicate(true), door_goals)
	assert_ne_deep(result, [])
	assert_ne_deep(result, false)


#func test_close_all_the_doors_as_plan():
#func test_close_all_the_doors():


func test_close_all_the_door_goal() -> void:
	var state1 = state0.duplicate(true)
	var goals = []
	for location in types["location"]:
		state1 = planner.run_lazy_lookahead(state1, [Multigoal.new("goal_%s" % location, {"door": {location: "closed"}, "time": {"Mia": 0}})])
	var is_doors_closed = true
	for location in types["location"]:
		gut.p("Location and door state: %s %s" % [location, state1["door"][location]])
		if state1["door"][location] != "closed":
			is_doors_closed = false
			gut.p("Door is still open: %s" % location)
	gut.p(state1["loc"])
	gut.p("What is Mia's time?: %s" % state1["time"]["Mia"])
	assert_true(is_doors_closed)
