extends GutTest

func test_get_feasible_intervals_new_constraint() -> void:
	# Create a new STN
	var stn = STN.new()

	# Create a new PlanResource and add the STN to it
	var resource = PlanResource.new("Resource")
	resource.stn = stn

	# Add some constraints to the STN
	resource.stn.add_temporal_constraint(TemporalConstraint.new(0, 10, TemporalConstraint.TemporalQualifier.OVERALL, "dummy constraint"))
	resource.stn.add_temporal_constraint(TemporalConstraint.new(15, 15, TemporalConstraint.TemporalQualifier.OVERALL, "dummy constraint"))
	resource.stn.add_temporal_constraint(TemporalConstraint.new(20, 5, TemporalConstraint.TemporalQualifier.OVERALL, "dummy constraint"))
	
	var start_time = 5
	var end_time = 35
	var duration = end_time - start_time
	# Get feasible intervals for a new constraint
	var feasible_intervals = resource.get_feasible_intervals(start_time, duration, 10)

	# Print the actual feasible intervals
	assert_true(feasible_intervals != null, "Actual feasible intervals: %s" % [feasible_intervals])

	# Test that the number of feasible intervals is correct
	assert_eq(feasible_intervals.size(), 1, "Expected one feasible interval")

	# Test that the feasible interval is correct
	var expected_interval = TemporalConstraint.new(15, 10, TemporalConstraint.TemporalQualifier.OVERALL, "feasible interval")
	if feasible_intervals.size():
		assert_eq(feasible_intervals[0], expected_interval, "Expected feasible interval not found")

	assert_true(expected_interval != null, "Expected feasible intervals: %s" % [expected_interval])


func test_propagate_non_overlapping_constraints():
	var mia = PlanResource.new("Mia")
	# Add initial temporal constraints
	mia.stn.add_temporal_constraint(TemporalConstraint.new(0, 25, TemporalConstraint.TemporalQualifier.OVERALL, "dummy constraint"))

	# Add temporal constraint for task
	var task_name = "Task 1"
	var start_time = 5
	var duration = 10
	var task_constraints = TemporalConstraint.new(start_time, duration, TemporalConstraint.TemporalQualifier.OVERALL, task_name)
	mia.stn.add_temporal_constraint(task_constraints)

	# Check that task constraints were added to STN
	var task_constraints_added = false
	for constraint in mia.stn.constraints:
		if constraint.resource_name == task_name:
			task_constraints_added = true
			break

	assert_eq(task_constraints_added, true, "Expected task constraints to be added to STN")

	# Check that the duration of the task constraint was propagated correctly
	var constraint_task_name = mia.stn.get_temporal_constraint_by_name(mia, task_name)

	if constraint_task_name:
		var propagated_duration = constraint_task_name.duration
		assert_eq(propagated_duration, duration, "Expected duration to be propagated correctly")

		var temporal_constraint : TemporalConstraint =  mia.stn.get_temporal_constraint_by_name(mia, task_name)
		# Check that the start time of the task constraint was propagated correctly
		var propagated_start_time = temporal_constraint.time_interval.x
		assert_eq(propagated_start_time, start_time, "Expected start time to be propagated correctly")

	# Check that STN is consistent after propagating constraints
	assert_eq(mia.stn.is_consistent(), true, "Expected STN to be consistent after propagating constraints")

func test_propagate_constraints():
	var mia = PlanResource.new("Mia")
	# Add initial temporal constraints
	mia.stn.add_temporal_constraint(TemporalConstraint.new(0, 25, TemporalConstraint.TemporalQualifier.OVERALL, "dummy constraint"))

	# Add temporal constraint for task
	var task_name = "Task 1"
	var start_time = 5
	var duration = 10
	var task_constraints = TemporalConstraint.new(start_time, duration, TemporalConstraint.TemporalQualifier.OVERALL, task_name)
	mia.stn.add_temporal_constraint(task_constraints)

	# Check that task constraints were added to STN
	var task_constraints_added = false
	for constraint in mia.stn.constraints:
		if constraint.resource_name == task_name:
			task_constraints_added = true
			break

	assert_eq(task_constraints_added, true, "Expected task constraints to be added to STN")

	# Check that the duration of the task constraint was propagated correctly
	var constraint_task_name = mia.stn.get_temporal_constraint_by_name(mia, task_name)

	if constraint_task_name:
		var propagated_duration = constraint_task_name.duration
		assert_eq(propagated_duration, duration, "Expected duration to be propagated correctly")

		var temporal_constraint : TemporalConstraint = mia.stn.get_temporal_constraint_by_name(mia, task_name)
		# Check that the start time of the task constraint was propagated correctly
		var propagated_start_time = temporal_constraint.time_interval.x
		assert_eq(propagated_start_time, start_time, "Expected start time to be propagated correctly")

	# Check that STN is consistent after propagating constraints
	assert_eq(mia.stn.is_consistent(), true, "Expected STN to be consistent after propagating constraints")


func test_task_duration_shorter_than_feasible_intervals():
	var mia = PlanResource.new("Mia")
	mia.stn.add_temporal_constraint(TemporalConstraint.new(10, 20, TemporalConstraint.TemporalQualifier.OVERALL, "dummy constraint"))

	var start_time = 5
	var end_time = 15
	var duration = 5
	var task_constraints: Array[TemporalConstraint] = [
		TemporalConstraint.new(start_time, duration, TemporalConstraint.TemporalQualifier.OVERALL, "Feasible interval [10, 15]")
	]

	var feasible = mia.get_feasible_intervals(start_time, end_time, duration)
	assert_eq(feasible.size(), 0, "Expected no feasible intervals")

