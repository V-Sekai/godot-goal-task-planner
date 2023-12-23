# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_simple_temporal_visual_novel.gd
# SPDX-License-Identifier: MIT

extends GutTest

var domain_name = "isekai_litrpg"
var the_domain = preload("res://addons/task_goal/core/domain.gd").new(domain_name)

var planner = preload("res://addons/task_goal/core/plan.gd").new()

var stn = SimpleTemporalNetwork.new()

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


func walk(state, p, x, y, goal_time):
	if is_a(p, "character") and is_a(x, "location") and is_a(y, "location") and x != y:
		if state.loc[p] == x:
			var current_time = state.time[p]
			var _travel_time = travel_time(x, y, "foot")
			if current_time + _travel_time > goal_time:
				if the_domain.verbose > 0:
					print("walk error: Arrival time exceeds goal time")
				return false
			var arrival_time = goal_time
			var constraint_name = "%s_walk_from_%s_to_%s" % [p, x, y]
			var constraint = TemporalConstraint.new(current_time, arrival_time, _travel_time, TemporalConstraint.TemporalQualifier.AT_END, constraint_name)
			if stn.add_temporal_constraint(constraint):
				state.loc[p] = y
				state["time"][p] = arrival_time
				return state
			else:
				if state.verbose > 0:
					print("walk error: Failed to add temporal constraint %s" % constraint.to_dictionary())


func travel_time(x, y, mode):
	var _distance = distance(x, y)
	if mode == "foot":
		return _distance / 1
	elif mode == "car":
		return _distance / 5
	else:
		print("Error: Invalid mode of transportation")
		return -1


func idle(state, person, goal_time):
	if is_a(person, "character"):
		var current_time = state["time"][person]
		if current_time > goal_time:
			print("idle error: Current time is greater than goal time")
			return false
		var _idle_time = goal_time - current_time
		var constraint_name = "%s_idle_until_%s" % [person, goal_time]
		var constraint = TemporalConstraint.new(current_time, goal_time, _idle_time, TemporalConstraint.TemporalQualifier.AT_END, constraint_name)
		if stn.add_temporal_constraint(constraint):
			state["time"][person] = goal_time
			return state
		else:
			if state.verbose > 0:
				print("idle error: Failed to add temporal constraint %s" % constraint.to_dictionary())
	

func do_idle(state, person, goal_time):
	if is_a(person, "character"):
		if goal_time >= state["time"][person]:
			return [["idle", person, goal_time]]


func travel_by_foot(state, p, y):
	if is_a(p, "character") and is_a(y, "location"):
		var x = state.loc[p]
		var _travel_time = travel_time(x, y, "foot")
		if the_domain.verbose > 0:
			print("Travel time from ", x, " to ", y, ": ", _travel_time)
		if x != y:
			var goal_time = state.time[p] + _travel_time
			if the_domain.verbose > 0:
				print("Goal time for ", p, " to reach ", y, ": ", goal_time)
			return [["walk", p, x, y, goal_time]]


func wait_for_everyone(state, persons):
	var max_time = 0
	for person in persons:
		if not is_a(person, "character"):
			return false
		var time = state.time[person]  # Get the time for each person
		if time > max_time:
			max_time = time  # Update the maximum time

		# Have everyone do nothing until the slowest person arrives
	for person in persons:
		var time = max_time - state.time[person]
		if time > 0:
			state.time[person] += time
	return state


@export var types = {
	"character": ["Hero", "Villain"],
	"location": ["HomeTown", "Dungeon_01", "MarketPlace", "Guild", "BossRoom"],
}

@export var dist: Dictionary = {
	["HomeTown", "Dungeon_01"]: 12,
	["HomeTown", "MarketPlace"]: 4,
	["Guild", "HomeTown"]: 1,
	["Guild", "Dungeon_01"]: 10,
	["HomeTown", "Guild"]: 10,
	["MarketPlace", "Guild"]: 10,
	["Guild", "MarketPlace"]: 12,
	["HomeTown", "BossRoom"]: 8,
	["Dungeon_01", "BossRoom"]: 10,
	["BossRoom", "MarketPlace"]: 7,
}

var state0: Dictionary = {"loc": {"Hero": "HomeTown", "Villain": "Dungeon_01"}, "cash": {"Hero": 20, "Villain": 15}, "owe": {"Hero": 0, "Villain": 0}, "time": {"Hero": 0, "Villain": 0}}

var goal1: Multigoal = Multigoal.new("goal1", {"loc": {"Hero": "MarketPlace"}, "time": {"Hero":  20}})

var goal2: Multigoal = Multigoal.new("goal2", {"loc": {"Hero": "Guild"}, "time": {"Hero": 30}})

var goal3: Multigoal = Multigoal.new("goal3", {"loc": {"Hero": "Dungeon_01"}, "time": {"Hero": 44}})

var goal4: Multigoal = Multigoal.new("goal4", {"loc": {"Hero": "BossRoom"}, "time": {"Hero": 54}})

var goal5: Multigoal = Multigoal.new("goal5", {"loc": {"Hero": "MarketPlace"}, "time": {"Hero": 61}})


func before_each():
	planner.verbose = 0
	planner._domains.push_back(the_domain)
	planner.current_domain = the_domain
	planner.declare_actions([Callable(self, "wait_for_everyone"), Callable(self, "walk"), Callable(self, "idle")])

	planner.declare_unigoal_methods("loc", [Callable(self, "travel_by_foot")])
	planner.declare_unigoal_methods("time", [Callable(self, "do_idle")])

	planner.declare_multigoal_methods([planner.m_split_multigoal])


func test_isekai_litrpg():
	planner.current_domain = the_domain

	var expected = [["walk", "Hero", "HomeTown", "MarketPlace", 4], ["idle", "Hero", 20], ["walk", "Hero", "MarketPlace", "Guild", 30], ["walk", "Hero", "Guild", "Dungeon_01", 40], ["idle", "Hero", 44], ["walk", "Hero", "Dungeon_01", "BossRoom", 54], ["walk", "Hero", "BossRoom", "MarketPlace", 61]]
	var result = planner.find_plan(state0.duplicate(true), [goal1, goal2, goal3, goal4, goal5])
	assert_eq_deep(result, expected)
