# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# temporal_constraint.gd
# SPDX-License-Identifier: MIT

extends Resource

class_name TemporalConstraint

enum TemporalQualifier {
	AT_START,
	AT_END,
	OVERALL,
}

@export var time_interval: Vector2i
@export var duration: int
@export var temporal_qualifier: TemporalQualifier


func _init(start: int, end: int, duration: int, qualifier: TemporalQualifier, resource: String):
	time_interval = Vector2i(start, end)
	self.duration = duration
	temporal_qualifier = qualifier
	resource_name = resource


func _to_string() -> String:
	return str(
		{
			"resource_name": resource_name,
			"time_interval": time_interval,
			"duration": duration,
			"temporal_qualifier": temporal_qualifier
		}
	)


static func sort_func(a: TemporalConstraint, b: TemporalConstraint) -> bool:
	return (
		a.time_interval.x < b.time_interval.x
		or (a.time_interval.x == b.time_interval.x and a.time_interval.y < b.time_interval.y)
	)
