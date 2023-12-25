# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_novel.gd
# SPDX-License-Identifier: MIT

extends GutTest

var the_domain = preload("res://goal_task_tests/domains/isekai_anime_domain.gd").new()

var planner = preload("res://addons/task_goal/core/plan.gd").new()

@export var state0: Dictionary = {"loc": {"Mia": "home_Mia", "Chair": "home_Mia", "Frank": "home_Frank", "car1": "cinema", "car2": "station"}, "cash": {"Mia": 30, "Frank": 35}, "owe": {"Mia": 0, "Frank": 0}, "time": {"Mia": 0, "Frank": 0, "Chair": 0}, "stn": {"Mia": SimpleTemporalNetwork.new(), "Frank": SimpleTemporalNetwork.new(), "Chair": SimpleTemporalNetwork.new()}, "door": {}}

# func fight(state, character, enemy):
# func interact(state, character, npc):
# func craft(state, character, item):
# func level_up(state, character):

var goal1 = Multigoal.new("goal1", {"loc": {"Mia": "airport"}, "time": {"Mia": 59}})

var goal2 = Multigoal.new("goal2", {"loc": {"Mia": "supermarket"}, "time": {"Mia": 15}})


func before_each() -> void:	
	planner.verbose = 0
	planner._domains.push_back(the_domain.duplicate(true))
	
	planner.current_domain = planner._domains.front()
	for location in planner.current_domain.types["location"]:
		state0["door"][location] = "opened"
	
	planner.declare_actions([Callable(planner.current_domain, "wait_for_everyone"), Callable(planner.current_domain, "close_door"), Callable(planner.current_domain, "walk"), Callable(planner.current_domain, "do_nothing"), Callable(planner.current_domain, "idle")])

	planner.declare_unigoal_methods("loc", [Callable(planner.current_domain, "travel_by_foot")])
	planner.declare_unigoal_methods("time", [Callable(planner.current_domain, "do_idle")])
	planner.declare_unigoal_methods("door", [Callable(planner.current_domain, "do_mia_close_door")])
	planner.declare_task_methods("travel", [Callable(planner.current_domain, "travel_by_foot"), Callable(planner.current_domain, "find_path")])
	planner.declare_task_methods("find_path", [Callable(planner.current_domain, "find_path")])
	planner.declare_task_methods("do_close_door", [Callable(planner.current_domain, "do_close_door")])
	planner.declare_multigoal_methods([planner.m_split_multigoal])


func test_visit_all_the_doors() -> void:
	var door_goals = []
	for location in the_domain.types["location"]:
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
	for location in planner.current_domain.types["location"]:
		state1 = planner.run_lazy_lookahead(state1, [Multigoal.new("goal_%s" % location, {"door": {location: "closed"}, "time": {"Mia": 0}})])
	var is_doors_closed = true
	for location in planner.current_domain.types["location"]:
		gut.p("Location and door state: %s %s" % [location, state1["door"][location]])
		if state1["door"][location] != "closed":
			is_doors_closed = false
			gut.p("Door is still open: %s" % location)
	gut.p(state1["loc"])
	gut.p("What is Mia's time?: %s" % state1["time"]["Mia"])
	assert_true(is_doors_closed)
