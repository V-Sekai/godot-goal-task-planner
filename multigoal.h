/**************************************************************************/
/*  multigoal.h                                                           */
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

// SPDX-FileCopyrightText: 2021 University of Maryland
// SPDX-License-Identifier: BSD-3-Clause-Clear
// Author: Dana Nau <nau@umd.edu>, July 7, 2021

#include "core/io/resource.h"
#include "core/variant/dictionary.h"

class PlannerMultigoal : public Resource {
	GDCLASS(PlannerMultigoal, Resource);

private:
	Dictionary state;

public:
	PlannerMultigoal(String p_multigoal_name = "", Dictionary p_state_variables = Dictionary());
	Array get_goal_variables() const;

	Dictionary get_goal_conditions_for_variable(const String &p_variable) const;
	Variant get_goal_value(const String &p_variable, const String &p_argument) const;
	bool has_goal_condition(const String &p_variable, const String &p_argument) const;

	static Array method_split_multigoal(const Dictionary &p_state, const Ref<PlannerMultigoal> &p_multigoal);
	static Variant method_verify_multigoal(const Dictionary &p_state, const String &p_method, const Ref<PlannerMultigoal> &p_multigoal, int p_depth, int p_verbose);
	static Dictionary method_goals_not_achieved(const Dictionary &p_state, const Ref<PlannerMultigoal> &p_multigoal);

protected:
	static void _bind_methods();
};
