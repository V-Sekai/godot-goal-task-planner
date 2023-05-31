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

	var outcome = []

	# Call the get_feasible_intervals function with the input data
	var feasible_intervals = []
	for interval in intervals:
		feasible_intervals += plan_resource.get_feasible_intervals(interval["start"], interval["end"], tc)

	var output = []
	for c in plan_resource.simple_temporal_network.constraints:
		output.push_back(c.to_dictionary())

	# Expected output
	var expected_output = [
		{ "time_interval": Vector2i(0, 5), "temporal_qualifier": 0, "direct_successors": [] },
		{ "time_interval": Vector2i(15, 20), "temporal_qualifier": 0, "direct_successors": [] },
		{ "time_interval": Vector2i(30, 35), "temporal_qualifier": 0, "direct_successors": [] },
	]

	# Assert that the feasible intervals match the expected output
	assert_eq_deep(output, expected_output)
