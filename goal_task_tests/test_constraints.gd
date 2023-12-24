# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_constraints.gd
# SPDX-License-Identifier: MIT

extends "res://addons/gut/test.gd"

var stn = null


func before_each():
	stn = SimpleTemporalNetwork.new()


func test_is_consistent_with_no_constraints():
	assert_true(stn.is_consistent(), "An empty STN should be consistent")


func test_is_consistent_with_one_constraint():
	var constraint = TemporalConstraint.new(0, 10, 5, TemporalConstraint.TemporalQualifier.AT_START, "some_resource")
	stn.add_temporal_constraint(constraint)
	assert_true(stn.is_consistent(), "An STN with one constraint should be consistent")


func test_is_consistent_with_inconsistent_constraints():
	var constraint1 = TemporalConstraint.new(0, 10, 5, TemporalConstraint.TemporalQualifier.AT_START, "resource1")
	var constraint2 = TemporalConstraint.new(5, 15, 10, TemporalConstraint.TemporalQualifier.AT_START, "resource2")
	stn.add_temporal_constraint(constraint1)
	stn.add_temporal_constraint(constraint2)
	assert_false(stn.is_consistent(), "An STN with overlapping constraints should not be consistent")
