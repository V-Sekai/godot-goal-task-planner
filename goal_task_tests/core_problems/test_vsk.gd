# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_vsk.gd
# SPDX-License-Identifier: MIT

extends GutTest

## A simplified VR project planning example using the task_goal
## plugin framework for Godot. The goal is to create a plan for the
## VR development activities based on provided dependencies and durations.
var domain_name = "vr_project"
var the_domain = preload("res://addons/task_goal/core/domain.gd").new(domain_name)

var planner = preload("res://addons/task_goal/core/plan.gd").new()

@export var types = {
	"activity": [
		"finish",
		"implement_social_vr_functionality",
		"integrate_open_source_godot_engine",
		"setup_vr_environment",
		"design_3d_models",
		"create_textures",
		"develop_shaders",
		"program_game_logic",
		"write_scripts",
		"start",
		"fix_menu_toolbar_bug",
		"fix_ik_errors",
		"fix_physical_lighting_problems",
		"fix_player_movement_after_respawn",
		"restore_hand_movement_on_controller_interaction",
		"restore_voip",
		"fix_ui_dropdown_text_visibility",
		"fix_escape_button_freeze",
		"restore_mirror_in_preview_server",
		"fix_large_map_upload",
		"fix_logout_issue",
		"fix_finger_corruption",
		"fix_player_speech_stop",
		"load_avatars_after_loading_screen",
		"allow_login_from_map_and_avatar_list",
		"restore_grabbing_and_environmental_interactions",
		"fix_pause_menu_flow_disorientation",
		"fix_vr_menu",
		"fix_jumping"
	]
}

@export var dependencies: Dictionary = {
	"finish": ["implement_social_vr_functionality"],
	"implement_social_vr_functionality": ["integrate_open_source_godot_engine"],
	"integrate_open_source_godot_engine": ["setup_vr_environment"],
	"setup_vr_environment": ["design_3d_models", "create_textures", "develop_shaders"],
	"design_3d_models": ["write_scripts"],
	"create_textures": ["write_scripts"],
	"develop_shaders": ["write_scripts"],
	"program_game_logic": ["write_scripts"],
	"write_scripts": ["start"],
	"start": [],
	"fix_menu_toolbar_bug": ["start"],
	"fix_ik_errors": ["start"],
	"fix_physical_lighting_problems": ["start"],
	"fix_player_movement_after_respawn": ["start"],
	"restore_hand_movement_on_controller_interaction": ["start"],
	"restore_voip": ["start"],
	"fix_ui_dropdown_text_visibility": ["start"],
	"fix_escape_button_freeze": ["start"],
	"restore_mirror_in_preview_server": ["start"],
	"fix_large_map_upload": ["start"],
	"fix_logout_issue": ["start"],
	"fix_finger_corruption": ["start"],
	"fix_player_speech_stop": ["start"],
	"load_avatars_after_loading_screen": ["start"],
	"allow_login_from_map_and_avatar_list": ["start"],
	"restore_grabbing_and_environmental_interactions": ["start"],
	"fix_pause_menu_flow_disorientation": ["start"],
	"fix_vr_menu": ["start"],
	"fix_jumping": ["start"]
}


## Prototypical initial state, can include current progress, resources etc.
var state0: Dictionary = {
	"completed_activities": [],
	"pending_activities": types["activity"]  # Initial list from 'types'
}


## This function sets an activity as completed in the given state. 
## It removes the activity from pending activities and adds it to completed activities.
func set_as_completed(state, activity_name):
	if activity_name in state.pending_activities:
		state.pending_activities.erase(activity_name)
		state.completed_activities.append(activity_name)
	return state


## This function completes an activity in the given state if it is a pending activity.
func complete_activity(state, activity) -> Variant:
	if activity in state.pending_activities:
		return set_as_completed(state, activity)
	return false


## This function schedules an activity in the given state.
## It returns an array of actions needed to complete the activity and its dependencies.
func schedule_activity(state: Dictionary, activity: String) -> Variant:
	var actions = []
	
	if not activity in state["pending_activities"]:
		return false

	for predecessor in dependencies[activity]:
		if not predecessor in state["completed_activities"]:
			actions.push_back(["schedule_activity", predecessor])

	actions.append(["complete_activity", activity])
	
	return actions

## This function initializes the planner with the domain and declares the actions and task methods.
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


## This function tests the VR project planning by executing a single activity and asserting the plan.
func test_construction_planning() -> void:
	planner.current_domain = the_domain

	# Example: Executing a single activity
	var state1 = state0.duplicate(true)
	var goals = [["schedule_activity", "finish"]]
	var plan: Variant = planner.find_plan(state1, goals)

	# Assert that plan is not false and has a positive size
	assert_true(not plan is bool and plan.size() > 0)
	
	gut.p("Plan to finish:")
	if typeof(plan) == TYPE_ARRAY:
		for action in plan:
			gut.p("- %s" % str(action))
