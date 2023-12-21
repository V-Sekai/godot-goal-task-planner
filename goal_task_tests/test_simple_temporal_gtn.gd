# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_simple_temporal_gtn.gd
# SPDX-License-Identifier: MIT

extends GutTest

var domain_name = "isekai_anime"
var the_domain = preload("res://addons/task_goal/core/domain.gd").new(domain_name)

var planner = preload("res://addons/task_goal/core/plan.gd").new()


func taxi_rate(taxi_dist):
	return 1.5 + 0.5 * taxi_dist


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
			print("idle error: Current time is greater than goal time")
			return false
		var _idle_time = goal_time - current_time
		var constraint_name = "%s_idle_until_%s" % [person, goal_time]
		var constraint = TemporalConstraint.new(current_time, goal_time, _idle_time, TemporalConstraint.TemporalQualifier.AT_END, constraint_name)
		if planner.current_domain.stn.add_temporal_constraint(constraint):
			print("idle called")
			state["time"][person] = goal_time
			return state
		else:
			if state.verbose > 0:
				print("idle error: Failed to add temporal constraint %s" % constraint.to_dictionary())
	

func do_idle(state, person, goal_time):
	if is_a(person, "character"):
		if goal_time >= state["time"][person]:
			return [["idle", person, goal_time]]


func walk(state, p, x, y, goal_time):
	if is_a(p, "character") and is_a(x, "location") and is_a(y, "location") and x != y:
		if state.loc[p] == x:
			var current_time = state.time[p]
			if current_time < goal_time:
				current_time = goal_time
			var _travel_time = travel_time(x, y, "foot")
			var arrival_time = goal_time + _travel_time
			var constraint_name = "%s_walk_from_%s_to_%s" % [p, x, y]
			var constraint = TemporalConstraint.new(current_time, arrival_time, goal_time, TemporalConstraint.TemporalQualifier.AT_END, constraint_name)
			if planner.current_domain.stn.add_temporal_constraint(constraint):
				print("walk called")
				state.loc[p] = y
				state["time"][p] = arrival_time
				return state
			else:
				if state.verbose > 0:
					print("walk error: Failed to add temporal constraint %s" % constraint.to_dictionary())


func call_car(state, p, x, goal_time):
	if is_a(p, "character") and is_a(x, "location"):
		var current_time = state.time[p]
		if current_time < goal_time:
			current_time = goal_time
		var _travel_time = 1
		var arrival_time = goal_time + _travel_time
		var constraint_name = "%s_call_car_at_%s" % [p, x]
		var constraint = TemporalConstraint.new(current_time, arrival_time, goal_time, TemporalConstraint.TemporalQualifier.AT_END, constraint_name)
		if planner.current_domain.stn.add_temporal_constraint(constraint):
			for car in types["vehicle"]:
				state.loc[car] = x
				state.loc[p] = car
				state["time"][p] = arrival_time
				return state
			print("call_car error: No available cars at location.")
			return state
		else:
			print("call_car error: Failed to add temporal constraint %s" % constraint.to_dictionary())


func ride_car(state, p, y, goal_time):
	if is_a(p, "character") and is_a(state.loc[p], "vehicle") and is_a(y, "location"):
		var car = state.loc[p]
		var x = state.loc[car]
		if is_a(x, "location") and x != y:
			var _travel_time = travel_time(x, y, "car")
			var current_time = state.time[p]
			if current_time < goal_time :
				current_time = goal_time 
			var arrival_time = goal_time + _travel_time
			var constraint_name = "%s_ride_car_from_%s_to_%s" % [p, x, y]
			var constraint = TemporalConstraint.new(current_time, arrival_time, goal_time, TemporalConstraint.TemporalQualifier.AT_END, constraint_name)
			if planner.current_domain.stn.add_temporal_constraint(constraint):
				state.loc[car] = y
				state.owe[p] = taxi_rate(distance(x, y))
				state["time"][p] = arrival_time
				return state


func pay_driver(state, p, y, goal_time):
	if is_a(p, "character"):
		if state.cash[p] >= state.owe[p]:
			var payment_time = 1  # Assuming payment takes no time
			var current_time = state.time[p]
			# Ensure the payment starts after the ride
			if current_time < goal_time:
				current_time = goal_time
			var post_payment_time = current_time + payment_time
			var constraint_name = "%s_pay_driver_at_%s" % [p, y]
			var constraint = TemporalConstraint.new(current_time, post_payment_time, payment_time, TemporalConstraint.TemporalQualifier.AT_END, constraint_name)
			if planner.current_domain.stn.add_temporal_constraint(constraint):
				state.cash[p] = state.cash[p] - state.owe[p]
				state.owe[p] = 0
				state.loc[p] = y
				state["time"][p] = post_payment_time
				return state
			else:
				print("Constraint: ", constraint)
				print("Current STN: ", planner.current_domain.stn)
				print("Temporal constraint could not be added")
				return false


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


func travel_by_foot(state, p, y):
	if is_a(p, "character") and is_a(y, "location"):
		var x = state.loc[p]
		var goal_time = state.time[p] + travel_time(x, y, "foot")
		# print("Travel time: %s" % goal_time)
		if x != y and distance(x, y) <= 2 and goal_time <= 100:
			return [["walk", p, x, y, goal_time]]


func travel_by_car(state, p, y):
	if is_a(p, "character") and is_a(y, "location"):
		var x = state.loc[p]
		if x != y and state.cash[p] >= taxi_rate(distance(x, y)):
			var call_car_goal_time = state.time[p] + 1 # Assuming calling a car takes 1 unit of time
			var ride_car_goal_time = call_car_goal_time + travel_time(x, y, "car")
			var actions = [["call_car", p, x, call_car_goal_time], ["ride_car", p, y, ride_car_goal_time]]
			if actions[0][0] == "call_car" and actions[1][0] == "ride_car":
				var pay_driver_goal_time = ride_car_goal_time + 1 # Assuming payment takes 1 unit of time
				actions.append(["pay_driver", p, y, pay_driver_goal_time])
			return actions


@export var types = {
	"character": ["Mia", "Frank"],
	"location": ["home_Mia", "home_Frank", "cinema", "station", "mall"],
	"vehicle": ["car1", "car2"],
}

@export var dist: Dictionary = {
	["home_Mia", "cinema"]: 12,
	["home_Frank", "cinema"]: 4,
	["station", "home_Mia"]: 1,
	["station", "home_Frank"]: 10,
	["home_Mia", "home_Frank"]: 10,
	["station", "cinema"]: 12,
	["home_Mia", "mall"]: 8,
	["home_Frank", "mall"]: 10,
	["mall", "cinema"]: 7,
}

var state0: Dictionary = {"loc": {"Mia": "home_Mia", "Frank": "home_Frank", "car1": "cinema", "car2": "station"}, "cash": {"Mia": 20, "Frank": 15}, "owe": {"Mia": 0, "Frank": 0}, "time": {"Mia": 0, "Frank": 0}}

var goal2 = Multigoal.new("goal2", {"loc": {"Mia": "mall", "Frank": "mall"}})

var goal3 = Multigoal.new("goal3", {"loc": {"Mia": "cinema", "Frank": "cinema"}, "time": {"Mia": 19, "Frank": 19}})


func before_each():
	planner.verbose = 1
	planner._domains.push_back(the_domain)
	planner.current_domain = the_domain
	planner.declare_actions([Callable(self, "walk"), Callable(self, "call_car"), Callable(self, "ride_car"), Callable(self, "pay_driver"), Callable(self, "do_nothing"), Callable(self, "idle")])

	planner.declare_unigoal_methods("loc", [Callable(self, "travel_by_foot"), Callable(self, "travel_by_car")])
	planner.declare_task_methods("travel", [Callable(self, "travel_by_foot"), Callable(self, "travel_by_car")])
	planner.declare_unigoal_methods("time", [Callable(self, "do_idle")])
	planner.declare_multigoal_methods([planner.m_split_multigoal])


func test_isekai_anime():
	planner.current_domain = the_domain

	var expected = [["call_car", "Mia", "home_Mia", 1], ["ride_car", "Mia", "mall", 2], ["pay_driver", "Mia", "mall", 3]]
	var result = planner.find_plan(state0.duplicate(true), [["travel", "Mia", "mall"]])
	assert_eq_deep(result, expected)

	var state1 = state0.duplicate(true)
	var plan = planner.find_plan(state1, [goal2, goal3])

	assert_eq_deep(plan, 
		[["call_car", "Mia", "home_Mia", 1], ["ride_car", "Mia", "mall", 2], ["pay_driver", "Mia", "mall", 3], ["call_car", "Frank", "home_Frank", 1], ["ride_car", "Frank", "mall", 3], ["pay_driver", "Frank", "mall", 4], ["call_car", "Mia", "mall", 5], ["ride_car", "Mia", "cinema", 6], ["pay_driver", "Mia", "cinema", 7], ["call_car", "Frank", "mall", 7], ["ride_car", "Frank", "cinema", 8], ["pay_driver", "Frank", "cinema", 9], ["idle", "Mia", 19], ["idle", "Frank", 19]]
	)
