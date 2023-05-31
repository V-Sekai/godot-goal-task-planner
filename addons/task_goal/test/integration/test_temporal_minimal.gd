extends GutTest


func test_propagate_constraints() -> void:
	var simple_temporal_network: SimpleTemporalNetwork = SimpleTemporalNetwork.new()
	# Add 10 game temporal constraints
	for i in range(1, 12):
		var game_task_name = "Game Task %d" % i
		var game_start_time = i * 10
		var game_duration = 10
		var game_task_constraints = TemporalConstraint.new(game_start_time, game_start_time + game_duration, game_duration, TemporalConstraint.TemporalQualifier.AT_END, game_task_name)
		simple_temporal_network.add_temporal_constraint(game_task_constraints)

	assert_eq(simple_temporal_network.is_consistent(), true, "Expected STN to be consistent after propagating constraints")
	
	var constrains_array = []
	for c in simple_temporal_network.constraints:
		var dictionary = c.to_dictionary()
		constrains_array.append(dictionary)
	print_rich(constrains_array)
	assert_eq_deep(constrains_array,  
[{ "resource_name": "Game Task 1", "time_interval": Vector2i(10, 20), "duration": 10, "temporal_qualifier": 1 }, { "resource_name": "Game Task 2", "time_interval": Vector2i(20, 30), "duration": 10, "temporal_qualifier": 1 }, { "resource_name": "Game Task 3", "time_interval": Vector2i(30, 40), "duration": 10, "temporal_qualifier": 1 }, { "resource_name": "Game Task 4", "time_interval": Vector2i(40, 50), "duration": 10, "temporal_qualifier": 1 }, { "resource_name": "Game Task 5", "time_interval": Vector2i(50, 60), "duration": 10, "temporal_qualifier": 1 }, { "resource_name": "Game Task 6", "time_interval": Vector2i(60, 70), "duration": 10, "temporal_qualifier": 1 }, { "resource_name": "Game Task 7", "time_interval": Vector2i(70, 80), "duration": 10, "temporal_qualifier": 1 }, { "resource_name": "Game Task 8", "time_interval": Vector2i(80, 90), "duration": 10, "temporal_qualifier": 1 }, { "resource_name": "Game Task 9", "time_interval": Vector2i(90, 100), "duration": 10, "temporal_qualifier": 1 }, { "resource_name": "Game Task 10", "time_interval": Vector2i(100, 110), "duration": 10, "temporal_qualifier": 1 }, { "resource_name": "Game Task 11", "time_interval": Vector2i(110, 120), "duration": 10, "temporal_qualifier": 1 }])
