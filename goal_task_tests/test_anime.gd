# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_anime.gd
# SPDX-License-Identifier: MIT

extends GutTest

var the_domain = preload("res://goal_task_tests/domains/isekai_anime_domain.gd").new()

var planner = preload("res://addons/task_goal/core/plan.gd").new()

var state0: Dictionary = {"loc": {"Mia": "home_Mia", "Frank": "home_Frank", "car1": "cinema", "car2": "station"}, "cash": {"Mia": 30, "Frank": 35}, "owe": {"Mia": 0, "Frank": 0}, "time": {"Mia": 0, "Frank": 0}, "stn": {"Mia": SimpleTemporalNetwork.new(), "Frank": SimpleTemporalNetwork.new()}}

var goal2 = Multigoal.new("goal2", {"loc": {"Mia": "mall", "Frank": "mall"}})

var goal3 = Multigoal.new("goal3", {"loc": {"Mia": "cinema", "Frank": "cinema"}, "time": {"Mia": 15, "Frank": 15}})

var goal4 = Multigoal.new("goal4", {"loc": {"Mia": "home_Mia", "Frank": "home_Mia"}, "time": {"Mia": 25, "Frank": 25}})


func before_each():
	planner.verbose = 0
	planner._domains.push_back(the_domain)
	planner.current_domain = the_domain
	planner.declare_actions([Callable(the_domain, "walk"), Callable(the_domain, "call_car"), Callable(the_domain, "ride_car"), Callable(the_domain, "pay_driver"), Callable(the_domain, "do_nothing"), Callable(the_domain, "idle")])

	planner.declare_unigoal_methods("loc", [Callable(the_domain, "travel_by_foot"), Callable(the_domain, "travel_by_car")])
	planner.declare_task_methods("travel", [Callable(the_domain, "travel_by_foot"), Callable(the_domain, "travel_by_car")])
	planner.declare_unigoal_methods("time", [Callable(the_domain, "do_idle")])
	planner.declare_multigoal_methods([planner.m_split_multigoal])


func test_isekai_anime_01():
	planner.current_domain = the_domain

	var expected = [["call_car", "Mia", "home_Mia", 1], ["ride_car", "Mia", "mall", 2], ["pay_driver", "Mia", "mall", 3]]
	var result = planner.find_plan(state0.duplicate(true), [["travel", "Mia", "mall"]])
	assert_eq_deep(result, expected)


func test_isekai_anime_02():
	var state1 = state0.duplicate(true)
	var plan = planner.find_plan(state1, [goal2, goal3, goal4])

	assert_eq_deep(plan, [["call_car", "Mia", "home_Mia", 1], ["ride_car", "Mia", "mall", 2], ["pay_driver", "Mia", "mall", 3], ["call_car", "Frank", "home_Frank", 1], ["ride_car", "Frank", "mall", 3], ["pay_driver", "Frank", "mall", 4], ["call_car", "Mia", "mall", 5], ["ride_car", "Mia", "cinema", 6], ["pay_driver", "Mia", "cinema", 7], ["call_car", "Frank", "mall", 7], ["ride_car", "Frank", "cinema", 8], ["pay_driver", "Frank", "cinema", 9], ["idle", "Mia", 15], ["idle", "Frank", 15], ["call_car", "Mia", "cinema", 16], ["ride_car", "Mia", "home_Mia", 18], ["pay_driver", "Mia", "home_Mia", 19], ["call_car", "Frank", "cinema", 16], ["ride_car", "Frank", "home_Mia", 18], ["pay_driver", "Frank", "home_Mia", 19], ["idle", "Mia", 25], ["idle", "Frank", 25]])
