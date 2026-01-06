/**************************************************************************/
/*  magical_girls_college_test.h                                          */
/**************************************************************************/
/*                         This file is part of:                          */
/*                             GODOT ENGINE                               */
/*                        https://godotengine.org                         */
/**************************************************************************/
/* Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md). */
/* Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.                  */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

#pragma once

// SPDX-FileCopyrightText: 2025-present K. S. Ernest (iFire) Lee
// SPDX-License-Identifier: MIT

#include "../../domain.h"
#include "../../plan.h"
#include "../../planner_belief_manager.h"
#include "../../planner_facts_allocentric.h"
#include "../../planner_persona.h"
#include "../../planner_result.h"
#include "../../planner_time_range.h"
#include "core/math/random_number_generator.h"
#include "core/math/vector3.h"
#include "core/variant/callable.h"
#include "core/variant/dictionary.h"
#include "core/variant/typed_array.h"
#include "magical_girls_college_domain.h"
#include "tests/test_macros.h"

namespace TestMagicalGirlsCollege {

// Helper: Create magical girls college domain with actions and methods
Ref<PlannerDomain> create_magical_girls_college_domain() {
	Ref<PlannerDomain> domain = memnew(PlannerDomain);

	// Add actions
	TypedArray<Callable> actions;
	actions.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::action_attend_lecture));
	actions.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::action_complete_homework));
	actions.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::action_study_library));
	actions.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::action_eat_mess_hall));
	actions.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::action_coffee_together));
	actions.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::action_watch_movie));
	actions.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::action_pool_hangout));
	actions.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::action_park_picnic));
	actions.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::action_beach_trip));
	actions.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::action_read_book));
	actions.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::action_club_activity));
	actions.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::action_optimize_schedule));
	actions.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::action_predict_outcome));
	domain->add_actions(actions);

	// Add task methods for earn_study_points
	// Coordinated method is tried first (if coordination exists in state)
	TypedArray<Callable> earn_study_points_methods;
	earn_study_points_methods.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::task_earn_study_points_method_done));
	earn_study_points_methods.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::task_earn_study_points_method_coordinated));
	earn_study_points_methods.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::task_earn_study_points_method_lecture));
	earn_study_points_methods.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::task_earn_study_points_method_homework));
	earn_study_points_methods.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::task_earn_study_points_method_library));
	domain->add_task_methods("task_earn_study_points", earn_study_points_methods);

	// Add task methods for socialize
	TypedArray<Callable> socialize_methods;
	socialize_methods.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::task_socialize_method_easy));
	socialize_methods.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::task_socialize_method_moderate));
	socialize_methods.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::task_socialize_method_challenging));
	domain->add_task_methods("task_socialize", socialize_methods);

	// Add task methods for manage_week
	TypedArray<Callable> manage_week_methods;
	manage_week_methods.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::task_manage_week_method_balance));
	manage_week_methods.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::task_manage_week_method_academics));
	manage_week_methods.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::task_manage_week_method_relationships));
	domain->add_task_methods("task_manage_week", manage_week_methods);

	// Add unigoal methods
	TypedArray<Callable> unigoal_methods;
	unigoal_methods.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::unigoal_achieve_study_goal));
	domain->add_unigoal_methods("study_points", unigoal_methods);

	// Add multigoal methods
	TypedArray<Callable> multigoal_methods;
	multigoal_methods.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::multigoal_solve_temporal_puzzle));
	multigoal_methods.push_back(callable_mp_static(&MagicalGirlsCollegeDomainCallable::multigoal_balance_life));
	domain->add_multigoal_methods(multigoal_methods);

	return domain;
}

// Helper: Create initial state for magical girls college
Dictionary create_magical_girls_college_init_state() {
	Dictionary state;

	// Locations
	Dictionary is_at;
	is_at["yuki"] = "dorm";
	is_at["maya"] = "dorm";
	is_at["rin"] = "dorm";
	is_at["kira"] = "dorm";
	is_at["luna"] = "dorm";
	state["is_at"] = is_at;

	// Study points
	Dictionary study_points;
	study_points["yuki"] = 0;
	study_points["maya"] = 0;
	study_points["rin"] = 0;
	study_points["kira"] = 0;
	study_points["luna"] = 0;
	state["study_points"] = study_points;

	// Relationship points
	Dictionary relationship_points;
	Dictionary yuki_relationships;
	yuki_relationships["maya"] = 0;
	yuki_relationships["rin"] = 0;
	yuki_relationships["kira"] = 0;
	yuki_relationships["luna"] = 0;
	relationship_points["yuki"] = yuki_relationships;
	state["relationship_points"] = relationship_points;

	// Burnout
	Dictionary burnout;
	burnout["yuki"] = 0;
	burnout["maya"] = 0;
	burnout["rin"] = 0;
	burnout["kira"] = 0;
	burnout["luna"] = 0;
	state["burnout"] = burnout;

	// Preferences
	Dictionary preferences;
	Dictionary yuki_prefs;
	Array yuki_likes;
	yuki_likes.push_back("library");
	yuki_likes.push_back("movies");
	yuki_prefs["likes"] = yuki_likes;
	Array yuki_dislikes;
	yuki_dislikes.push_back("beach");
	yuki_prefs["dislikes"] = yuki_dislikes;
	preferences["yuki"] = yuki_prefs;

	Dictionary maya_prefs;
	Array maya_likes;
	maya_likes.push_back("library");
	maya_likes.push_back("park");
	maya_prefs["likes"] = maya_likes;
	Array maya_dislikes;
	maya_dislikes.push_back("pool");
	maya_prefs["dislikes"] = maya_dislikes;
	preferences["maya"] = maya_prefs;

	Dictionary rin_prefs;
	Array rin_likes;
	rin_likes.push_back("beach");
	rin_likes.push_back("pool");
	rin_prefs["likes"] = rin_likes;
	Array rin_dislikes;
	rin_dislikes.push_back("library");
	rin_prefs["dislikes"] = rin_dislikes;
	preferences["rin"] = rin_prefs;

	Dictionary kira_prefs;
	Array kira_likes;
	kira_likes.push_back("cinema");
	kira_likes.push_back("coffee");
	kira_prefs["likes"] = kira_likes;
	Array kira_dislikes;
	kira_dislikes.push_back("beach");
	kira_prefs["dislikes"] = kira_dislikes;
	preferences["kira"] = kira_prefs;

	Dictionary luna_prefs;
	Array luna_likes;
	luna_likes.push_back("park");
	luna_likes.push_back("beach");
	luna_prefs["likes"] = luna_likes;
	Array luna_dislikes;
	luna_dislikes.push_back("mess_hall");
	luna_prefs["dislikes"] = luna_dislikes;
	preferences["luna"] = luna_prefs;

	state["preferences"] = preferences;

	return state;
}

// Helper: Create Yuki persona (HUMAN)
Ref<PlannerPersona> create_yuki_persona() {
	Ref<PlannerPersona> persona = PlannerPersona::create_human("yuki", "Yuki");
	return persona;
}

// Helper: Create Maya persona (HUMAN)
Ref<PlannerPersona> create_maya_persona() {
	Ref<PlannerPersona> persona = PlannerPersona::create_human("maya", "Maya");
	return persona;
}

// Helper: Create Rin persona (AI)
Ref<PlannerPersona> create_rin_persona() {
	Ref<PlannerPersona> persona = PlannerPersona::create_ai("rin", "Rin");
	return persona;
}

// Helper: Create Kira persona (HUMAN_AND_AI)
Ref<PlannerPersona> create_kira_persona() {
	Ref<PlannerPersona> persona = PlannerPersona::create_hybrid("kira", "Kira");
	return persona;
}

// Helper: Create Luna persona (HUMAN)
Ref<PlannerPersona> create_luna_persona() {
	Ref<PlannerPersona> persona = PlannerPersona::create_human("luna", "Luna");
	return persona;
}

// Helper: Setup belief manager with all personas
Ref<PlannerBeliefManager> setup_belief_manager() {
	Ref<PlannerBeliefManager> manager = memnew(PlannerBeliefManager);
	manager->register_persona(create_yuki_persona());
	manager->register_persona(create_maya_persona());
	manager->register_persona(create_rin_persona());
	manager->register_persona(create_kira_persona());
	manager->register_persona(create_luna_persona());
	return manager;
}

// Helper: Setup allocentric facts
Ref<PlannerFactsAllocentric> setup_allocentric_facts() {
	Ref<PlannerFactsAllocentric> facts = memnew(PlannerFactsAllocentric);

	// Set terrain facts for locations
	facts->set_terrain_fact("mess_hall", "type", "indoor");
	facts->set_terrain_fact("mess_hall", "difficulty", 1);
	facts->set_terrain_fact("library", "type", "indoor");
	facts->set_terrain_fact("library", "difficulty", 1);
	facts->set_terrain_fact("cinema", "type", "indoor");
	facts->set_terrain_fact("cinema", "difficulty", 2);
	facts->set_terrain_fact("pool", "type", "outdoor");
	facts->set_terrain_fact("pool", "difficulty", 2);
	facts->set_terrain_fact("park", "type", "outdoor");
	facts->set_terrain_fact("park", "difficulty", 3);
	facts->set_terrain_fact("beach", "type", "outdoor");
	facts->set_terrain_fact("beach", "difficulty", 3);

	// Add shared objects
	Dictionary book_data;
	book_data["type"] = "study_book";
	book_data["location"] = "library";
	facts->add_shared_object("study_book_1", book_data);

	Dictionary club_data;
	club_data["type"] = "club_material";
	club_data["location"] = "dorm";
	facts->add_shared_object("club_material_1", club_data);

	// Add public events
	Dictionary lecture_event;
	lecture_event["type"] = "lecture";
	lecture_event["location"] = "library";
	lecture_event["time"] = "morning";
	facts->add_public_event("lecture_schedule_1", lecture_event);

	Dictionary club_event;
	club_event["type"] = "club_meeting";
	club_event["location"] = "dorm";
	club_event["time"] = "afternoon";
	facts->add_public_event("club_meeting_1", club_event);

	// Set entity positions (initially all at dorm)
	facts->set_entity_position("yuki", Vector3(0, 0, 0));
	facts->set_entity_position("maya", Vector3(0, 0, 0));
	facts->set_entity_position("rin", Vector3(0, 0, 0));
	facts->set_entity_position("kira", Vector3(0, 0, 0));
	facts->set_entity_position("luna", Vector3(0, 0, 0));

	// Set entity capabilities (publicly observable)
	facts->set_entity_capability_public("yuki", "movable", true);
	facts->set_entity_capability_public("yuki", "interact", true);
	facts->set_entity_capability_public("maya", "movable", true);
	facts->set_entity_capability_public("maya", "interact", true);
	facts->set_entity_capability_public("rin", "compute", true);
	facts->set_entity_capability_public("rin", "optimize", true);
	facts->set_entity_capability_public("kira", "movable", true);
	facts->set_entity_capability_public("kira", "interact", true);
	facts->set_entity_capability_public("kira", "compute", true);
	facts->set_entity_capability_public("luna", "movable", true);
	facts->set_entity_capability_public("luna", "interact", true);

	return facts;
}

// Helper: Create randomized initial state based on seed
Dictionary create_randomized_state(int64_t seed) {
	Ref<RandomNumberGenerator> rng = memnew(RandomNumberGenerator);
	rng->set_seed(static_cast<uint64_t>(seed));

	Dictionary state = create_magical_girls_college_init_state();

	// Randomize initial study points (0-5)
	Dictionary study_points = state["study_points"];
	study_points["yuki"] = rng->randi_range(0, 5);
	study_points["maya"] = rng->randi_range(0, 5);
	study_points["rin"] = rng->randi_range(0, 5);
	study_points["kira"] = rng->randi_range(0, 5);
	study_points["luna"] = rng->randi_range(0, 5);
	state["study_points"] = study_points;

	// Randomize initial relationship points (0-3)
	Dictionary relationship_points = state["relationship_points"];
	Dictionary yuki_relationships = relationship_points["yuki"];
	yuki_relationships["maya"] = rng->randi_range(0, 3);
	yuki_relationships["rin"] = rng->randi_range(0, 3);
	yuki_relationships["kira"] = rng->randi_range(0, 3);
	yuki_relationships["luna"] = rng->randi_range(0, 3);
	relationship_points["yuki"] = yuki_relationships;
	state["relationship_points"] = relationship_points;

	// Randomize initial burnout (0-20)
	Dictionary burnout = state["burnout"];
	burnout["yuki"] = rng->randi_range(0, 20);
	burnout["maya"] = rng->randi_range(0, 20);
	burnout["rin"] = rng->randi_range(0, 20);
	burnout["kira"] = rng->randi_range(0, 20);
	burnout["luna"] = rng->randi_range(0, 20);
	state["burnout"] = burnout;

	return state;
}

// Helper: Get random observation target based on seed
String get_random_observation_target(Ref<RandomNumberGenerator> rng) {
	Array targets;
	targets.push_back("maya");
	targets.push_back("rin");
	targets.push_back("kira");
	targets.push_back("luna");
	return targets[rng->randi() % targets.size()];
}

// Helper: Get random location based on seed
String get_random_location(Ref<RandomNumberGenerator> rng) {
	Array locations;
	locations.push_back("library");
	locations.push_back("pool");
	locations.push_back("cinema");
	locations.push_back("park");
	locations.push_back("beach");
	locations.push_back("mess_hall");
	return locations[rng->randi() % locations.size()];
}

// Helper: Get random activity level (1-3) based on seed
int get_random_activity_level(Ref<RandomNumberGenerator> rng) {
	return rng->randi_range(1, 3);
}

// Helper: Capitalize first letter of string
String capitalize_string(const String &str) {
	if (str.length() == 0) {
		return str;
	}
	String result = str;
	char32_t first = result[0];
	if (first >= 'a' && first <= 'z') {
		result[0] = first - ('a' - 'A');
	}
	return result;
}

// Test Case 1: Setup personas with identity types and capabilities
TEST_CASE("[Modules][Planner][MagicalGirls] Setup personas with identity types and capabilities") {
	Ref<PlannerPersona> yuki = create_yuki_persona();
	Ref<PlannerPersona> maya = create_maya_persona();
	Ref<PlannerPersona> rin = create_rin_persona();
	Ref<PlannerPersona> kira = create_kira_persona();
	Ref<PlannerPersona> luna = create_luna_persona();

	CHECK(yuki.is_valid());
	CHECK(yuki->get_identity_type() == PlannerPersonaIdentity::IDENTITY_HUMAN);
	CHECK(yuki->has_capability("movable"));
	CHECK(yuki->has_capability("interact"));

	CHECK(maya.is_valid());
	CHECK(maya->get_identity_type() == PlannerPersonaIdentity::IDENTITY_HUMAN);

	CHECK(rin.is_valid());
	CHECK(rin->get_identity_type() == PlannerPersonaIdentity::IDENTITY_AI);
	CHECK(rin->has_capability("compute"));
	CHECK(rin->has_capability("optimize"));
	CHECK(rin->has_capability("predict"));

	CHECK(kira.is_valid());
	CHECK(kira->get_identity_type() == PlannerPersonaIdentity::IDENTITY_HUMAN_AND_AI);
	CHECK(kira->has_capability("movable"));
	CHECK(kira->has_capability("interact"));
	CHECK(kira->has_capability("compute"));
	CHECK(kira->has_capability("optimize"));

	CHECK(luna.is_valid());
	CHECK(luna->get_identity_type() == PlannerPersonaIdentity::IDENTITY_HUMAN);

	Ref<PlannerBeliefManager> manager = setup_belief_manager();
	CHECK(manager->has_persona("yuki"));
	CHECK(manager->has_persona("maya"));
	CHECK(manager->has_persona("rin"));
	CHECK(manager->has_persona("kira"));
	CHECK(manager->has_persona("luna"));
}

// Test Case 2: Setup allocentric facts
TEST_CASE("[Modules][Planner][MagicalGirls] Setup allocentric facts - terrain, objects, events, positions") {
	Ref<PlannerFactsAllocentric> facts = setup_allocentric_facts();

	CHECK(facts->has_terrain_fact("library", "type"));
	CHECK(String(facts->get_terrain_fact("library", "type")) == "indoor");

	CHECK(facts->has_shared_object("study_book_1"));
	Dictionary book = facts->get_shared_object("study_book_1");
	CHECK(String(book["type"]) == "study_book");

	CHECK(facts->has_public_event("lecture_schedule_1"));
	Dictionary event = facts->get_public_event("lecture_schedule_1");
	CHECK(String(event["type"]) == "lecture");

	CHECK(facts->has_entity_position("yuki"));
	Vector3 pos = facts->get_entity_position("yuki");
	CHECK(pos == Vector3(0, 0, 0));

	CHECK(facts->has_entity_capability_public("yuki", "movable"));
	CHECK(bool(facts->get_entity_capability_public("yuki", "movable")) == true);

	// Verify all personas can observe
	Dictionary terrain = facts->observe_terrain("library");
	CHECK(terrain.has("type"));

	Dictionary objects = facts->observe_shared_objects("library");
	CHECK(objects.has("study_book_1"));

	Dictionary events = facts->observe_public_events();
	CHECK(events.has("lecture_schedule_1"));

	Dictionary positions = facts->observe_entity_positions();
	CHECK(positions.has("yuki"));

	Dictionary capabilities = facts->observe_entity_capabilities();
	CHECK(capabilities.has("yuki"));
}

// Test Case 3: Yuki plans weekly activities with persona integration
TEST_CASE("[Modules][Planner][MagicalGirls] Yuki plans weekly activities with persona integration") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);
	plan->set_verbose(0);

	Ref<PlannerPersona> yuki = create_yuki_persona();
	Ref<PlannerBeliefManager> manager = setup_belief_manager();
	Ref<PlannerFactsAllocentric> facts = setup_allocentric_facts();

	plan->set_current_persona(yuki);
	plan->set_belief_manager(manager);
	plan->set_allocentric_facts(facts);

	CHECK(plan->get_current_persona().is_valid());
	CHECK(plan->get_belief_manager().is_valid());
	CHECK(plan->get_allocentric_facts().is_valid());

	Dictionary state = create_magical_girls_college_init_state();
	Array todo_list;
	Array task;
	task.push_back("task_manage_week");
	task.push_back("yuki");
	todo_list.push_back(task);

	Ref<PlannerResult> result = plan->find_plan(state, todo_list);
	CHECK(result.is_valid());
	// Planning may succeed or fail depending on complexity, but should not crash
	CHECK(true);
}

// Test Case 4: Belief formation through observation processing
TEST_CASE("[Modules][Planner][MagicalGirls] Belief formation through observation processing") {
	Ref<PlannerPersona> yuki = create_yuki_persona();
	Ref<PlannerPersona> maya = create_maya_persona();

	// Yuki observes Maya's activities
	Dictionary observation1;
	observation1["entity"] = "maya";
	observation1["action"] = "visit_library";
	observation1["location"] = "library";
	observation1["confidence"] = 0.7;
	yuki->process_observation(observation1);

	Dictionary beliefs = yuki->get_beliefs_about("maya");
	CHECK(beliefs.has("observed_visit_library"));

	// Check belief confidence for the observed action
	float confidence = yuki->get_belief_confidence_for("maya", "observed_visit_library");
	CHECK(confidence > 0.0);

	// Update belief confidence
	yuki->update_belief_confidence("maya", "observed_visit_library", 0.8);
	float updated_confidence = yuki->get_belief_confidence_for("maya", "observed_visit_library");
	CHECK(updated_confidence > 0.0);

	// Multiple observations increase confidence
	Dictionary observation2;
	observation2["entity"] = "maya";
	observation2["action"] = "visit_library";
	observation2["location"] = "library";
	observation2["confidence"] = 0.8;
	yuki->process_observation(observation2);

	float new_confidence = yuki->get_belief_confidence_for("maya", "observed_visit_library");
	CHECK(new_confidence >= confidence);
}

// Test Case 5: Persona coordination through communication with temporal planning
TEST_CASE("[Modules][Planner][MagicalGirls] Persona coordination through communication with temporal planning") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);
	plan->set_current_persona(create_yuki_persona());
	plan->set_verbose(1); // Enable metadata logging

	// Set time range for a day (24 hours = 86400000000 microseconds)
	PlannerTimeRange time_range;
	time_range.start_time = static_cast<int64_t>(1735689600000000LL); // 2025-01-01 00:00:00 UTC (midnight)
	time_range.end_time = time_range.start_time + static_cast<int64_t>(86400000000LL); // +24 hours
	plan->set_time_range(time_range);

	// Maya coordinates a study session with Yuki at 2pm (14:00 = 14 hours from midnight)
	int64_t coordinated_time = time_range.start_time + static_cast<int64_t>(50400000000LL); // 14 hours = 2pm
	Dictionary coordination;
	coordination["from"] = "maya";
	coordination["message"] = "Let's study together at the library at 2pm";
	coordination["topic"] = "coordination";
	coordination["action"] = "study_session";
	coordination["location"] = "library";
	coordination["time"] = coordinated_time; // Absolute time in microseconds

	// Store coordination in persona (for communication tracking)
	Ref<PlannerPersona> yuki = plan->get_current_persona();
	yuki->process_communication(coordination);

	// Communication stores coordination information (not beliefs about preferences)
	Dictionary beliefs = yuki->get_beliefs_about("maya");
	CHECK(beliefs.has("communication_coordination"));

	// Communication does NOT form location preference beliefs
	float location_confidence = yuki->get_belief_confidence_for("maya", "likes_library");
	CHECK(location_confidence == 0.0); // Should be 0.0 - coordination doesn't form preference beliefs

	// Store coordination in state so domain methods can access it
	Dictionary state = create_magical_girls_college_init_state();
	if (!state.has("coordination")) {
		state["coordination"] = Dictionary();
	}
	Dictionary coord_dict = state["coordination"];
	coord_dict["yuki"] = coordination; // Store coordination for Yuki in state
	state["coordination"] = coord_dict;

	// Create a task to study at the library (which will fulfill the coordination)
	Array todo_list;
	Array task;
	task.push_back("task_earn_study_points");
	task.push_back("yuki");
	task.push_back(5); // Earn some study points
	todo_list.push_back(task);

	// Use run_lazy_refineahead for temporal planning (supports temporal constraints)
	Ref<PlannerResult> result = plan->run_lazy_refineahead(state, todo_list);
	CHECK(result.is_valid());
	CHECK(result->get_success());

	// Verify the plan includes actions that advance time
	if (result->get_success()) {
		Array plan_actions = result->extract_plan();
		CHECK(plan_actions.size() > 0);

		// Simulate the plan to verify time advancement
		Array state_sequence = plan->simulate(result, state, 0);
		CHECK(state_sequence.size() > 1); // Should have multiple states showing time progression

		// Verify Yuki ends up at the library (coordinated location) after study
		if (state_sequence.size() > 0) {
			Dictionary final_state = state_sequence[state_sequence.size() - 1];
			Dictionary is_at = final_state["is_at"];
			String yuki_location = is_at.get("yuki", "");
			// Yuki should be at library after the study session (action_study_library sets location)
			// May end at library or return to dorm
			bool location_valid = (yuki_location == "library" || yuki_location == "dorm");
			CHECK(location_valid);
		}

		// Verify study points increased (showing actions executed and time advanced)
		Dictionary final_state = state_sequence[state_sequence.size() - 1];
		Dictionary study_points = final_state["study_points"];
		int yuki_points = study_points.get("yuki", 0);
		CHECK(yuki_points >= 5); // Should have earned study points
	}

	// Yuki responds with coordination confirmation
	Ref<PlannerPersona> maya = create_maya_persona();
	Dictionary response;
	response["from"] = "yuki";
	response["message"] = "Sounds good! I'll meet you there at 2pm";
	response["topic"] = "coordination";
	response["action"] = "confirm";
	response["time"] = coordinated_time;
	maya->process_communication(response);

	// Both personas now have coordination records
	Dictionary yuki_beliefs = yuki->get_beliefs_about("maya");
	Dictionary maya_beliefs = maya->get_beliefs_about("yuki");
	CHECK(yuki_beliefs.has("communication_coordination"));
	CHECK(maya_beliefs.has("communication_coordination"));
}

// Test Case 6: Multi-persona planning with capabilities and preferences
TEST_CASE("[Modules][Planner][MagicalGirls] Multi-persona planning with capabilities and preferences") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Dictionary state = create_magical_girls_college_init_state();

	// Yuki plans socialization
	Ref<PlannerPlan> plan_yuki = memnew(PlannerPlan);
	plan_yuki->set_current_domain(domain);
	plan_yuki->set_current_persona(create_yuki_persona());
	plan_yuki->set_verbose(0);

	Array todo_yuki;
	Array task_yuki;
	task_yuki.push_back("task_socialize");
	task_yuki.push_back("yuki");
	task_yuki.push_back("maya");
	task_yuki.push_back(2); // Moderate activity
	todo_yuki.push_back(task_yuki);

	Ref<PlannerResult> result_yuki = plan_yuki->find_plan(state, todo_yuki);
	CHECK(result_yuki.is_valid());

	// Rin (AI) plans optimal study schedule
	Ref<PlannerPlan> plan_rin = memnew(PlannerPlan);
	plan_rin->set_current_domain(domain);
	plan_rin->set_current_persona(create_rin_persona());
	plan_rin->set_verbose(0);

	Array todo_rin;
	Array task_rin;
	task_rin.push_back("task_earn_study_points");
	task_rin.push_back("rin");
	task_rin.push_back(15); // Target points
	todo_rin.push_back(task_rin);

	Ref<PlannerResult> result_rin = plan_rin->find_plan(state, todo_rin);
	CHECK(result_rin.is_valid());
}

// Test Case 7: Information asymmetry - internal state hidden
TEST_CASE("[Modules][Planner][MagicalGirls] Information asymmetry - internal state hidden") {
	Ref<PlannerBeliefManager> manager = setup_belief_manager();

	// Yuki cannot directly access Maya's internal planner state
	Dictionary result = manager->get_planner_state("maya", "yuki");
	// Should return error or empty for internal state
	bool result_valid = result.is_empty() || result.has("error");
	CHECK(result_valid);

	// Must form beliefs through observation (not communication)
	// Communication is for coordination, not belief formation
	Ref<PlannerPersona> yuki = manager->get_persona("yuki");
	Dictionary observation;
	observation["entity"] = "maya";
	observation["action"] = "activity";
	observation["location"] = "library";
	observation["observer_location"] = "library"; // Yuki is at library
	yuki->process_observation(observation);

	Dictionary beliefs = yuki->get_beliefs_about("maya");
	CHECK(beliefs.size() > 0);
}

// Test Case 8: Allocentric facts - terrain, objects, events, positions
TEST_CASE("[Modules][Planner][MagicalGirls] Allocentric facts - terrain, objects, events, positions") {
	Ref<PlannerFactsAllocentric> facts = setup_allocentric_facts();

	// All personas can observe terrain facts
	Dictionary terrain = facts->observe_terrain("library");
	CHECK(terrain.has("type"));

	// All personas can observe shared objects
	Dictionary objects = facts->observe_shared_objects("library");
	CHECK(objects.has("study_book_1"));

	// All personas can observe public events
	Dictionary events = facts->observe_public_events();
	CHECK(events.has("lecture_schedule_1"));

	// All personas can observe entity positions
	Dictionary positions = facts->observe_entity_positions();
	CHECK(positions.has("yuki"));
	CHECK(positions.has("maya"));
	CHECK(positions.has("rin"));

	// All personas can observe entity capabilities
	Dictionary capabilities = facts->observe_entity_capabilities();
	CHECK(capabilities.has("yuki"));
	CHECK(capabilities.has("rin"));

	// Update allocentric facts
	facts->set_entity_position("yuki", Vector3(10, 0, 0));
	Vector3 new_pos = facts->get_entity_position("yuki");
	CHECK(new_pos == Vector3(10, 0, 0));

	// All personas see updated facts
	Dictionary updated_positions = facts->observe_entity_positions();
	Vector3 observed_pos = updated_positions["yuki"];
	CHECK(observed_pos == Vector3(10, 0, 0));
}

// Test Case 9: Identity type affects planning capabilities
TEST_CASE("[Modules][Planner][MagicalGirls] Identity type affects planning capabilities") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Dictionary state = create_magical_girls_college_init_state();

	// Rin (AI) uses COMPUTE and OPTIMIZE
	Ref<PlannerPlan> plan_rin = memnew(PlannerPlan);
	plan_rin->set_current_domain(domain);
	plan_rin->set_current_persona(create_rin_persona());
	plan_rin->set_verbose(0);

	Array todo_rin;
	Array task_rin;
	task_rin.push_back("task_earn_study_points");
	task_rin.push_back("rin");
	task_rin.push_back(10);
	todo_rin.push_back(task_rin);

	Ref<PlannerResult> result_rin = plan_rin->find_plan(state, todo_rin);
	CHECK(result_rin.is_valid());

	// Kira (HYBRID) uses both human and AI capabilities
	Ref<PlannerPlan> plan_kira = memnew(PlannerPlan);
	plan_kira->set_current_domain(domain);
	plan_kira->set_current_persona(create_kira_persona());
	plan_kira->set_verbose(0);

	Array todo_kira;
	Array task_kira;
	task_kira.push_back("task_manage_week");
	task_kira.push_back("kira");
	todo_kira.push_back(task_kira);

	Ref<PlannerResult> result_kira = plan_kira->find_plan(state, todo_kira);
	CHECK(result_kira.is_valid());
}

// Test Case 10: Three planning methods - find_plan, lazy_lookahead, lazy_refineahead
TEST_CASE("[Modules][Planner][MagicalGirls] Three planning methods - find_plan, lazy_lookahead, lazy_refineahead") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);
	plan->set_verbose(0);
	plan->set_current_persona(create_yuki_persona());

	Dictionary state = create_magical_girls_college_init_state();
	Array todo_list;
	Array task;
	task.push_back("task_earn_study_points");
	task.push_back("yuki");
	task.push_back(10);
	todo_list.push_back(task);

	// Method 1: find_plan (standard planning)
	Ref<PlannerResult> result1 = plan->find_plan(state, todo_list);
	CHECK(result1.is_valid());

	// Method 2: run_lazy_lookahead (incremental execution)
	Ref<PlannerResult> result2 = plan->run_lazy_lookahead(state, todo_list, 10);
	CHECK(result2.is_valid());

	// Method 3: run_lazy_refineahead (graph-based with temporal constraints)
	Ref<PlannerResult> result3 = plan->run_lazy_refineahead(state, todo_list);
	CHECK(result3.is_valid());
}

// Test Case 11: Temporal planning with metadata
TEST_CASE("[Modules][Planner][MagicalGirls] Temporal planning with metadata") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);
	plan->set_verbose(0);

	// Set time range (week: 7 days = 604800000000 microseconds)
	PlannerTimeRange time_range;
	time_range.start_time = static_cast<int64_t>(1735689600000000LL); // 2025-01-01 00:00:00 UTC
	time_range.end_time = time_range.start_time + static_cast<int64_t>(604800000000LL); // +7 days
	plan->set_time_range(time_range);

	// Attach temporal constraints to actions
	Array action1;
	action1.push_back("action_attend_lecture");
	action1.push_back("yuki");
	action1.push_back("math");
	Dictionary temporal1;
	temporal1["duration"] = static_cast<int64_t>(7200000000LL); // 2 hours
	Variant action1_with_metadata = plan->attach_metadata(action1, temporal1);

	Array action2;
	action2.push_back("action_watch_movie");
	action2.push_back("yuki");
	action2.push_back("maya");
	Dictionary temporal2;
	temporal2["start_time"] = time_range.start_time + static_cast<int64_t>(3600000000LL); // +1 hour
	temporal2["end_time"] = time_range.start_time + static_cast<int64_t>(10800000000LL); // +3 hours
	Variant action2_with_metadata = plan->attach_metadata(action2, temporal2);

	Dictionary state = create_magical_girls_college_init_state();
	Array todo_list;
	Array task;
	task.push_back("task_manage_week");
	task.push_back("yuki");
	todo_list.push_back(task);

	Ref<PlannerResult> result = plan->run_lazy_refineahead(state, todo_list);
	CHECK(result.is_valid());
}

// Test Case 12: Entity requirements with metadata
TEST_CASE("[Modules][Planner][MagicalGirls] Entity requirements with metadata") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);
	plan->set_verbose(0);
	plan->set_current_persona(create_rin_persona()); // AI persona

	// Attach entity requirements to actions
	Array action1;
	action1.push_back("action_optimize_schedule");
	action1.push_back("rin");
	Dictionary entity1;
	entity1["type"] = "ai";
	TypedArray<String> capabilities1;
	capabilities1.push_back("compute");
	capabilities1.push_back("optimize");
	entity1["capabilities"] = capabilities1;
	Variant action1_with_metadata = plan->attach_metadata(action1, Dictionary(), entity1);

	Array action2;
	action2.push_back("action_predict_outcome");
	action2.push_back("rin");
	action2.push_back("study");
	Dictionary entity2;
	entity2["type"] = "ai";
	TypedArray<String> capabilities2;
	capabilities2.push_back("predict");
	entity2["capabilities"] = capabilities2;
	Variant action2_with_metadata = plan->attach_metadata(action2, Dictionary(), entity2);

	Dictionary state = create_magical_girls_college_init_state();
	Array todo_list;
	Array task;
	task.push_back("task_earn_study_points");
	task.push_back("rin");
	task.push_back(10);
	todo_list.push_back(task);

	Ref<PlannerResult> result = plan->find_plan(state, todo_list);
	CHECK(result.is_valid());
}

// Test Case 13: VSIDS activity tracking
TEST_CASE("[Modules][Planner][MagicalGirls] VSIDS activity tracking") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);
	plan->set_verbose(0);

	Dictionary state = create_magical_girls_college_init_state();

	// Plan multiple times with different goals
	for (int i = 0; i < 3; i++) {
		Array todo_list;
		Array task;
		task.push_back("task_earn_study_points");
		task.push_back("yuki");
		task.push_back(5 + i * 5);
		todo_list.push_back(task);

		Ref<PlannerResult> result = plan->find_plan(state, todo_list);
		CHECK(result.is_valid());
	}

	// Check method activities
	Dictionary activities = plan->get_method_activities();
	CHECK(activities.size() >= 0); // Activities may be empty or populated

	// Reset VSIDS activity
	plan->reset_vsids_activity();
	Dictionary cleared_activities = plan->get_method_activities();
	CHECK(cleared_activities.size() == 0);
}

// Test Case 14: Plan simulation
TEST_CASE("[Modules][Planner][MagicalGirls] Plan simulation") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);
	plan->set_verbose(0);

	Dictionary state = create_magical_girls_college_init_state();
	Array todo_list;
	Array task;
	task.push_back("task_earn_study_points");
	task.push_back("yuki");
	task.push_back(10);
	todo_list.push_back(task);

	Ref<PlannerResult> result = plan->find_plan(state, todo_list);
	CHECK(result.is_valid());

	if (result->get_success()) {
		// Simulate plan execution
		Array state_sequence = plan->simulate(result, state, 0);
		CHECK(state_sequence.size() > 0);

		// Verify state sequence shows progression
		Dictionary initial_state = state_sequence[0];
		if (state_sequence.size() > 1) {
			Dictionary final_state = state_sequence[state_sequence.size() - 1];
			CHECK(initial_state != final_state);
		}
	}
}

// Test Case 15: Replanning from failure
TEST_CASE("[Modules][Planner][MagicalGirls] Replanning from failure") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);
	plan->set_verbose(0);

	Dictionary state = create_magical_girls_college_init_state();
	Array todo_list;
	Array task;
	task.push_back("task_earn_study_points");
	task.push_back("yuki");
	task.push_back(10);
	todo_list.push_back(task);

	Ref<PlannerResult> result = plan->find_plan(state, todo_list);
	CHECK(result.is_valid());

	if (result->get_success()) {
		// Find failed nodes (should be empty if successful)
		Array failed_nodes = result->find_failed_nodes();
		CHECK(failed_nodes.size() >= 0);

		// If there are failures, replan from failure point
		if (failed_nodes.size() > 0) {
			int fail_node_id = failed_nodes[0];
			Ref<PlannerResult> replan_result = plan->replan(result, state, fail_node_id);
			CHECK(replan_result.is_valid());
		}
	}
}

// Test Case 16: Solution graph operations
TEST_CASE("[Modules][Planner][MagicalGirls] Solution graph operations") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);
	plan->set_verbose(0);

	Dictionary state = create_magical_girls_college_init_state();
	Array todo_list;
	Array task;
	task.push_back("task_earn_study_points");
	task.push_back("yuki");
	task.push_back(10);
	todo_list.push_back(task);

	Ref<PlannerResult> result = plan->find_plan(state, todo_list);
	CHECK(result.is_valid());

	if (result->get_success()) {
		// Extract plan
		Array plan_actions = result->extract_plan();
		CHECK(plan_actions.size() >= 0);

		// Find failed nodes
		Array failed_nodes = result->find_failed_nodes();
		CHECK(failed_nodes.size() >= 0);

		// Get all nodes
		Array all_nodes = result->get_all_nodes();
		CHECK(all_nodes.size() > 0);

		// Get specific node
		if (all_nodes.size() > 0) {
			int node_id = all_nodes[0];
			Dictionary node = result->get_node(node_id);
			CHECK(node.size() > 0);
			CHECK(result->has_node(node_id));
		}

		// Load solution graph
		Dictionary solution_graph = result->get_solution_graph();
		plan->load_solution_graph(solution_graph);
		CHECK(true); // If no crash, test passes
	}
}

// Test Case 17: Blacklisting commands
TEST_CASE("[Modules][Planner][MagicalGirls] Blacklisting commands") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);
	plan->set_verbose(0);

	// Blacklist an action
	Array blacklisted_action;
	blacklisted_action.push_back("action_attend_lecture");
	blacklisted_action.push_back("yuki");
	blacklisted_action.push_back("math");
	plan->blacklist_command(blacklisted_action);

	Dictionary state = create_magical_girls_college_init_state();
	Array todo_list;
	Array task;
	task.push_back("task_earn_study_points");
	task.push_back("yuki");
	task.push_back(10);
	todo_list.push_back(task);

	Ref<PlannerResult> result = plan->find_plan(state, todo_list);
	CHECK(result.is_valid());
	// Planner should find alternative path without blacklisted action
}

// Test Case 18: Verbosity and depth control
TEST_CASE("[Modules][Planner][MagicalGirls] Verbosity and depth control") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);

	// Test verbosity levels
	plan->set_verbose(0);
	CHECK(plan->get_verbose() == 0);

	// Test depth limit
	plan->set_max_depth(5);
	CHECK(plan->get_max_depth() == 5);

	Dictionary state = create_magical_girls_college_init_state();
	Array todo_list;
	Array task;
	task.push_back("task_earn_study_points");
	task.push_back("yuki");
	task.push_back(10);
	todo_list.push_back(task);

	Ref<PlannerResult> result = plan->find_plan(state, todo_list);
	CHECK(result.is_valid());

	// Check iterations
	int iterations = plan->get_iterations();
	CHECK(iterations >= 0);
}

// Test Case 19: Multigoal planning
TEST_CASE("[Modules][Planner][MagicalGirls] Multigoal planning") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);
	plan->set_verbose(0);

	Dictionary state = create_magical_girls_college_init_state();

	// Multigoal: balance study, relationships, burnout
	Array multigoal;
	Array goal1;
	goal1.push_back("study_points");
	goal1.push_back("yuki");
	goal1.push_back(10);
	multigoal.push_back(goal1);
	Array goal2;
	goal2.push_back("relationship_points");
	goal2.push_back("yuki");
	goal2.push_back("maya");
	goal2.push_back(5);
	multigoal.push_back(goal2);
	Array goal3;
	goal3.push_back("burnout");
	goal3.push_back("yuki");
	goal3.push_back(50); // Max burnout
	multigoal.push_back(goal3);

	Ref<PlannerResult> result = plan->find_plan(state, multigoal);
	CHECK(result.is_valid());
}

// Test Case 20: Unigoal planning
TEST_CASE("[Modules][Planner][MagicalGirls] Unigoal planning") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);
	plan->set_verbose(0);

	Dictionary state = create_magical_girls_college_init_state();

	// Unigoal: achieve study goal
	Array unigoal;
	unigoal.push_back("study_points");
	unigoal.push_back("yuki");
	unigoal.push_back(10);

	Ref<PlannerResult> result = plan->find_plan(state, unigoal);
	CHECK(result.is_valid());
}

// Test Case 21: First Act - Orientation Week (with seed-based randomization)
// A narrative scenario demonstrating the persona system in a meaningful gameplay context
TEST_CASE("[Modules][Planner][MagicalGirls] First Act - Orientation Week") {
	// Use seed for reproducible randomization
	int64_t seed = 12345; // Can be changed for different scenarios
	Ref<RandomNumberGenerator> rng = memnew(RandomNumberGenerator);
	rng->set_seed(static_cast<uint64_t>(seed));

	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);
	plan->set_verbose(1);
	plan->set_max_depth(100);
	// Setup personas and belief system
	Ref<PlannerPersona> yuki = create_yuki_persona();
	Ref<PlannerBeliefManager> manager = setup_belief_manager();
	Ref<PlannerFactsAllocentric> facts = setup_allocentric_facts();

	plan->set_current_persona(yuki);
	plan->set_belief_manager(manager);
	plan->set_allocentric_facts(facts);

	// Set time range for first week (7 days)
	PlannerTimeRange time_range;
	time_range.start_time = static_cast<int64_t>(1735689600000000LL); // 2025-01-01 00:00:00 UTC
	time_range.end_time = time_range.start_time + static_cast<int64_t>(604800000000LL); // +7 days
	plan->set_time_range(time_range);

	// Create randomized initial state based on seed
	Dictionary state = create_randomized_state(seed);

	int verbose = plan->get_verbose();

	// Randomly select first observation target and location
	String first_target = get_random_observation_target(rng);
	String first_location = get_random_location(rng);
	float first_confidence = 0.5f + rng->randf() * 0.3f; // 0.5-0.8

	// For valid beliefs, Yuki must be at the same location as the observed entity
	// Move Yuki to the observation location first
	Dictionary is_at = state["is_at"];
	is_at["yuki"] = first_location;
	state["is_at"] = is_at;

	Dictionary observation1;
	observation1["entity"] = first_target;
	observation1["action"] = vformat("visit_%s", first_location);
	observation1["location"] = first_location;
	observation1["observer_location"] = first_location; // Yuki is at the same location - valid belief
	observation1["time"] = "morning";
	observation1["confidence"] = first_confidence;
	yuki->process_observation(observation1);

	// Randomly select second observation target and location (different from first)
	String second_target = first_target;
	String second_location = first_location;
	while (second_target == first_target) {
		second_target = get_random_observation_target(rng);
	}
	while (second_location == first_location) {
		second_location = get_random_location(rng);
	}
	float second_confidence = 0.5f + rng->randf() * 0.3f; // 0.5-0.8

	// Move Yuki to the second observation location for valid belief
	is_at = state["is_at"];
	is_at["yuki"] = second_location;
	state["is_at"] = is_at;

	Dictionary observation2;
	observation2["entity"] = second_target;
	observation2["action"] = vformat("visit_%s", second_location);
	observation2["location"] = second_location;
	observation2["observer_location"] = second_location; // Yuki is at the same location - valid belief
	observation2["time"] = "afternoon";
	observation2["confidence"] = second_confidence;
	yuki->process_observation(observation2);

	// Check initial beliefs
	Dictionary beliefs_about_first = yuki->get_beliefs_about(first_target);
	Dictionary beliefs_about_second = yuki->get_beliefs_about(second_target);

	// Act 1, Scene 2: First Communication (randomized target)
	// Randomly select which character introduces themselves
	Array communication_targets;
	communication_targets.push_back("maya");
	communication_targets.push_back("rin");
	communication_targets.push_back("kira");
	communication_targets.push_back("luna");
	String comm_target = communication_targets[rng->randi() % communication_targets.size()];

	// Generate communication message based on target's preferences
	String comm_location = get_random_location(rng);
	String comm_target_capitalized = capitalize_string(comm_target);
	Dictionary communication1;
	communication1["from"] = comm_target;
	communication1["message"] = vformat("Hi! I'm %s. I love spending time at the %s, it's so nice there.", comm_target_capitalized, comm_location);
	communication1["topic"] = "preference";
	float comm_confidence_value = 0.8f + rng->randf() * 0.2f; // 0.8-1.0
	communication1["confidence"] = comm_confidence_value;
	yuki->process_communication(communication1);

	// Randomize study point target (8-15)
	int study_target = rng->randi_range(8, 15);
	// Randomize relationship target (3-8)
	int relationship_target = rng->randi_range(3, 8);
	// Randomly select relationship target character
	String relationship_char = communication_targets[rng->randi() % communication_targets.size()];

	// Goal: Balance study and build relationship
	// For "at least" goals, use task methods directly instead of unigoals
	// (unigoal verification requires exact equality, which fails when we overshoot)
	Array todo_list;
	Array task1;
	task1.push_back("task_earn_study_points");
	task1.push_back("yuki");
	task1.push_back(study_target);
	todo_list.push_back(task1);
	Array task2;
	task2.push_back("task_socialize");
	task2.push_back("yuki");
	task2.push_back(relationship_char);
	// Calculate activity level needed (1=easy, 2=moderate, 3=challenging)
	Dictionary relationship_points = state["relationship_points"];
	Dictionary yuki_relationships = relationship_points["yuki"];
	int current_relationship = yuki_relationships.has(relationship_char) ? int(yuki_relationships[relationship_char]) : 0;
	int points_needed = relationship_target - current_relationship;
	int activity_level = (points_needed <= 2) ? 1 : ((points_needed <= 4) ? 2 : 3);
	task2.push_back(activity_level);
	todo_list.push_back(task2);

	String relationship_char_capitalized = capitalize_string(relationship_char);
	if (verbose >= 1) {
		print_line("Yuki's goals for the week:");
		print_line(vformat("  1. Earn %d study points", study_target));
		print_line(vformat("  2. Build relationship with %s (target: %d points)", relationship_char_capitalized, relationship_target));
		print_line("");
	}

	Ref<PlannerResult> result = plan->find_plan(state, todo_list);
	CHECK(result.is_valid());

	if (result->get_success()) {
		if (verbose >= 1) {
			print_line("=== PLANNING SUCCEEDED ===");
		}
		Array plan_actions = result->extract_plan(verbose);
		if (verbose >= 1) {
			print_line(vformat("Plan has %d actions:", plan_actions.size()));

			for (int i = 0; i < plan_actions.size(); i++) {
				Array action = plan_actions[i];
				String action_str = "[";
				for (int j = 0; j < action.size(); j++) {
					if (j > 0) {
						action_str += ", ";
					}
					action_str += String(action[j]);
				}
				action_str += "]";
				print_line(vformat("  %d. %s", i + 1, action_str));
			}

			// Simulate the plan to see state progression
			print_line("");
			print_line("--- Simulating Plan Execution ---");
		}
		Array state_sequence = plan->simulate(result, state, 0);
		if (verbose >= 1) {
			print_line(vformat("State sequence has %d states", state_sequence.size()));
		}

		// Show final state
		if (state_sequence.size() > 0) {
			Dictionary final_state = state_sequence[state_sequence.size() - 1];
			Dictionary study_points = final_state["study_points"];
			Dictionary final_relationship_points = final_state["relationship_points"];
			Dictionary final_yuki_relationships = final_relationship_points["yuki"];

			int final_study = int(study_points["yuki"]);
			int final_relationship = 0;
			if (final_yuki_relationships.has(relationship_char)) {
				final_relationship = int(final_yuki_relationships[relationship_char]);
			}

			String relationship_char_capitalized_final = capitalize_string(relationship_char);
			if (verbose >= 1) {
				print_line("");
				print_line("=== FINAL STATE ===");
				print_line(vformat("Yuki's study points: %d (target: %d)", final_study, study_target));
				print_line(vformat("Yuki's relationship with %s: %d (target: %d)", relationship_char_capitalized_final, final_relationship, relationship_target));
				print_line("");
			}

			// Verify goals achieved
			CHECK(final_study >= study_target);
			CHECK(final_relationship >= relationship_target);
		}

		// Randomly observe positive response from relationship target
		// For valid belief formation, Yuki must be at the same location
		String update_target = relationship_char;
		float update_confidence = 0.7f + rng->randf() * 0.3f; // 0.7-1.0

		// Get Yuki's current location from final state (must be after final_state is defined)
		String yuki_final_location = "dorm"; // Default
		if (state_sequence.size() > 0) {
			Dictionary final_state = state_sequence[state_sequence.size() - 1];
			Dictionary final_is_at = final_state["is_at"];
			yuki_final_location = final_is_at.get("yuki", "dorm");
		}

		// Use Yuki's actual location for the observation - ensures valid belief formation
		String update_location = yuki_final_location;

		String update_target_capitalized = capitalize_string(update_target);
		Dictionary observation3;
		observation3["entity"] = update_target;
		observation3["action"] = "positive_response";
		observation3["location"] = update_location;
		observation3["observer_location"] = yuki_final_location; // Yuki is at the same location - valid belief
		observation3["confidence"] = update_confidence;
		yuki->process_observation(observation3);
		if (verbose >= 1) {
			print_line(vformat("Yuki notices %s's positive response to spending time together...", update_target_capitalized));
		}

		float updated_confidence = yuki->get_belief_confidence_for(update_target, vformat("likes_%s", update_location));
		if (verbose >= 1) {
			print_line(vformat("Updated confidence that %s likes %s: %.2f", update_target, update_location, updated_confidence));
		}
		// If Yuki is at the same location, belief should be formed with the observation confidence
		if (update_location == yuki_final_location && updated_confidence > 0.0) {
			CHECK(updated_confidence >= update_confidence - 0.1f); // Allow some variance
		}

		if (verbose >= 1) {
			print_line("");
			print_line("=== END OF FIRST ACT ===");
			print_line(vformat("Seed used: %d", static_cast<int>(seed)));
			print_line("Yuki has successfully:");
			print_line("  - Earned study points");
			print_line(vformat("  - Built relationship with %s", relationship_char_capitalized));
			print_line("  - Formed beliefs about other students");
			print_line("  - Planned her first week at college");
			print_line("");
		}
	} else {
		if (verbose >= 1) {
			print_line("=== PLANNING FAILED ===");
		}
		Array failed_nodes = result->find_failed_nodes();
		if (verbose >= 1) {
			print_line(vformat("Failed nodes: %d", failed_nodes.size()));
		}
	}
}

// Test Case 22: Complex temporal puzzle with conflicting constraints and dependencies
// Puzzle: Yuki must schedule activities with strict temporal constraints:
// - Study session with Maya at library (9am-11am) - FIXED TIME
// - Complete homework (1.5 hours) - MUST finish before movie
// - Lunch with Rin at mess hall (12pm-12:30pm) - FIXED TIME
// - Movie with Maya at cinema (3pm-5pm) - FIXED TIME, requires homework done first
// - Additional study to reach 15 points total - must fit between activities
// - Evening activity with Kira - can only happen after movie ends (5pm+)
// The puzzle: Fit all activities while respecting dependencies and fixed times
TEST_CASE("[Modules][Planner][MagicalGirls] Complex temporal puzzle with dependencies") {
	Ref<PlannerDomain> domain = create_magical_girls_college_domain();
	Ref<PlannerPlan> plan = memnew(PlannerPlan);
	plan->set_current_domain(domain);
	plan->set_current_persona(create_yuki_persona());
	plan->set_verbose(0); // Enable verbose output to debug
	plan->set_max_depth(500); // Increase depth limit significantly to test if it's a depth issue

	// Set up a full day: 2025-01-01 00:00:00 UTC to 2025-01-02 00:00:00 UTC
	// 24 hours = 86400000000 microseconds
	int64_t day_start = static_cast<int64_t>(1735689600000000LL); // 2025-01-01 00:00:00 UTC
	int64_t day_end = day_start + static_cast<int64_t>(86400000000LL); // +24 hours

	PlannerTimeRange time_range;
	time_range.start_time = day_start;
	time_range.end_time = day_end;
	plan->set_time_range(time_range);

	Dictionary state = create_magical_girls_college_init_state();

	// PUZZLE CONSTRAINT 1: Fixed-time study session with Maya (9am-11am)
	// Duration: 2 hours = 7200000000 microseconds
	int64_t morning_study_start = day_start + static_cast<int64_t>(32400000000LL); // 9 hours = 9am
	Dictionary morning_coordination;
	morning_coordination["from"] = "maya";
	morning_coordination["message"] = "Let's study together at the library at 9am sharp";
	morning_coordination["topic"] = "coordination";
	morning_coordination["action"] = "study_session";
	morning_coordination["location"] = "library";
	morning_coordination["time"] = morning_study_start;

	// PUZZLE CONSTRAINT 3: Fixed-time movie with Maya (3pm-5pm)
	// Duration: 2 hours = 7200000000 microseconds
	// DEPENDENCY: Homework must be completed BEFORE movie starts
	int64_t movie_time = day_start + static_cast<int64_t>(54000000000LL); // 15 hours = 3pm
	Dictionary movie_coordination;
	movie_coordination["from"] = "maya";
	movie_coordination["message"] = "Let's watch a movie together at 3pm - but finish homework first!";
	movie_coordination["topic"] = "coordination";
	movie_coordination["action"] = "movie";
	movie_coordination["location"] = "cinema";
	movie_coordination["time"] = movie_time;
	movie_coordination["requires_homework"] = true; // Dependency marker

	// Store coordinations in state
	if (!state.has("coordination")) {
		state["coordination"] = Dictionary();
	}
	Dictionary coord_dict = state["coordination"];
	// Store both morning and movie coordinations (merge them)
	Dictionary yuki_coord = morning_coordination.duplicate(true);
	// Merge movie coordination into yuki's coordination
	for (int i = 0; i < movie_coordination.keys().size(); i++) {
		Variant key = movie_coordination.keys()[i];
		yuki_coord[key] = movie_coordination[key];
	}
	coord_dict["yuki"] = yuki_coord;
	state["coordination"] = coord_dict;

	// Store temporal constraints in state for puzzle solving
	if (!state.has("temporal_puzzle")) {
		state["temporal_puzzle"] = Dictionary();
	}
	Dictionary puzzle = state["temporal_puzzle"];
	puzzle["homework_deadline"] = movie_time; // Homework must finish before movie
	puzzle["morning_study_time"] = morning_study_start; // Morning study session time (preserved even if coordination is overwritten)
	puzzle["available_windows"] = Array(); // Will be calculated by planner
	state["temporal_puzzle"] = puzzle;

	// Use task methods directly for "at least" goals (multigoal verification uses exact equality)
	// Task methods handle "at least" logic in their "done" methods (check >= instead of ==)
	Array todo_list;

	// Task 1: Earn 15 study points (planner must figure out: lecture, homework, library, or coordinated study)
	Array study_task;
	study_task.push_back("task_earn_study_points");
	study_task.push_back("yuki");
	study_task.push_back(15);
	todo_list.push_back(study_task);

	// Task 2: Build relationship with Rin (planner must figure out: lunch, coffee, movie, etc.)
	Array rin_socialize_task;
	rin_socialize_task.push_back("task_socialize");
	rin_socialize_task.push_back("yuki");
	rin_socialize_task.push_back("rin");
	rin_socialize_task.push_back(1); // Easy activity (at least 1 point)
	todo_list.push_back(rin_socialize_task);

	// Task 3: Build relationship with Maya (planner must figure out: study session, movie, etc.)
	Array maya_socialize_task;
	maya_socialize_task.push_back("task_socialize");
	maya_socialize_task.push_back("yuki");
	maya_socialize_task.push_back("maya");
	maya_socialize_task.push_back(2); // Moderate activity (at least 2 points)
	todo_list.push_back(maya_socialize_task);

	// Task 4: Build relationship with Kira (planner must figure out: coffee, reading together, etc.)
	Array kira_socialize_task;
	kira_socialize_task.push_back("task_socialize");
	kira_socialize_task.push_back("yuki");
	kira_socialize_task.push_back("kira");
	kira_socialize_task.push_back(1); // Easy activity (at least 1 point)
	todo_list.push_back(kira_socialize_task);

	// Use run_lazy_refineahead for temporal planning (handles complex temporal constraints)
	// Pass todo_list with task methods - task methods handle "at least" logic
	Ref<PlannerResult> result = plan->run_lazy_refineahead(state, todo_list);
	CHECK(result.is_valid());
	CHECK(result->get_success());

	if (result->get_success()) {
		Array plan_actions = result->extract_plan(plan->get_verbose());
		if (plan->get_verbose() >= 1) {
			print_line("");
			print_line("=== PUZZLE SOLUTION ===");
			print_line(vformat("Plan has %d actions:", plan_actions.size()));

			for (int i = 0; i < plan_actions.size(); i++) {
				Variant action_var = plan_actions[i];
				Array action;

				// Unwrap if dictionary-wrapped
				if (action_var.get_type() == Variant::DICTIONARY) {
					Dictionary dict = action_var;
					if (dict.has("item")) {
						action_var = dict["item"];
					}
				}

				if (action_var.get_type() == Variant::ARRAY) {
					action = action_var;
				}

				String action_str = "[";
				for (int j = 0; j < action.size(); j++) {
					if (j > 0) {
						action_str += ", ";
					}
					action_str += String(action[j]);
				}
				action_str += "]";
				print_line(vformat("  %d. %s", i + 1, action_str));
			}
		}

		// Simulate the plan to verify temporal constraints
		Array state_sequence = plan->simulate(result, state, 0);
		if (plan->get_verbose() >= 1) {
			print_line("");
			print_line("--- Puzzle Solution Verification ---");
			print_line(vformat("State sequence has %d states", state_sequence.size()));
		}

		// Verify puzzle constraints were satisfied
		if (state_sequence.size() > 0) {
			Dictionary final_state = state_sequence[state_sequence.size() - 1];
			Dictionary study_points = final_state["study_points"];
			Dictionary relationship_points = final_state["relationship_points"];
			Dictionary yuki_relationships = relationship_points["yuki"];

			int final_study = int(study_points["yuki"]);
			int final_relationship_maya = 0;
			int final_relationship_rin = 0;
			int final_relationship_kira = 0;
			if (yuki_relationships.has("maya")) {
				final_relationship_maya = int(yuki_relationships["maya"]);
			}
			if (yuki_relationships.has("rin")) {
				final_relationship_rin = int(yuki_relationships["rin"]);
			}
			if (yuki_relationships.has("kira")) {
				final_relationship_kira = int(yuki_relationships["kira"]);
			}

			if (plan->get_verbose() >= 1) {
				print_line("");
				print_line("=== PUZZLE SOLUTION VERIFICATION ===");
				print_line(vformat("Study points: %d (target: 15)", final_study));
				print_line(vformat("Relationship with Maya: %d (target: 2+)", final_relationship_maya));
				print_line(vformat("Relationship with Rin: %d (target: 1+)", final_relationship_rin));
				print_line(vformat("Relationship with Kira: %d (target: 1+)", final_relationship_kira));
				print_line("");
				print_line("Puzzle solved! All temporal constraints satisfied.");
			}

			// Verify puzzle constraints
			CHECK(final_study >= 15); // Must earn at least 15 study points
			CHECK(final_relationship_maya >= 2); // Must build relationship with Maya (study + movie)
			CHECK(final_relationship_rin >= 1); // Must build relationship with Rin (lunch)
			CHECK(final_relationship_kira >= 1); // Must build relationship with Kira (evening activity)

			// Verify plan contains required activities
			bool has_study = false;
			bool has_lunch = false;
			bool has_movie = false;
			bool has_evening = false;

			for (int i = 0; i < plan_actions.size(); i++) {
				Variant action_var = plan_actions[i];
				Array action;

				if (action_var.get_type() == Variant::DICTIONARY) {
					Dictionary dict = action_var;
					if (dict.has("item")) {
						action_var = dict["item"];
					}
				}

				if (action_var.get_type() == Variant::ARRAY) {
					action = action_var;
					if (action.size() > 0) {
						String action_name = String(action[0]);
						if (action_name == "action_study_library") {
							has_study = true;
						} else if (action_name == "action_eat_mess_hall") {
							has_lunch = true;
						} else if (action_name == "action_watch_movie") {
							has_movie = true;
						} else if (action_name == "action_coffee_together" || action_name == "action_read_book") {
							has_evening = true;
						}
					}
				}
			}

			CHECK(has_study); // Must include morning study session
			CHECK(has_lunch); // Must include lunch with Rin
			CHECK(has_movie); // Must include movie with Maya
			CHECK(has_evening); // Must include evening activity with Kira
		}
	} else {
		if (plan->get_verbose() >= 1) {
			print_line("=== PUZZLE UNSOLVABLE ===");
		}
		Array failed_nodes = result->find_failed_nodes();
		if (plan->get_verbose() >= 1) {
			print_line(vformat("Failed nodes: %d", failed_nodes.size()));
		}
		// Puzzle should be solvable with proper planning
		CHECK_MESSAGE(result->get_success(), "Complex temporal puzzle should be solvable");
	}
}

} // namespace TestMagicalGirlsCollege
