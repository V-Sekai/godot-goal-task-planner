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
	var initial_constraint = TemporalConstraint.new(0, 25, 25, TemporalConstraint.TemporalQualifier.OVERALL, "dummy constraint")
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
	var task_constraints = TemporalConstraint.new(start_time, start_time + duration, duration, TemporalConstraint.TemporalQualifier.OVERALL, task_name)

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
	var simple_temporal_network: SimpleTemporalNetwork = SimpleTemporalNetwork.new()
	var task_constraints_data = [
		{"task_name": "Task 2", "duration": 12},
		{"task_name": "Task 3", "duration": 15},
		{"task_name": "Task 4", "duration": 8},
	]

	for data in task_constraints_data:
		var task_constraints: TemporalConstraint = TemporalConstraint.new(0, 100, data.duration, TemporalConstraint.TemporalQualifier.AT_START, data.task_name)
		simple_temporal_network.add_temporal_constraint(task_constraints)

	print("STN after adding all constraints: %s" % str(simple_temporal_network.to_dictionary()))

	var constrains_array = []
	for c in simple_temporal_network.constraints:
		constrains_array.append(c.to_dictionary())
	print("STN constraints after adding task constraints: ", constrains_array)

	assert_eq_deep(constrains_array,  [{ "resource_name": "Task 2", "time_interval": Vector2i(0, 100), "duration": 12, "temporal_qualifier": 0 }, { "resource_name": "Task 3", "time_interval": Vector2i(0, 100), "duration": 15, "temporal_qualifier": 0 }, { "resource_name": "Task 4", "time_interval": Vector2i(0, 100), "duration": 8, "temporal_qualifier": 0 }]) 

