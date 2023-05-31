extends GutTest

func test_temporal_constraint() -> void:
	# Create an instance of PlanResource
	var plan_resource = PlanResource.new("test_plan")

	# Define input data for the test
	var intervals = [
		{ "start": 0, "end": 10 },
		{ "start": 15, "end": 25 },
		{ "start": 30, "end": 40 }
	]
	var min_duration = 5
	var max_duration = 20

	# Create a new TemporalConstraint
	var tc = TemporalConstraint.new(0, min_duration, TemporalConstraint.TemporalQualifier.AT_START, "resource")

	# Call the get_feasible_intervals function with the input data
	var feasible_intervals = []
	for interval in intervals:
		feasible_intervals += plan_resource.get_feasible_intervals(interval["start"], interval["end"], tc)

	# Expected output
	var expected_output = [
		{ "start": 0, "end": 5 },
		{ "start": 15, "end": 20 },
		{ "start": 30, "end": 35 }
	]

	# Assert that the feasible intervals match the expected output
	assert_eq_deep(feasible_intervals, expected_output)
