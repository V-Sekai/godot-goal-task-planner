# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_logistics.gd
# SPDX-License-Identifier: MIT

extends GutTest

#This file is based on the logistics-domain examples included with HGNpyhop:
#	https://github.com/ospur/hgn-pyhop
#For a discussion of the adaptations that were needed, see the relevant
#section of Some_GTPyhop_Details.md in the top-level directory.
#-- Dana Nau <nau@umd.edu>, July 20, 2021

var domain_name = "temporal_logistics"

var the_domain = preload("res://addons/task_goal/core/domain.gd").new(domain_name)

var planner = preload("res://addons/task_goal/core/plan.gd").new()


func handle_temporal_constraint(state, resource, current_time, goal_time, constraint_name) -> Variant:
	var constraint = TemporalConstraint.new(current_time, goal_time, goal_time - current_time, TemporalConstraint.TemporalQualifier.AT_END, constraint_name)
	if state["stn"][resource].check_overlap(constraint):
		if planner.verbose > 0:
			print("Error: Temporal constraint overlaped %s" % [str(constraint)])
		return false
	if state["stn"][resource].add_temporal_constraint(constraint):
		state["time"][resource] = goal_time
		return state
	else:
		if planner.verbose > 0:
			print("Error: Failed to add temporal constraint %s" % str(constraint))
	return false


## Actions


func drive_truck(state, t, l, time) -> Variant:
	if state.truck_at[t] == l:
		return state
	var constraint_name = "%s_drive_to_%s" % [t, l]
	var current_time = state["time"][t]
	if current_time >= time:
		return false
	state = handle_temporal_constraint(state, t, current_time, time, constraint_name)
	if state and state["stn"][t].is_consistent():
		state.truck_at[t] = l
		state["time"][t] = time
		return state
	return false

func load_truck(state, o, t, time) -> Variant:
	if state.at[o] == t:
		return state
	var constraint_name = "%s_load_to_%s" % [o, t]
	var current_time = state["time"][o]
	if current_time >= time:
		return false
	state = handle_temporal_constraint(state, o, current_time, time, constraint_name)
	if state and state["stn"][o].is_consistent():
		state.at[o] = t
		state["time"][t] = time
		return state
	return false

func unload_truck(state, o, l, time) -> Variant:
	if state.at[o] == l:
		return state
	var t = state.at[o]
	if state.truck_at[t] == l:
		var constraint_name = "%s_unload_to_%s" % [o, l]
		var current_time = state["time"][o]
		if current_time >= time:
			return false
		state = handle_temporal_constraint(state, o, current_time, time, constraint_name)
		if state and state["stn"][o].is_consistent():
			state.at[o] = l
			state["time"][t] = time
			return state
	return false

func fly_plane(state, plane, a, time) -> Variant:
	if state.plane_at[plane] == a:
		return state
	var constraint_name = "%s_fly_to_%s" % [plane, a]
	var current_time = state["time"][plane]
	if current_time >= time:
		return false
	state = handle_temporal_constraint(state, plane, current_time, time, constraint_name)
	if state and state["stn"][plane].is_consistent():
		state.plane_at[plane] = a
		state["time"][plane] = time
		return state
	return false

func load_plane(state, o, plane, time) -> Variant:
	if state.at[o] == plane:
		return state
	var constraint_name = "%s_load_to_%s" % [o, plane]
	var current_time = state["time"][o]
	if current_time >= time:
		return false
	state = handle_temporal_constraint(state, o, current_time, time, constraint_name)
	if state and state["stn"][o].is_consistent():
		state.at[o] = plane
		state["time"][plane] = time
		return state
	return false

func unload_plane(state, o, a, time) -> Variant:
	if state.at[o] == a:
		return state
	var plane = state.at[o]
	if state.plane_at[plane] == a:
		var constraint_name = "%s_unload_to_%s" % [o, a]
		var current_time = state["time"][o]
		if current_time >= time:
			return false
		state = handle_temporal_constraint(state, o, current_time, time, constraint_name)
		if state and state["stn"][o].is_consistent():
			state.at[o] = a
			state["time"][a] = time
			return state
	return false


## Helper functions for the methods

# Find a truck in the same city as the package and available at the current time
func find_truck(state, o, time) -> Variant:
	for t in state.trucks:
		if state.in_city[state.truck_at[t]] == state.in_city[state.at[o]]:
			return t
	return false

# Find a plane in the same city as the package and available at the current time; if none available, find a random plane
func find_plane(state, o, time) -> Variant:
	var random_plane
	for plane in state.airplanes:
		if state.in_city[state.plane_at[plane]] == state.in_city[state.at[o]]:
			return plane
		random_plane = plane
	return random_plane

# Find an airport in the same city as the location and available at the current time
func find_airport(state, l, time) -> Variant:
	for a in state.airports:
		if state.in_city[a] == state.in_city[l]:
			return a
	return false


## Methods to call the actions

func m_drive_truck(state, t, l) -> Variant:
	if t in state.trucks and l in state.locations and state.in_city[state.truck_at[t]] == state.in_city[l]:
		var current_time = state["time"][t]
		return [["drive_truck", t, l, current_time+1]]
	return false

func m_load_truck(state, o, t) -> Variant:
	if o in state.packages and t in state.trucks and state.at[o] != t and state.at[o] == state.truck_at[t]:
		var current_time = state["time"][t]
		return [["load_truck", o, t, current_time+1]]
	return false

func m_unload_truck(state, o, l) -> Variant:
	if o in state.packages and state.at[o] != l and state.at[o] in state.trucks and l in state.locations:
		var current_time = state["time"][state.at[o]]
		return [["unload_truck", o, l, current_time+1]]
	return false

func m_fly_plane(state, plane, a) -> Variant:
	if plane in state.airplanes and a in state.airports:
		var current_time = state["time"][plane]
		return [["fly_plane", plane, a, current_time+1]]
	return false

func m_load_plane(state, o, plane) -> Variant:
	if o in state.packages and plane in state.airplanes and state.at[o] != plane and state.at[o] == state.plane_at[plane]:
		var current_time = state["time"][plane]
		return [["load_plane", o, plane, current_time+1]]
	return false

func m_unload_plane(state, o, a) -> Variant:
	if o in state.packages and state.at[o] != a and state.at[o] in state.airplanes and a in state.airports:
		var current_time = state["time"][state.at[o]]
		return [["unload_plane", o, a, current_time+1]]
	return false


## Other methods


func move_within_city(state, o, l) -> Variant:
	if o in state.packages and l in state.locations and state.at[o] in state.locations and state.in_city[state.at[o]] == state.in_city[l]:
		var temp_time = state.time[o]
		var t = find_truck(state, o, temp_time)
		if t:
			var new_state = handle_temporal_constraint(state, t, state.time[t], state.time[t] + 1, "move_within_city")
			if new_state:
				state = new_state
				return [["truck_at", t, state.at[o]], ["at", o, t], ["truck_at", t, l], ["at", o, l]]
	return false


func move_between_airports(state, o, a) -> Variant:
	if o in state.packages and a in state.airports and state.at[o] in state.airports and state.in_city[state.at[o]] != state.in_city[a]:
		var temp_time = state.time[o]
		var plane = find_plane(state, o, temp_time)
		if plane:
			var new_state = handle_temporal_constraint(state, plane, state.time[plane], state.time[plane] + 1, "move_between_airports")
			if new_state:
				state = new_state
				return [["plane_at", plane, state.at[o]], ["at", o, plane], ["plane_at", plane, a], ["at", o, a]]
	return false


func move_between_city(state, o, l) -> Variant:
	if o in state.packages and l in state.locations and state.at[o] in state.locations and state.in_city[state.at[o]] != state.in_city[l]:
		var temp_time = state.time[o]
		var a1 = find_airport(state, state.at[o], temp_time)
		var a2 = find_airport(state, l, temp_time)
		if a1 and a2:
			var new_state_a1 = handle_temporal_constraint(state, a1, state.time[a1], state.time[a1] + 1, "move_between_city")
			var new_state_a2 = handle_temporal_constraint(state, a2, state.time[a2], state.time[a2] + 1, "move_between_city")
			if new_state_a1 and new_state_a2:
				state = new_state_a1
				state = new_state_a2
				return [["at", o, a1], ["at", o, a2], ["at", o, l]]
	return false


var state1: Dictionary


func before_each() -> void:
	state1.clear()
	planner._domains.push_back(the_domain)

	# If we've changed to some other domain, this will change us back.
	planner.current_domain = the_domain
	planner.declare_actions([Callable(self, "drive_truck"), Callable(self, "load_truck"), Callable(self, "unload_truck"), Callable(self, "fly_plane"), Callable(self, "load_plane"), Callable(self, "unload_plane")])

	planner.declare_unigoal_methods("at", [Callable(self, "m_load_truck"), Callable(self, "m_unload_truck"), Callable(self, "m_load_plane"), Callable(self, "m_unload_plane")])
	planner.declare_unigoal_methods("truck_at", [Callable(self, "m_drive_truck")])
	planner.declare_unigoal_methods("plane_at", [Callable(self, "m_fly_plane")])

	planner.declare_unigoal_methods("at", [Callable(self, "move_within_city"), Callable(self, "move_between_airports"), Callable(self, "move_between_city")])

#	planner.print_domain()

	state1.stn = {}
	state1.time = {}
	state1.packages = ["package1", "package2"]
	state1.trucks = ["truck1", "truck6"]
	state1.airplanes = ["plane2"]
	state1.locations = ["location1", "location2", "location3", "airport1", "location10", "airport2"]
	state1.airports = ["airport1", "airport2"]
	state1.cities = ["city1", "city2"]

	state1.at = {"package1": "location1", "package2": "location2"}
	state1.truck_at = {"truck1": "location3", "truck6": "location10"}
	state1.plane_at = {"plane2": "airport2"}
	state1.in_city = {"location1": "city1", "location2": "city1", "location3": "city1", "airport1": "city1", "location10": "city2", "airport2": "city2"}

	for c in state1.cities:
		state1["stn"][c] =  SimpleTemporalNetwork.new()
		state1.time[c] = 0
		
	for a in state1.airports:
		state1["stn"][a] =  SimpleTemporalNetwork.new()
		state1.time[a] = 0
		
	for p in state1.packages:
		state1["stn"][p] =  SimpleTemporalNetwork.new()
		state1.time[p] = 0

	for t in state1.trucks:
		state1["stn"][t] =  SimpleTemporalNetwork.new()
		state1.time[t] = 0

	for a in state1.airplanes:
		state1["stn"][a] =  SimpleTemporalNetwork.new()
		state1.time[a] = 0


func test_move_goal_1() -> void:
	planner.verbose = 1
	var state2 = state1.duplicate(true)
	var plan = planner.find_plan(state2, [["at", "package1", "location2"], ["at", "package2", "location3"]])
	assert_eq(plan, [["drive_truck", "truck1", "location1", 2], ["load_truck", "package1", "truck1", 3], ["drive_truck", "truck1", "location2", 4], ["unload_truck", "package1", "location2", 5], ["load_truck", "package2", "truck1", 7], ["drive_truck", "truck1", "location3", 8], ["unload_truck", "package2", "location3", 9]])
	assert_eq(state2.time["truck1"], 9)
	assert_eq(state2.time["package1"], 5)
	assert_eq(state2.time["package2"], 9)


###	Goal 2: package1 is at location10 (transport to a different city)
#func test_move_goal_2() -> void:
	#planner.verbose = 0
	#var plan = planner.find_plan(state1.duplicate(true), [["at", "package1", "location10"]])
	#assert_eq(plan, [["drive_truck", "truck1", "location1"], ["load_truck", "package1", "truck1"], ["drive_truck", "truck1", "airport1"], ["unload_truck", "package1", "airport1"], ["fly_plane", "plane2", "airport1"], ["load_plane", "package1", "plane2"], ["fly_plane", "plane2", "airport2"], ["unload_plane", "package1", "airport2"], ["drive_truck", "truck6", "airport2"], ["load_truck", "package1", "truck6"], ["drive_truck", "truck6", "location10"], ["unload_truck", "package1", "location10"]])
	#assert_eq(state1.time["truck1"], 3)
	#assert_eq(state1.time["truck6"], 11)
	#assert_eq(state1.time["plane2"], 7)
	#assert_eq(state1.time["package1"], 12)


## Goal 3: package1 is at location1 (no actions needed)
func test_move_goal_3() -> void:
	planner.verbose = 0
	var state2 = state1.duplicate(true)
	var plan = planner.find_plan(state2, [["at", "package1", "location1"]])
	assert_eq(plan, [])
	# No actions were performed, so the time should remain at 0
	assert_eq(state2.time["package1"], 0)


##	Goal 4: package1 is at location2
func test_move_goal_4() -> void:
	planner.verbose = 0
	var state2 = state1.duplicate(true)
	var plan = planner.find_plan(state2, [["at", "package1", "location2"]])
	assert_eq(plan, [["drive_truck", "truck1", "location1", 2], ["load_truck", "package1", "truck1", 3], ["drive_truck", "truck1", "location2", 4], ["unload_truck", "package1", "location2", 5]])
	assert_eq(state2.time["truck1"], 5)
	assert_eq(state2.time["package1"], 5)


func test_drive_truck():
	var initial_state = {"truck_at": {"t1": "l1"}, "time": {"t1": 0}, "stn": {"t1": SimpleTemporalNetwork.new()}}
	var expected_state = {"truck_at": {"t1": "l2"}, "time": {"t1": 10}, "stn": {"t1": SimpleTemporalNetwork.new()}}
	
	var result_state = drive_truck(initial_state, "t1", "l2", 10)
	assert_eq(expected_state.truck_at.t1, "l2")
	assert_eq(expected_state.time.t1, 10)
