# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_vr_community.gd
# SPDX-License-Identifier: MIT

extends GutTest
"""
 A simplified example using the task_goal plugin framework for Godot
 demonstrating the planning of activities involved in running a VR social
 network like V-Sekai.
"""

var domain_name = "vr_community_management"
var the_domain = preload("res://addons/task_goal/core/domain.gd").new(domain_name)

var planner = preload("res://addons/task_goal/core/plan.gd").new()

# Types used for validation if necessary
@export var types = {
	"activity": [
		"initialize_virtual_environment",
		"design_avatar_customization_options",
		"implement_communication_systems",
		"create_social_gathering_areas",
		"develop_mini_games",
		"set_up_event_scheduling",
		"integrate_user_content_sharing",
		"establish_community_guidelines",
		"launch_public_beta_test",
		"collect_beta_feedback",
		"improve_based_on_feedback",
		"finalize_platform_polishing",
		"prepare_marketing_campaign",
		"launch_full_platform",
		"monitor_platform_stability",
		"update_with_new_features",
		"finish"
	]
}

# Dependency graph for the activities
@export var dependencies: Dictionary = {
	"initialize_virtual_environment": [],
	"design_avatar_customization_options": ["initialize_virtual_environment"],
	"implement_communication_systems": ["initialize_virtual_environment"],
	"create_social_gathering_areas": ["implement_communication_systems"],
	"develop_mini_games": ["create_social_gathering_areas", "design_avatar_customization_options"],
	"set_up_event_scheduling": ["create_social_gathering_areas"],
	"integrate_user_content_sharing": ["implement_communication_systems"],
	"establish_community_guidelines": ["initialize_virtual_environment"],
	"launch_public_beta_test": ["develop_mini_games", "establish_community_guidelines"],
	"collect_beta_feedback": ["launch_public_beta_test"],
	"improve_based_on_feedback": ["collect_beta_feedback"],
	"finalize_platform_polishing": ["improve_based_on_feedback"],
	"prepare_marketing_campaign": ["finalize_platform_polishing"],
	"launch_full_platform": ["prepare_marketing_campaign"],
	"monitor_platform_stability": ["launch_full_platform"],
	"update_with_new_features": ["monitor_platform_stability"],
	"finish": [
		"update_with_new_features",
		"launch_full_platform"
	]
}

# Prototypical initial state, can include current progress, resources etc.
var state0: Dictionary = {
	# Example state properties
	"completed_activities": [],
	"pending_activities": types["activity"]  # Initial list from 'types'
}

# Helper functions:

func set_as_completed(state, activity_name):
	if activity_name in state.pending_activities:
		state.pending_activities.erase(activity_name)
		state.completed_activities.append(activity_name)
	return state


## Actions:

func complete_activity(state, activity) -> Variant:
	if activity in state.pending_activities:
		return set_as_completed(state, activity)
	return false


## Methods:

func schedule_activity(state: Dictionary, activity: String) -> Array:
	var actions = []

	if not activity in state["pending_activities"]:
		return []

	for predecessor in dependencies[activity]:
		if not predecessor in state["completed_activities"]:
			actions.push_back(["schedule_activity", predecessor])

	actions.append(["complete_activity", activity])

	return actions


func _ready() -> void:
	planner.domains.push_back(the_domain)
	planner.current_domain = the_domain
	planner.declare_actions([Callable(self, "complete_activity")])
	planner.declare_task_methods(
		"schedule_activity",
		[
			Callable(self, "schedule_activity"),
		]
	)

func test_vr_community_planning() -> void:
	planner.current_domain = the_domain

	# Example: Executing a single activity
	var state1 = state0.duplicate(true)
	var goals = [["schedule_activity", "finish"]]
	var plan: Variant = planner.find_plan(state1, goals)

	# Assert that plan is not false and has a positive size
	assert_true( not plan is bool and plan.size() > 0)

	gut.p("Plan to finish:")
	if typeof(plan) == TYPE_ARRAY:
		for action in plan:
			gut.p("- %s" % str(action))
