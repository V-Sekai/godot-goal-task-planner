# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# temporal_constraint.gd
# SPDX-License-Identifier: MIT

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

func _init(start: int, end: int, duration: int, qualifier: TemporalQualifier, resource: String):
	time_interval = Vector2i(start, end)
	self.duration = duration
	temporal_qualifier = qualifier
	resource_name = resource

func to_dictionary() -> Dictionary:
	return { "resource_name": resource_name, "time_interval" : time_interval, "duration": duration, "temporal_qualifier": temporal_qualifier }
