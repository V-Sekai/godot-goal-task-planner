# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_integration.gd
# SPDX-License-Identifier: MIT

extends GutTest

## Preload and instantiate the domain and planner scripts
var the_domain = preload("res://goal_task_tests/domains/isekai_anime_domain.gd").new()
var planner = preload("res://addons/task_goal/core/plan.gd").new()
var state0: Dictionary

## Setup function to be run before each test
func before_each() -> void:
	# Add the domain to the planner's domains
	planner._domains.push_back(the_domain)

	# Set the current domain to the_domain
	planner.current_domain = planner._domains.front()

	# Declare actions and methods
	planner.declare_actions([Callable(the_domain, "travel_location")])
	planner.declare_task_methods("entity_met_entity", [Callable(the_domain, "has_entity_met_entity")])
	planner.declare_unigoal_methods("at", [Callable(the_domain, "m_travel_location")])
	planner.declare_multigoal_methods([planner.m_split_multigoal])

	# Initialize the state
	state0.locations = ["coffee_shop", "home", "groceries"]
	state0.entities = ["seb", "mia"]
	state0.at = {"seb": "home", "mia": "groceries"}

## Test function to check if the goal of being together is achieved
func test_together_goal() -> void:
	var plan = planner.find_plan(state0.duplicate(true), [["entity_met_entity", "seb", "mia", "coffee_shop"]])
	assert_eq(plan, [["travel_location", "seb", "coffee_shop"], ["travel_location", "mia", "coffee_shop"]], "")
