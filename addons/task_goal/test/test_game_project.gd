# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# test_game_project.gd
# SPDX-License-Identifier: MIT

extends GutTest

func test_propagate_constraints() -> void:
	var simple_temporal_network: SimpleTemporalNetwork = SimpleTemporalNetwork.new()

	# Add 10 specific 3D game creation tasks
	var tasks = [
		"Model Character",
		"Create Environment",
		"Design Level",
		"Implement Gameplay Mechanics",
		"Animate Characters",
		"Add Sound Effects",
		"Optimize Performance",
		"Test and Debug",
		"Polish Game",
		"Publish Game"
	]

	for i in range(tasks.size()):
		var task_name = tasks[i]
		var task_duration = 10
		var task_start_time = i * task_duration # Set the start time for each task
		
		# Create a new temporal constraint using the task name, start time, duration, and AT_END qualifier
		var task_constraint = TemporalConstraint.new(task_start_time, task_start_time + task_duration, task_duration, TemporalConstraint.TemporalQualifier.AT_END, task_name)
		
		# Add the constraint to the simple temporal network
		simple_temporal_network.add_temporal_constraint(task_constraint)

	assert_eq(simple_temporal_network.is_consistent(), true, "Expected STN to be consistent after propagating constraints")

	var constraints_array = []
	for c in simple_temporal_network.constraints:
		if c == null:
			continue
		var dictionary = c.to_dictionary()
		constraints_array.append(dictionary)
	
	simple_temporal_network.propagate_constraints()
	
	print_rich(constraints_array)

	assert_eq_deep(constraints_array, [
		{ "resource_name": "Model Character", "time_interval": Vector2i(0, 10), "duration": 10, "temporal_qualifier": 1 },
		{ "resource_name": "Create Environment", "time_interval": Vector2i(10, 20), "duration": 10, "temporal_qualifier": 1 },
		{ "resource_name": "Design Level", "time_interval": Vector2i(20, 30), "duration": 10, "temporal_qualifier": 1 },
		{ "resource_name": "Implement Gameplay Mechanics", "time_interval": Vector2i(30, 40), "duration": 10, "temporal_qualifier": 1 },
		{ "resource_name": "Animate Characters", "time_interval": Vector2i(40, 50), "duration": 10, "temporal_qualifier": 1 },
		{ "resource_name": "Add Sound Effects", "time_interval": Vector2i(50, 60), "duration": 10, "temporal_qualifier": 1 },
		{ "resource_name": "Optimize Performance", "time_interval": Vector2i(60, 70), "duration": 10, "temporal_qualifier": 1 },
		{ "resource_name": "Test and Debug", "time_interval": Vector2i(70, 80), "duration": 10, "temporal_qualifier": 1 },
		{ "resource_name": "Polish Game", "time_interval": Vector2i(80, 90), "duration": 10, "temporal_qualifier": 1 },
		{ "resource_name": "Publish Game", "time_interval": Vector2i(90, 100), "duration": 10, "temporal_qualifier": 1 }
	])
