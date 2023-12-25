# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_anime.gd
# SPDX-License-Identifier: MIT

extends GutTest


# Brainstorm and sketch out what you want your avatar to look like. Consider things like body proportions, clothing, and accessories. 
# Create a 3D model of your avatar using software like Blender. Add textures to give your avatar color and detail. 
# This is done using software like Krita. 
# Add bones to your model so it can move. This is usually done in the same software as the modeling. 

var the_domain = preload("res://goal_task_tests/domains/anime_domain.gd").new()

var planner = null

func before_each():
	planner = preload("res://addons/task_goal/core/plan.gd").new()
	planner.verbose = 0
	var new_domain = the_domain.duplicate(true)
	planner._domains.push_back(new_domain)
	planner.current_domain = new_domain
	
	planner.declare_multigoal_methods([planner.m_split_multigoal])	
	#planner.declare_actions([Callable(planner.current_domain, "use_move")])
	#planner.declare_unigoal_methods("loc", [Callable(planner.current_domain, "travel_by_foot")])
	#planner.declare_task_methods("travel", [Callable(planner.current_domain, "travel_by_foot")])

func test_create_existing_avatar():
	planner.verbose = 0
	var state0: Dictionary = {"time": {}, "stn": {}}
	state0.avatar = {}
	state0.avatar["Nova"] = "rigged"
	var state1 = state0.duplicate(true)
	var expected = [] 
	var result = planner.find_plan(state1, [Multigoal.new("Create an avatar", { "avatar": {"Nova": "rigged"}})])
	assert_eq_deep(result, expected)
