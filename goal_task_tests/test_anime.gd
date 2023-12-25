# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_anime.gd
# SPDX-License-Identifier: MIT

extends GutTest

var the_domain = preload("res://goal_task_tests/domains/anime_domain.gd").new()

var planner = null

func before_each():
	planner = preload("res://addons/task_goal/core/plan.gd").new()
	var new_domain = the_domain.duplicate(true)
	planner._domains.push_back(new_domain)
	planner.current_domain = new_domain
	planner.declare_actions([Callable(planner.current_domain, "walk"), Callable(planner.current_domain, "close_door"), Callable(planner.current_domain, "call_car"), Callable(planner.current_domain, "do_nothing"), Callable(planner.current_domain, "ride_car"), Callable(planner.current_domain, "pay_driver"), Callable(planner.current_domain, "do_nothing"), Callable(planner.current_domain, "idle"), Callable(planner.current_domain, "wait_for_everyone")])
	planner.declare_unigoal_methods("loc", [Callable(planner.current_domain, "travel_by_foot"), Callable(planner.current_domain, "travel_by_car")])
	planner.declare_task_methods("travel", [Callable(planner.current_domain, "travel_by_foot"), Callable(planner.current_domain, "travel_by_car"), Callable(planner.current_domain, "find_path")])
	planner.declare_unigoal_methods("time", [Callable(planner.current_domain, "do_idle")])
	planner.declare_multigoal_methods([planner.m_split_multigoal])	
	planner.declare_unigoal_methods("door", [Callable(planner.current_domain, "do_mia_close_door")])
	planner.declare_task_methods("find_path", [Callable(planner.current_domain, "find_path")])
	planner.declare_task_methods("do_close_door", [Callable(planner.current_domain, "do_close_door")])
	planner.declare_multigoal_methods([planner.m_split_multigoal])

func test_walk():
	var state0: Dictionary = {"loc": {"Mia": "home_Mia", "Chair": "home_Mia", "Frank": "home_Frank", "car1": "cinema", "car2": "station"}, "cash": {"Mia": 30, "Frank": 35}, "owe": {"Mia": 0, "Frank": 0}, "time": {"Mia": 0, "Frank": 0}, "stn": {"Mia": SimpleTemporalNetwork.new(), "Frank": SimpleTemporalNetwork.new(), "Chair": SimpleTemporalNetwork.new()}, "door": {}}
	var state1 = state0.duplicate(true)
	var expected = [["walk", "Mia", "home_Mia", "mall", 8]] 
	var result = planner.find_plan(state1, [["walk", "Mia", "home_Mia", "mall", 8]])
	assert_eq_deep(result, expected)
	assert_eq(state1["time"]["Mia"], 8)
	assert_eq(state1["loc"]["Mia"], "mall")


func test_find_path():
	var state0: Dictionary = {"loc": {"Mia": "home_Mia", "Chair": "home_Mia", "Frank": "home_Frank", "car1": "cinema", "car2": "station"}, "cash": {"Mia": 30, "Frank": 35}, "owe": {"Mia": 0, "Frank": 0}, "time": {"Mia": 0, "Frank": 0}, "stn": {"Mia": SimpleTemporalNetwork.new(), "Frank": SimpleTemporalNetwork.new(), "Chair": SimpleTemporalNetwork.new()}, "door": {}}
	var expected = [["walk", "Mia", "home_Mia", "mall", 8]] 
	var result = planner.find_plan(state0.duplicate(true), [["find_path", "Mia", "mall"]])
	assert_eq_deep(result, expected)
	
func test_find_path_next_node():
	planner.verbose = 2
	var state0: Dictionary = {"loc": {"Mia": "home_Mia", "Chair": "home_Mia", "Frank": "home_Frank", "car1": "cinema", "car2": "station"}, "cash": {"Mia": 30, "Frank": 35}, "owe": {"Mia": 0, "Frank": 0}, "time": {"Mia": 0, "Frank": 0}, "stn": {"Mia": SimpleTemporalNetwork.new(), "Frank": SimpleTemporalNetwork.new(), "Chair": SimpleTemporalNetwork.new()}, "door": {}}
	var expected = [["walk", "Mia", "home_Mia", "park", 5], ["walk", "Mia", "park", "museum", 13], ["walk", "Mia", "museum", "zoo", 14], ["walk", "Mia", "zoo", "airport", 15]]
	var result = planner.find_plan(state0, [["find_path", "Mia", "airport"]])
	assert_eq_deep(result, expected)
	assert_eq(state0["time"]["Mia"], 15)
	assert_eq(state0["loc"]["Mia"], "airport")
	
	
func test_isekai_anime_01():
	var state0: Dictionary = {"loc": {"Mia": "home_Mia", "Chair": "home_Mia", "Frank": "home_Frank", "car1": "cinema", "car2": "station"}, "cash": {"Mia": 30, "Frank": 35}, "owe": {"Mia": 0, "Frank": 0}, "time": {"Mia": 0, "Frank": 0}, "stn": {"Mia": SimpleTemporalNetwork.new(), "Frank": SimpleTemporalNetwork.new(), "Chair": SimpleTemporalNetwork.new()}, "door": {}}
	var expected = [["walk", "Mia", "home_Mia", "mall", 8]]
	var result = planner.find_plan(state0.duplicate(true), [["travel", "Mia", "mall"]])
	assert_eq_deep(result, expected)


func test_isekai_anime_02_fixme():
	var state0: Dictionary = {"loc": {"Mia": "home_Mia", "Chair": "home_Mia", "Frank": "home_Frank", "car1": "cinema", "car2": "station"}, "cash": {"Mia": 30, "Frank": 35}, "owe": {"Mia": 0, "Frank": 0}, "time": {"Mia": 0, "Frank": 0}, "stn": {"Mia": SimpleTemporalNetwork.new(), "Frank": SimpleTemporalNetwork.new(), "Chair": SimpleTemporalNetwork.new()}, "door": {}}
	var goal2 = Multigoal.new("goal2", {"loc": {"Mia": "mall", "Frank": "mall"}})
	var goal3 = Multigoal.new("goal3", {"loc": {"Mia": "cinema", "Frank": "cinema"}, "time": {"Mia": 15, "Frank": 15}})
	var goal4 = Multigoal.new("goal4", {"loc": {"Mia": "home_Mia", "Frank": "home_Mia"}, "time": {"Mia": 25, "Frank": 25}})
	var plan = planner.find_plan(state0.duplicate(true), [goal2, goal3, goal4])
	assert_ne_deep(plan, [["walk", "Mia", "home_Mia", "mall", 8], ["walk", "Frank", "home_Frank", "mall", 10], ["walk", "Mia", "mall", "cinema", 7], ["walk", "Frank", "mall", "cinema", 7], ["idle", "Mia", 15], ["idle", "Frank", 15], ["walk", "Mia", "cinema", "home_Mia", 12], ["walk", "Frank", "cinema", "home_Mia", 12], ["idle", "Mia", 25], ["idle", "Frank", 25]])


func test_visit_all_the_doors_fixme() -> void:
	var state0: Dictionary = {"loc": {"Mia": "home_Mia", "Chair": "home_Mia", "Frank": "home_Frank", "car1": "cinema", "car2": "station"}, "cash": {"Mia": 30, "Frank": 35}, "owe": {"Mia": 0, "Frank": 0}, "time": {"Mia": 0, "Frank": 0}, "stn": {"Mia": SimpleTemporalNetwork.new(), "Frank": SimpleTemporalNetwork.new(), "Chair": SimpleTemporalNetwork.new()}, "door": {}}
	var door_goals = []
	for location in the_domain.types["location"]:
		var task = ["travel", "Mia", location]
		gut.p(task)
		door_goals.append(task)
	var result = planner.find_plan(state0, door_goals)
	assert_ne_deep(result, [])
	assert_eq_deep(result, false)


func test_close_all_the_door_goal_fixme() -> void:
	var state0: Dictionary = {"loc": {"Mia": "home_Mia", "Chair": "home_Mia", "Frank": "home_Frank", "car1": "cinema", "car2": "station"}, "cash": {"Mia": 30, "Frank": 35}, "owe": {"Mia": 0, "Frank": 0}, "time": {"Mia": 0, "Frank": 0}, "stn": {"Mia": SimpleTemporalNetwork.new(), "Frank": SimpleTemporalNetwork.new(), "Chair": SimpleTemporalNetwork.new()}, "door": {}}
	var state1 = state0.duplicate(true)	
	for location in planner.current_domain.types["location"]:
		state1["door"][location] = "opened"
	for location in planner.current_domain.types["location"]:
		state1 = planner.run_lazy_lookahead(state1, [Multigoal.new("goal_%s" % location, {"door": {location: "closed"}, "time": {"Mia": 200}})])
	var is_doors_closed = true
	for location in planner.current_domain.types["location"]:
		gut.p("Location and door state: %s %s" % [location, state1["door"][location]])
		if state1["door"][location] != "closed":
			is_doors_closed = false
			gut.p("Door is still open: %s" % location)
	gut.p(state1["loc"])
	gut.p("What is Mia's time?: %s" % state1["time"]["Mia"])
	assert_false(is_doors_closed)
