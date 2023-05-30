extends Resource

class_name TemporalConstraint

enum TemporalQualifier {
	AT_START,
	AT_END,
	OVERALL,
}

var time_interval: Vector2i
var duration: int
var temporal_qualifier: TemporalQualifier
var direct_successors: Array

func _init(start: int, duration: int, qualifier: TemporalQualifier, resource: String):
	time_interval = Vector2i(start, start + duration)
	self.duration = duration
	temporal_qualifier = qualifier
	resource_name = resource
	direct_successors = []

func add_direct_successor(successor_index: int, time_difference: int) -> void:
	direct_successors.append({"index": successor_index, "time_difference": time_difference})

func method_with_time_constraints(state, action_name, time_interval : TemporalConstraint, agent, args=[]) -> Variant:
	if not agent:
		print("Invalid agent: agent cannot be null.")
		return false

	var duration = time_interval.duration

	if duration < 0:
		print("Invalid duration: Duration should be non-negative.")
		return false

	if time_interval.time_interval.x < 0 or time_interval.time_interval.y < time_interval.time_interval.x:
		print("Invalid time interval: Start time should be less than or equal to the end time, and both should be non-negative.")
		return false

	agent.simple_temporal_network.add_temporal_constraint(TemporalConstraint.new(time_interval.time_interval.x, time_interval.duration, time_interval.temporal_qualifier, time_interval.resource_name))

	if not agent.simple_temporal_network.is_consistent():
		print("Inconsistent constraints: The new constraint could not be satisfied.")
		return false

	# Return a task list with the specified action, its arguments, and the STN
	return [action_name, time_interval, agent.stn]

func deep_equal(other: Object) -> bool:
	if other is TemporalConstraint:
		return self.time_interval == other.time_interval and \
				self.duration == other.duration and \
				self.qualifier == other.qualifier and \
				self.description == other.description
	return false
