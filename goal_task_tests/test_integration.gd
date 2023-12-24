# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_integration.gd
# SPDX-License-Identifier: MIT

extends GutTest

## Test visual novel planner

var domain_name = "romantic"

## Preload and instantiate the domain and planner scripts
var the_domain = preload("res://addons/task_goal/core/domain.gd").new(domain_name)
var planner = preload("res://addons/task_goal/core/plan.gd").new()

## Function to travel to a location
func travel_location(state, entity, location) -> Dictionary:
	state.at[entity] = location
	return state

## Method for traveling to a location
func m_travel_location(state, entity, location) -> Variant:
	if entity in state.entities and location in state.locations and state.at[entity] != location:
		return [["travel_location", entity, location]]
	return false

## Check if two entities have met at a place
func has_entity_met_entity(_state: Dictionary, e_1: String, e_2, place: String) -> Variant:
	return [Multigoal.new("entities_together", {"at": {e_1: place, e_2: place}})]

## Initial state
var state1: Dictionary

## Setup function to be run before each test
func before_each() -> void:
	# Add the domain to the planner's domains
	planner._domains.push_back(the_domain)

	# Set the current domain to the_domain
	planner.current_domain = the_domain

	# Declare actions and methods
	planner.declare_actions([Callable(self, "travel_location")])
	planner.declare_task_methods("entity_met_entity", [Callable(self, "has_entity_met_entity")])
	planner.declare_unigoal_methods("at", [Callable(self, "m_travel_location")])
	planner.declare_multigoal_methods([planner.m_split_multigoal])

	# Initialize the state
	state1.locations = ["coffee_shop", "home", "groceries"]
	state1.entities = ["seb", "mia"]
	state1.at = {"seb": "home", "mia": "groceries"}

## Test function to check if the goal of being together is achieved
func test_together_goal() -> void:
	var plan = planner.find_plan(state1.duplicate(true), [["entity_met_entity", "seb", "mia", "coffee_shop"]])
	assert_eq(plan, [["travel_location", "seb", "coffee_shop"], ["travel_location", "mia", "coffee_shop"]], "")
