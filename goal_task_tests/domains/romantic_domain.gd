extends "res://addons/task_goal/core/domain.gd"

func _init() -> void:
	set_name("isekai_anime")

## Function to travel to a location
func travel_location(state, entity, location) -> Dictionary:
	state.at[entity] = location
	return state

## Method for traveling to a location
func m_travel_location(state, entity, location) -> Variant:
	if entity in state.entities and location in state.locations and state.at[entity] != location:
		return [["travel_location", entity, location]]
	return false

## Check if two entities have met at a place
func has_entity_met_entity(_state: Dictionary, e_1: String, e_2, place: String) -> Variant:
	return [Multigoal.new("entities_together", {"at": {e_1: place, e_2: place}})]
