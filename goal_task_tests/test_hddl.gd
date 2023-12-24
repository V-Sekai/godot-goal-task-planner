extends GutTest

var parser = HDDLParser.new()

func test_parse_sexp():
	var sexp = "(define (domain blocks) (:requirements :strips :typing))"
	var expected_output = [["define", ["domain", "blocks"], [":requirements", ":strips", ":typing"]]]
	
	assert_eq(parser.parse_sexp(sexp), expected_output)

func test_normalize_pddl():
	var pddl = "(define (problem blocks-1)\n(:domain blocks))"
	var result = parser.normalize_pddl(pddl)
	assert_eq(result, "( define ( problem blocks-1 )\n( :domain blocks ) )")

func test_parse_definition():
	var definition = "(define (problem blocks-1) (:domain blocks))"
	parser.parse_definition(definition)
	assert_eq(parser.types, {})
	assert_eq(parser.objects, {})
	assert_eq(parser.actions, {})
	assert_eq(parser.methods, {})


func test_parse_action():
	var action: String = "(:action pickup
		:parameters (?a)
		:precondition (not (have ?a))
		:effect (have ?a)
		)"
	var sexp: Array[Array] = parser.parse_sexp(action)
	print(sexp)
	assert_true(sexp.size() == 1)
	var pickup = parser.parse_action(sexp)
	assert_eq_deep(pickup["parameters"], ["?a"])
	assert_eq_deep(pickup["precondition"], ["not", "have", "?a"])
	assert_eq_deep(pickup["effect"], ["have", "?a"])
	

func test_parse_method_preconditions():
	var method = "(:method transport :parameters (?a - block ?b - block) :task (move ?a ?b) :precondition (and (clear ?b) (on-table ?a)) :ordered-subtasks ((pickup ?a) (putdown ?a ?b)))"
	var sexp: Array[Array] = parser.parse_sexp(method)
	print(sexp)
	assert_true(sexp.size() == 1)
	parser.parse_method_preconditions(sexp)
	assert_eq(parser.methods["transport"]["parameters"] , {"?a": "- block", "?b": "- block"})
	assert_eq(parser.methods["transport"]["task"] ,"(move ?a ?b)")
	assert_eq(parser.methods["transport"]["precondition"], ["and", "(clear ?b)", "(on-table ?a)"])
	assert_eq(parser.methods["transport"]["ordered_subtasks"], ["(pickup ?a)", "(putdown ?a ?b)"])
