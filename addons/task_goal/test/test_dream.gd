# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# test_dream.gd
# SPDX-License-Identifier: MIT

func reserve_practice_room(state, time_interval: TemporalConstraint, stn: SimpleTemporalNetwork) -> Variant:
	# Update the state to show that the practice room is reserved
	state['shared_resource']['practice_room'] = 'reserved'
	state['task_status']['reserve_room'] = 'done'
	# Add the time interval to the STN and propagate the constraints
	stn.update_state({"practice": time_interval})
	if not stn.is_consistent():
		return false
	return []


func attend_audition(state, time_interval: TemporalConstraint, stn: SimpleTemporalNetwork) -> Variant:
	# Update the state to show that the audition has been attended
	state['task_status']['audition'] = 'attended'
	# Add the time interval to the STN and propagate the constraints
	stn.update_state({"audition": time_interval})
	if not stn.propagate_constraints():
		return false
	return []


func practice_craft(state, time_interval: TemporalConstraint, stn: SimpleTemporalNetwork) -> Variant:
	# Update the state to show that the practice has been done
	state['task_status']['practice'] = 'done'
	# Add the time interval to the STN and propagate the constraints
	stn.update_state({"craft": time_interval})
	if not stn.propagate_constraints():
		return false
	return []


func network(state, time_interval: TemporalConstraint, stn: SimpleTemporalNetwork) -> Variant:
	# Update the state to show that networking has been done
	state['task_status']['networking'] = 'done'
	# Add the time interval to the STN and propagate the constraints
	stn.update_state({"network": time_interval})
	if not stn.propagate_constraints():
		return false
	return []


func get_possible_dream_time_intervals(stn: SimpleTemporalNetwork) -> Array[TemporalConstraint]:
	# Determine the minimum and maximum possible start times
	var min_start = INF
	var max_start = 0
	for constraint in stn.constraints:
		var start = constraint.time_interval.x
		if start < min_start:
			min_start = start
		if start > max_start:
			max_start = start

	# Generate all possible time intervals within the minimum and maximum start times
	var time_intervals : Array[TemporalConstraint] = []
	for start_time in range(min_start, max_start + 1):
		var end_time = start_time + 24
		var time_interval = TemporalConstraint.new(start_time, end_time, end_time - start_time, TemporalConstraint.TemporalQualifier.OVERALL, "")
		if stn.is_valid_constraint(time_interval):
			time_intervals.append(time_interval)

	return time_intervals


