extends "res://addons/gut/test.gd"

var stn = null


func before_each():
	stn = SimpleTemporalNetwork.new()


func test_to_dictionary():
	var result = stn.to_dictionary()
	assert_eq(typeof(result), TYPE_DICTIONARY, "to_dictionary should return a Dictionary")


func test_get_node_index():
	var node_interval = Vector2i(1, 2)
	var index = stn.get_node_index(node_interval)
	assert_eq(index, -1, "get_node_index should return -1 for non-existing node")


func test_init_matrix():
	stn.num_nodes = 3
	stn._init_matrix()
	assert_eq(stn.stn_matrix.size(), 3, "_init_matrix should initialize matrix with size equal to num_nodes")


func test_add_temporal_constraint():
	var from_constraint = TemporalConstraint.new(1, 2, 3, TemporalConstraint.TemporalQualifier.AT_START, "resource")
	var result = stn.add_temporal_constraint(from_constraint)
	assert_true(result, "add_temporal_constraint should return true when adding valid constraint")


func test_get_temporal_constraint_by_name():
	var constraint = TemporalConstraint.new(1, 2, 3, TemporalConstraint.TemporalQualifier.AT_START, "resource")
	stn.constraints.append(constraint)
	var result = stn.get_temporal_constraint_by_name("resource")
	assert_eq(result, constraint, "get_temporal_constraint_by_name should return the correct constraint")


func test_propagate_constraints():
	stn.num_nodes = 3
	stn._init_matrix()
	var result = stn.propagate_constraints()
	assert_true(result, "propagate_constraints should return true when there are no negative diagonal values")


func test_is_consistent():
	var result = stn.is_consistent()
	assert_true(result, "is_consistent should return true when constraints are consistent")


func test_update_state():
	var state = {"constraint": TemporalConstraint.new(1, 2, 3, TemporalConstraint.TemporalQualifier.AT_START, "resource")}
	stn.update_state(state)
	assert_eq(stn.constraints.size(), 1, "update_state should add the constraint to the constraints array")


func test_is_consistent_with():
	var constraint = TemporalConstraint.new(1, 2, 3, TemporalConstraint.TemporalQualifier.AT_START, "resource")
	stn.add_temporal_constraint(constraint)
	var result = stn.is_consistent_with(constraint)
	assert_true(result, "is_consistent_with should return true when the network is consistent with the given constraint")


func test_print_constraints_and_check_consistency():
	var constraint = TemporalConstraint.new(1, 2, 3, TemporalConstraint.TemporalQualifier.AT_START, "resource")
	stn.add_temporal_constraint(constraint)
	for i in range(stn.constraints.size()):
		gut.p("Constraint " + str(i) + ": " + str(stn.constraints[i].to_dictionary()), gut.LOG_LEVEL_ALL_ASSERTS)
	var result = stn.is_consistent()
	assert_true(result, "is_consistent should return true when the network is consistent")
