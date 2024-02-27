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
		"Understand the project requirements",
		"Research on latest VR interaction trends",
		"Define the scope of the VR interaction system",
		"Sketch initial designs for the VR interaction system",
		"Review and refine initial sketches",
		"Develop wireframes for the VR interaction system",
		"Review and refine wireframes",
		"Create detailed mockups for the VR interaction system",
		"Review and refine mockups",
		"Create user flow diagrams for the VR interaction system",
		"Review and refine user flow diagrams",
		"Develop a prototype of the VR interaction system",
		"Test the prototype and make necessary adjustments",
		"Conduct a final review of the design",
		"Prepare design handoff for development team"
	]
}


@export var dependencies: Dictionary = {
	"Understand the project requirements": [],
	"Research on latest VR interaction trends": ["Understand the project requirements"],
	"Define the scope of the VR interaction system": ["Research on latest VR interaction trends"],
	"Sketch initial designs for the VR interaction system": ["Define the scope of the VR interaction system"],
	"Review and refine initial sketches": ["Sketch initial designs for the VR interaction system"],
	"Develop wireframes for the VR interaction system": ["Review and refine initial sketches"],
	"Review and refine wireframes": ["Develop wireframes for the VR interaction system"],
	"Create detailed mockups for the VR interaction system": ["Review and refine wireframes"],
	"Review and refine mockups": ["Create detailed mockups for the VR interaction system"],
	"Create user flow diagrams for the VR interaction system": ["Review and refine mockups"],
	"Review and refine user flow diagrams": ["Create user flow diagrams for the VR interaction system"],
	"Develop a prototype of the VR interaction system": ["Review and refine user flow diagrams"],
	"Test the prototype and make necessary adjustments": ["Develop a prototype of the VR interaction system"],
	"Conduct a final review of the design": ["Test the prototype and make necessary adjustments"],
	"Prepare design handoff for development team": ["Conduct a final review of the design"]
}


## Prototypical initial state, can include current progress, resources etc.
var state0: Dictionary = {
	"completed_activities": [],
	"pending_activities": types["activity"]
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
		return []

	if activity in dependencies:
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
func test_vsk_planning() -> void:
	planner.current_domain = the_domain

	# Example: Executing all activities
	var state1 = state0.duplicate(true)
	var goals = []
	for activity in types["activity"]:
		goals.append(["schedule_activity", activity])
	
	RandomNumberGenerator.new().seed = 12345
	goals.shuffle()
	
	var plan: Variant = planner.find_plan(state1, goals)

	# Assert that plan is not false and has a positive size
	assert_true(not plan is bool and plan.size() > 0)

	gut.p("Plan to finish:")
	if typeof(plan) == TYPE_ARRAY:
		for action in plan:
			gut.p("- %s" % str(action))
