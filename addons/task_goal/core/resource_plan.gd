extends Resource

class_name PlanResource

var domain_name = "artist_dream"

var the_domain = preload("res://addons/task_goal/core/domain.gd").new(domain_name)

var planner = preload("res://addons/task_goal/core/plan.gd").new()

var simple_temporal_network : SimpleTemporalNetwork

func _init(name):
	self.set_name(name)
	self.simple_temporal_network = SimpleTemporalNetwork.new()

func get_feasible_intervals(start_time: int, end_time: int, new_constraint: TemporalConstraint) -> Array:
	var feasible_intervals = []
	
	for i in range(start_time, end_time - new_constraint.duration + 1):
		var temp_constraint = TemporalConstraint.new(i, i + new_constraint.duration, new_constraint.temporal_qualifier, new_constraint.resource_name)
		
		simple_temporal_network.add_temporal_constraint(temp_constraint)
		
		simple_temporal_network.propagate_constraints()
		
		if simple_temporal_network.is_consistent():
			feasible_intervals.append(temp_constraint)
		
		simple_temporal_network.remove_temporal_constraint(temp_constraint.resource_name)
	
	return feasible_intervals
