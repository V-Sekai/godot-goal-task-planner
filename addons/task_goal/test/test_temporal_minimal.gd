# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# test_temporal_minimal.gd
# SPDX-License-Identifier: MIT

extends GutTest

func test_propagate_project_constraints() -> void:
	var simple_temporal_network: SimpleTemporalNetwork = SimpleTemporalNetwork.new()
	
	# Add 10 game temporal constraints
	for i in range(1, 5):
		var game_task_name = "Game Task %d" % i
		var game_start_time = i * 50
		var game_duration = 10
		var game_task_constraints = TemporalConstraint.new(game_start_time, game_start_time + game_duration, game_duration, TemporalConstraint.TemporalQualifier.AT_END, game_task_name)
		simple_temporal_network.add_temporal_constraint(game_task_constraints)

	assert_eq(simple_temporal_network.is_consistent(), true, "Expected STN to be consistent after propagating constraints")
	
	var constraints_array = []
	for c in simple_temporal_network.constraints:
		var dictionary = c.to_dictionary()
		constraints_array.append(dictionary)
	print_rich(constraints_array)
	
	assert_eq_deep(constraints_array, [
		{ "resource_name": "Game Task 1", "time_interval": Vector2i(50, 60), "duration": 10, "temporal_qualifier": 1 },
		{ "resource_name": "Game Task 2", "time_interval": Vector2i(100, 110), "duration": 10, "temporal_qualifier": 1 },
		{ "resource_name": "Game Task 3", "time_interval": Vector2i(150, 160), "duration": 10, "temporal_qualifier": 1 },
		{ "resource_name": "Game Task 4", "time_interval": Vector2i(200, 210), "duration": 10, "temporal_qualifier": 1 },
	])
