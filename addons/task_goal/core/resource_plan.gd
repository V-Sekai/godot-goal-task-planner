extends Resource

class_name PlanResource

var domain_name = "artist_dream"

var the_domain = preload("res://addons/task_goal/core/domain.gd").new(domain_name)

var planner = preload("res://addons/task_goal/core/plan.gd").new()

var simple_temporal_network : SimpleTemporalNetwork

func _init(name):
	self.set_name(name)
	self.simple_temporal_network = SimpleTemporalNetwork.new()

func get_feasible_intervals(start_time: int, end_time: int, duration: int) -> Array[TemporalConstraint]:
	# Propagate constraints to ensure consistency
	simple_temporal_network.propagate_constraints()

	var feasible_intervals: Array[TemporalConstraint] = []
	
	for other_constraint in simple_temporal_network.constraints:
		var interval = other_constraint.time_interval

		var feasible_interval_start : int = max(interval.x, start_time)
		var feasible_interval_end: int = min(interval.y - duration, end_time)
		if feasible_interval_end < feasible_interval_start:
			continue

		if feasible_interval_end >= feasible_interval_start:
			var feasible_interval: TemporalConstraint = TemporalConstraint.new(feasible_interval_start, feasible_interval_end - feasible_interval_start, TemporalConstraint.TemporalQualifier.OVERALL, "feasible interval")
			feasible_intervals.append(feasible_interval)

	if feasible_intervals.size() == 0:
		return []
	else:
		return feasible_intervals

