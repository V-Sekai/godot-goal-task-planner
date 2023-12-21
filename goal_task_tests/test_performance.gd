# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_performance.gd
# SPDX-License-Identifier: MIT

extends "res://addons/gut/test.gd"

var stn: SimpleTemporalNetwork = null


func before_each():
	stn = SimpleTemporalNetwork.new()


func test_performance_with_large_number_of_constraints():
	var start_time = Time.get_ticks_msec()

	for i in range(197):
		var from_constraint = TemporalConstraint.new(i, i+10, 5, TemporalConstraint.TemporalQualifier.AT_START, "from" + str(i))
		var to_constraint = TemporalConstraint.new(i+11, i+21, 5, TemporalConstraint.TemporalQualifier.AT_END, "to" + str(i))

		# Add constraints and propagate them.
		stn.add_temporal_constraint(from_constraint, to_constraint, 0, 10)
	stn.propagate_constraints()
	assert_true(stn.is_consistent(), "Consistency test failed: STN should be consistent")
	var end_time = Time.get_ticks_msec()
	var time_taken = end_time - start_time
	gut.p("Time taken for 1000 constraints: " + str(time_taken) + " ms")
	assert_true(time_taken >= 1000, "Performance test failed: Time taken should be slower than 1 second")
	
