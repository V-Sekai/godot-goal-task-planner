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
		var dictionary = c.to_dictionary()
		constrains_array.append(dictionary)
	assert_eq_deep(constrains_array, [
		{ "resource_name": "dummy constraint", "time_interval": Vector2i(0, 25), "duration": 25, "temporal_qualifier": 2},
		{ "resource_name": "Task 1", "time_interval": Vector2i(5, 15), "duration": 10, "temporal_qualifier": 2}]
	)


func test_propagate_constraints_variation_1() -> void:
	seed(12345)
	var simple_temporal_network: SimpleTemporalNetwork = SimpleTemporalNetwork.new()
	var task_constraints_data = [
		{"task_name": "Concept Art", "duration": 14, "temporal_qualifier": TemporalConstraint.TemporalQualifier.OVERALL},
		{"task_name": "Game Design Document", "duration": 30, "temporal_qualifier": TemporalConstraint.TemporalQualifier.OVERALL},
		{"task_name": "Character Modeling", "duration": 45, "temporal_qualifier": TemporalConstraint.TemporalQualifier.OVERALL},
		{"task_name": "Level Design", "duration": 60, "temporal_qualifier": TemporalConstraint.TemporalQualifier.OVERALL},
		{"task_name": "UI Design", "duration": 20, "temporal_qualifier": TemporalConstraint.TemporalQualifier.OVERALL},
		{"task_name": "Sound Effects", "duration": 25, "temporal_qualifier": TemporalConstraint.TemporalQualifier.OVERALL},
		{"task_name": "Music Composition", "duration": 40, "temporal_qualifier": TemporalConstraint.TemporalQualifier.OVERALL},
		{"task_name": "Programming Mechanics", "duration": 70, "temporal_qualifier": TemporalConstraint.TemporalQualifier.OVERALL},
		{"task_name": "QA Testing", "duration": 50, "temporal_qualifier": TemporalConstraint.TemporalQualifier.OVERALL},
		{"task_name": "Marketing", "duration": 35, "temporal_qualifier": TemporalConstraint.TemporalQualifier.OVERALL},
	]

	for data in task_constraints_data:
		var start_time = randi() % 100
		var end_time = start_time + data.duration + randi() % 50
		var task_constraints: TemporalConstraint = TemporalConstraint.new(start_time, end_time, data.duration, data.temporal_qualifier, data.task_name)
		simple_temporal_network.add_temporal_constraint(task_constraints)

	print("STN after adding all constraints: %s" % str(simple_temporal_network.to_dictionary()))

	var constrains_array = []
	for c in simple_temporal_network.constraints:
		var dictionary = c.to_dictionary()
		dictionary.erase("constraints")
		constrains_array.append(dictionary)

	print("STN constraints after adding task constraints: ", constrains_array)

	assert_eq_deep(constrains_array, [{ "resource_name": "Concept Art", "time_interval": Vector2i(56, 117), "duration": 14, "temporal_qualifier": 2 }, { "resource_name": "Game Design Document", "time_interval": Vector2i(41, 91), "duration": 30, "temporal_qualifier": 2 }, { "resource_name": "Character Modeling", "time_interval": Vector2i(6, 70), "duration": 45, "temporal_qualifier": 2 }, { "resource_name": "Level Design", "time_interval": Vector2i(41, 139), "duration": 60, "temporal_qualifier": 2 }, { "resource_name": "UI Design", "time_interval": Vector2i(38, 61), "duration": 20, "temporal_qualifier": 2 }, { "resource_name": "Sound Effects", "time_interval": Vector2i(2, 73), "duration": 25, "temporal_qualifier": 2 }, { "resource_name": "Music Composition", "time_interval": Vector2i(36, 112), "duration": 40, "temporal_qualifier": 2 }, { "resource_name": "Programming Mechanics", "time_interval": Vector2i(17, 111), "duration": 70, "temporal_qualifier": 2 }, { "resource_name": "QA Testing", "time_interval": Vector2i(1, 73), "duration": 50, "temporal_qualifier": 2 }, { "resource_name": "Marketing", "time_interval": Vector2i(28, 72), "duration": 35, "temporal_qualifier": 2 }])
