# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_simple_nine_squares.gd
# SPDX-License-Identifier: MIT

extends GutTest

var domain_name = "isekai_anime"
var the_domain = preload("res://addons/task_goal/core/domain.gd").new(domain_name)

var planner = preload("res://addons/task_goal/core/plan.gd").new()


func distance(x: String, y: String):
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


func is_a(variable, type):
	return variable in types[type]


func idle(state, person, goal_time):
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


func do_idle(state, person, goal_time):
	if is_a(person, "character"):
		if the_domain.verbose > 0:
			print("Current time for %s: %s" % [person, state["time"][person]])
			print("Goal time: %s" % goal_time)
		if goal_time < state["time"][person]:			
			if the_domain.verbose > 0:
				print("Warning: Goal time is in the past. Adjusting goal time.")
			goal_time = state["time"][person]
		if goal_time >= state["time"][person]:
			return [["idle", person, goal_time]]
		else:
			if the_domain.verbose > 0:
				print("Error: Goal time is less than current time: %s" % goal_time)
				

func walk(state, p, x, y, goal_time):
	if is_a(p, "character") and is_a(x, "location") and is_a(y, "location") and x != y:
		if state.loc[p] == x:
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
			print("walk error: Character is not at the expected location %s" % state.loc)
			

func travel_time(x, y, mode):
	var _distance = distance(x, y)
	if mode == "foot":
		return _distance / 1
	elif mode == "car":
		return _distance / 5
	else:
		print("Error: Invalid mode of transportation")
		return -1

		
func do_nothing(state, p, y):
	if is_a(p, "character"):
		state["time"][p] += y
		return []


func travel_by_foot(state, p, destination):
	if is_a(p, "character") and is_a(destination, "location"):
		var current_location = state.loc[p]
		if current_location == destination:
			return [["idle", p, state["time"][p]]]
		var path = find_path(state, p, destination)
		if path.size() > 0:
			return path
	return []


var memo = {}

func find_path(state, p, destination):
	var current_location = state["loc"][p]
	var stack = [[current_location, [], 0]] # Initialize stack with current location, empty path and total time as 0
	memo = {}

	while len(stack) > 0:
		var top = stack.pop_back() # In DFS, we use a stack and pop the last element
		var new_current_location = top[0]
		var path = top[1]
		var total_time = top[2]

		if new_current_location == destination:
			return path

		if new_current_location in memo:
			continue

		memo[new_current_location] = true

		for loc in types["location"]:
			if loc == new_current_location or distance(new_current_location, loc) == INF:
				continue
			var travel_time_to_loc = travel_time(new_current_location, loc, "foot")
			var goal_time = total_time + travel_time_to_loc
			if goal_time < INF and not path_has_location(path, loc):
				var new_path = path.duplicate()
				new_path.append(["walk", p, new_current_location, loc, goal_time])
				stack.append([loc, new_path, goal_time])

	return []



func compare_goal_times(a, b):
	return a[1] > b[1]


func path_has_location(path, location):
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
	"character": ["Mia", "Frank"],
	"location": ["home_Mia", "home_Frank", "cinema", "station", "mall", "park", "restaurant", "school", "office", "gym", "library", "hospital", "beach", "supermarket", "museum", "zoo", "airport"],
	"vehicle": ["car1", "car2"],
	"owe": [],
	"stn": [],
}


@export var dist: Dictionary = {
	["home_Mia", "cinema"]: 12,
	["cinema", "home_Mia"]: 12,
	["home_Frank", "cinema"]: 4,
	["cinema", "home_Frank"]: 4,
	["station", "home_Mia"]: 1,
	["station", "home_Frank"]: 10,
	["station", "cinema"]: 12,
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

var state0: Dictionary = {"loc": {"Mia": "home_Mia", "Frank": "home_Frank", "car1": "cinema", "car2": "station"}, "cash": {"Mia": 30, "Frank": 35}, "owe": {"Mia": 0, "Frank": 0}, "time": {"Mia": 0, "Frank": 0}, "stn": {"Mia": SimpleTemporalNetwork.new(), "Frank": SimpleTemporalNetwork.new()}}

var goal1 = Multigoal.new("goal1", {"loc": {"Mia": "supermarket"}, "time": {"Mia": 127 }})

var goal2 = Multigoal.new("goal2", {"loc": {"Mia": "supermarket"}, "time": {"Mia": 15 }})

func before_each():
	planner.verbose = 0
	planner._domains.push_back(the_domain)
	planner.current_domain = the_domain
	planner.declare_actions([Callable(self, "wait_for_everyone"), Callable(self, "walk"), Callable(self, "do_nothing"), Callable(self, "idle"), Callable(self, "find_path")])

	planner.declare_unigoal_methods("loc", [Callable(self, "travel_by_foot"), Callable(self, "find_path")])
	planner.declare_unigoal_methods("time", [Callable(self, "do_idle")])
	planner.declare_task_methods("travel", [Callable(self, "travel_by_foot"), Callable(self, "find_path")])
	planner.declare_multigoal_methods([planner.m_split_multigoal])
	

func test_isekai_anime():
	planner.verbose = 3
	planner.current_domain = the_domain

	var expected =  [["walk", "Mia", "home_Mia", "park", 5], ["walk", "Mia", "park", "museum", 18], ["walk", "Mia", "museum", "zoo", 32], ["walk", "Mia", "zoo", "airport", 47], ["walk", "Mia", "airport", "home_Frank", 64], ["walk", "Mia", "home_Frank", "hospital", 84], ["walk", "Mia", "hospital", "beach", 95], ["walk", "Mia", "beach", "supermarket", 107]]
	var result = planner.find_plan(state0.duplicate(true), [goal1])
	assert_eq_deep(result, expected)


func generate_random_plan():
	var shuffled_state: Dictionary = {"loc": {}, "time": {}}

	var loc_keys = state0["loc"].keys()
	var travel_destinations = []
	for key in loc_keys:
		if is_a(key, "character"):
			var possible_values = types["location"]
			possible_values.shuffle()
			# Ensure the character does not stay at home
			if possible_values[0] == state0["loc"][key]:
				possible_values.remove_at(0)
			shuffled_state["loc"][key] = possible_values[0]
			shuffled_state["time"][key] = 100
			gut.p("Goal %s" % shuffled_state)
			break
	travel_destinations.push_back(Multigoal.new("goal1", shuffled_state))
	return travel_destinations
	
	
func test_random_plans():
	planner.verbose = 0
	randomize()
	var result = []
	for i in range(100):
		var plan = generate_random_plan()
		var temp_result = planner.find_plan(state0.duplicate(true), plan)
		if not temp_result is bool and temp_result.size():
			result.append(temp_result)
		else: 
			break
	gut.p("Result: %s" % str(result))
	assert_ne_deep(result, [])
	assert_ne_deep(result, false)
