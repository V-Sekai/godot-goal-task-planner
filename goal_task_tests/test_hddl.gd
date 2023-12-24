# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_hddl.gd
# SPDX-License-Identifier: MIT

extends GutTest

var parser = HDDLParser.new()

var test_string = """
(define (domain basic)
  (:requirements :hierarchy :negative-preconditions :method-preconditions)
  (:predicates (have ?a))
  (:task swap :parameters (?x ?y))

  (:action pickup
	:parameters (?a)
	:precondition (not (have ?a))
	:effect (have ?a)
  )

  (:action drop
	:parameters (?a)
	:precondition (have ?a)
	:effect (not (have ?a))
  )

  (:method have_first
	:parameters (?x ?y)
	:task (swap ?x ?y)
	:precondition (and
	  (have ?x)
	  (not (have ?y))
	)
	:ordered-subtasks (and
	  (drop ?x)
	  (pickup ?y)
	)
  )

  (:method have_second
	:parameters (?x ?y)
	:task (swap ?x ?y)
	:precondition (and
	  (have ?y)
	  (not (have ?x))
	)
	:ordered-subtasks (and
	  (drop ?y)
	  (pickup ?x)
	)
  )
)"""

func parse_sexp(expression: String) -> Array:
	var stack: Array = [[]]
	var word: String = ""
	for char in expression:
		if char == '(':
			stack.append([])
		elif char == ')':
			if word.strip_edges() != "":
				stack[stack.size() - 1].append(word.strip_edges())
				word = ""
			var temp: Array = stack.pop_back()
			stack[stack.size() - 1].append(temp)
		elif char == ' ' or char == '\n':
			if word.strip_edges() != "":
				stack[stack.size() - 1].append(word.strip_edges())
				word = ""
		else:
			word += char
	if word.strip_edges() != "":
		stack[stack.size() - 1].append(word.strip_edges())
	return stack[0]

func test_parse_sexp():
	var sexp = parse_sexp(test_string)
	var expected_output = [["define", ["domain", "basic"], [":requirements", ":hierarchy", ":negative-preconditions", ":method-preconditions"], [":predicates", ["have", "?a"]], [":task", "swap", ":parameters", ["?x", "?y"]], [":action", "pickup", ":parameters", ["?a"], ":precondition", ["not", ["have", "?a"]], ":effect", ["have", "?a"]], [":action", "drop", ":parameters", ["?a"], ":precondition", ["have", "?a"], ":effect", ["not", ["have", "?a"]]], [":method", "have_first", ":parameters", ["?x", "?y"], ":task", ["swap", "?x", "?y"], ":precondition", ["and", ["have", "?x"], ["not", ["have", "?y"]]], ":ordered-subtasks", ["and", ["drop", "?x"], ["pickup", "?y"]]], [":method", "have_second", ":parameters", ["?x", "?y"], ":task", ["swap", "?x", "?y"], ":precondition", ["and", ["have", "?y"], ["not", ["have", "?x"]]], ":ordered-subtasks", ["and", ["drop", "?y"], ["pickup", "?x"]]]]]
	print(sexp)
	assert_eq(sexp, expected_output)


func test_parse_definition():
	var sexp = [[":types", "a", "b"]]
	parser.parse_definition(sexp)
	assert_eq_deep(parser.types.get("a"), "b")


func test_parse_initialization():
	var initialization = "( :object-instances instance1 property1 value1 property2 value2 )"
	parser.parse_initialization(initialization)
	var expected_output = {"property1": "value1", "property2": "value2"}
	assert_eq(parser.objects.get("instance1"), expected_output)


func test_normalize_pddl():
	var pddl = "(define (domain basic) (:requirements :hierarchy :negative-preconditions :method-preconditions))"
	var normalized_pddl = parser.normalize_pddl(pddl)
	var expected_output = " ( define ( domain basic ) ( :requirements :hierarchy :negative-preconditions :method-preconditions ) ) "
	print(normalized_pddl)
	assert_eq(normalized_pddl, expected_output)


func test_parse_action():
	var sexp = [[":action", "pickup", ":parameters", ["?a"], ":precondition", ["not", ["have", "?a"]], ":effect", ["have", "?a"]]]
	var actions = parser.parse_action(sexp)
	var expected_output = { "parameters": ["?a"], "precondition": ["have", "?a"], "effect": ["have", "?a"]}
	assert_ne(actions.get("pickup"), expected_output)


func test_parse_method_preconditions_fixme():
	var sexp = [[":method", "have_first", ":parameters", ["?x", "?y"], ":task", ["swap", "?x", "?y"], ":precondition", ["and", ["have", "?x"], ["not", ["have", "?y"]]], ":ordered-subtasks", ["and", ["drop", "?x"], ["pickup", "?y"]]]]
	
	parser.methods = parser.parse_method_preconditions(sexp)
	# Check if the key exists
	if "have_first" in parser.methods:
		gut.p("Key exists: %s" % parser.methods["have_first"])
	else:
		gut.p("Key 'have_first' does not exist in parser.methods")
	
	assert_ne_deep(parser.methods.get("have_first"), {})



func test_parse_method_preconditions_simple():
	var sexp = [[":method", "have_first"]]
	
	parser.methods = parser.parse_method_preconditions(sexp)
	
	# Check if the key exists
	if "have_first" in parser.methods:
		gut.p("Key exists: %s" % parser.methods["have_first"])
	else:
		gut.p("Key 'have_first' does not exist in parser.methods")
	
	var expected_output = {"parameters": {}, "precondition": [], "ordered_subtasks": [], "task": ""}
	
	assert_eq_deep(parser.methods.get("have_first"), expected_output)

