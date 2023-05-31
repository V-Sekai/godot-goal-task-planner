extends GutTest

func _validate_task_constraints(simple_temporal_network, task_name: String, start_time: int, duration: int) -> void:
	var task_constraints_added = false
	for constraint in simple_temporal_network.constraints:
		if constraint.resource_name == task_name:
			task_constraints_added = true
			break

	assert_true(simple_temporal_network.constraints.size() > 0, "Constraints: %d" % simple_temporal_network.constraints.size())
	assert_true(task_constraints_added, "Expected task constraints to be added to STN")

	var constraint_task_name = simple_temporal_network.get_temporal_constraint_by_name(task_name)

	if constraint_task_name:
		var propagated_duration = constraint_task_name.duration
		assert_eq(propagated_duration, duration, "Expected duration to be propagated correctly")

		var temporal_constraint : TemporalConstraint = simple_temporal_network.get_temporal_constraint_by_name(task_name)
		var propagated_start_time = temporal_constraint.time_interval.x
		assert_eq(propagated_start_time, start_time, "Expected start time to be propagated correctly")

	assert_eq(simple_temporal_network.is_consistent(), true, "Expected STN to be consistent after propagating constraints")


func _create_resource_with_initial_constraint() -> SimpleTemporalNetwork:
	var simple_temporal_network: SimpleTemporalNetwork = SimpleTemporalNetwork.new()
	var initial_constraint = TemporalConstraint.new(0, 25, TemporalConstraint.TemporalQualifier.OVERALL, "dummy constraint")
	simple_temporal_network.add_temporal_constraint(initial_constraint)

	print("Initial constraint: ", initial_constraint.to_dictionary())
	for c in simple_temporal_network.constraints:
		print("STN constraints after adding initial constraint: ", c.to_dictionary())

	return simple_temporal_network


func test_propagate_constraints() -> void:
	var simple_temporal_network = _create_resource_with_initial_constraint()

	var task_name = "Task 1"
	var start_time = 5
	var duration = 10
	var task_constraints = TemporalConstraint.new(start_time, duration, TemporalConstraint.TemporalQualifier.OVERALL, task_name)

	print("Task constraints: %s" % task_constraints.to_dictionary())

	print("STN before adding initial constraint: %s" % str(simple_temporal_network.to_dictionary()))
	simple_temporal_network.add_temporal_constraint(task_constraints)
	print("STN after adding initial constraint: %s" % str(simple_temporal_network.to_dictionary()))

	var constrains_array = []
	for c in simple_temporal_network.constraints:
		constrains_array.append(c.to_dictionary())
	print("STN constraints after adding task constraints: ", constrains_array)
	constrains_array.clear()

	_validate_task_constraints(simple_temporal_network, task_name, start_time, duration)

	for c in simple_temporal_network.constraints:
		constrains_array.append(c.to_dictionary())
	assert_eq_deep(constrains_array, [
		{ "resource_name": "dummy constraint", "time_interval": Vector2i(0, 25), "duration": 25, "temporal_qualifier": 2},
		{ "resource_name": "Task 1", "time_interval": Vector2i(5, 15), "duration": 10, "temporal_qualifier": 2}]
	)


func test_propagate_constraints_variation_1() -> void:
	var simple_temporal_network = _create_resource_with_initial_constraint()

	var task_constraints_data = [
		{"task_name": "Task 2", "start_time": 8, "duration": 12},
		{"task_name": "Task 3", "start_time": 5, "duration": 15},
		{"task_name": "Task 4", "start_time": 10, "duration": 8},
		{"task_name": "Task 5", "start_time": 3, "duration": 20},
		{"task_name": "Task 6", "start_time": 7, "duration": 14},
		{"task_name": "Task 7", "start_time": 12, "duration": 10},
		{"task_name": "Task 8", "start_time": 9, "duration": 11},
		{"task_name": "Task 9", "start_time": 6, "duration": 13},
		{"task_name": "Task 10", "start_time": 4, "duration": 18},
		{"task_name": "Task 11", "start_time": 11, "duration": 9}
	]

	for data in task_constraints_data:
		var task_constraints: TemporalConstraint = TemporalConstraint.new(data.start_time, data.duration, TemporalConstraint.TemporalQualifier.OVERALL, data.task_name)
		simple_temporal_network.add_temporal_constraint(task_constraints)

	print("STN after adding all constraints: %s" % str(simple_temporal_network.to_dictionary()))

	var constrains_array = []
	for c in simple_temporal_network.constraints:
		constrains_array.append(c.to_dictionary())
	print("STN constraints after adding task constraints: ", constrains_array)

	assert_eq_deep(constrains_array, [{ "resource_name": "dummy constraint", "time_interval": Vector2i(0, 25), "duration": 25, "temporal_qualifier": 2 }, { "resource_name": "Task 2", "time_interval": Vector2i(8, 20), "duration": 12, "temporal_qualifier": 2 }, { "resource_name": "Task 3", "time_interval": Vector2i(5, 20), "duration": 15, "temporal_qualifier": 2 }, { "resource_name": "Task 4", "time_interval": Vector2i(10, 18), "duration": 8, "temporal_qualifier": 2 }, { "resource_name": "Task 5", "time_interval": Vector2i(3, 23), "duration": 20, "temporal_qualifier": 2 }, { "resource_name": "Task 6", "time_interval": Vector2i(7, 21), "duration": 14, "temporal_qualifier": 2 }, { "resource_name": "Task 7", "time_interval": Vector2i(12, 22), "duration": 10, "temporal_qualifier": 2 }, { "resource_name": "Task 8", "time_interval": Vector2i(9, 20), "duration": 11, "temporal_qualifier": 2 }, { "resource_name": "Task 9", "time_interval": Vector2i(6, 19), "duration": 13, "temporal_qualifier": 2 }, { "resource_name": "Task 10", "time_interval": Vector2i(4, 22), "duration": 18, "temporal_qualifier": 2 }, { "resource_name": "Task 11", "time_interval": Vector2i(11, 20), "duration": 9, "temporal_qualifier": 2 }])
