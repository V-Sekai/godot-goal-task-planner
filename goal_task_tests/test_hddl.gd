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

func test_parse_sexp():
	var sexp = parser.parse_sexp(test_string)
	var expected_output = [["define", ["domain", "basic"], [":requirements", ":hierarchy", ":negative-preconditions", ":method-preconditions"], [":predicates", ["have", "?a"]], [":task", "swap", ":parameters", ["?x", "?y"]], [":action", "pickup", ":parameters", ["?a"], ":precondition", ["not", ["have", "?a"]], ":effect", ["have", "?a"]], [":action", "drop", ":parameters", ["?a"], ":precondition", ["have", "?a"], ":effect", ["not", ["have", "?a"]]], [":method", "have_first", ":parameters", ["?x", "?y"], ":task", ["swap", "?x", "?y"], ":precondition", ["and", ["have", "?x"], ["not", ["have", "?y"]]], ":ordered-subtasks", ["and", ["drop", "?x"], ["pickup", "?y"]]], [":method", "have_second", ":parameters", ["?x", "?y"], ":task", ["swap", "?x", "?y"], ":precondition", ["and", ["have", "?y"], ["not", ["have", "?x"]]], ":ordered-subtasks", ["and", ["drop", "?y"], ["pickup", "?x"]]]]]
	print(sexp)
	assert_eq(sexp, expected_output)


func test_parse_method_preconditions():
	var sexp = [[":method", "have_first", ":parameters", ["?x", "?y"], ":task", ["swap", "?x", "?y"], ":precondition", ["and", ["have", "?x"], ["not", ["have", "?y"]]], ":ordered-subtasks", ["and", ["drop", "?x"], ["pickup", "?y"]]]]
	
	parser.parse_method_preconditions(sexp)
	
	# Check if the key exists
	if "have_first" in parser.methods:
		gut.p("Key exists: %s" % parser.methods["have_first"])
	else:
		gut.p("Key 'have_first' does not exist in parser.methods")
	
	var expected_output = {"parameters": {"?x": "?y"}, "task": "swap", "precondition": [["have", "?x"], ["not", ["have", "?y"]]], "ordered_subtasks": [["drop", "?x"], ["pickup", "?y"]]}
	
	assert_ne_deep(parser.get("have_first"), expected_output)
	

func test_parse_definition():
	var sexp = [[":types", "a", "b"]]
	parser.parse_definition(sexp)
	assert_eq_deep(parser.types.get("a"), "b")


func test_parse_initialization():
	var initialization = "( :object-instances instance1 property1 value1 property2 value2 )"
	parser.parse_initialization(initialization)
	var expected_output = {"property1": "value1", "property2": "value2"}
	assert_eq(parser.objects.get("instance1"), expected_output)


func test_parse_action():
	var sexp = [[":action", "pickup", ":parameters", ["?a"], ":precondition", ["not", ["have", "?a"]], ":effect", ["have", "?a"]]]
	var actions = parser.parse_action(sexp)
	var expected_output = { "parameters": ["?a"], "precondition": ["have", "?a"], "effect": ["have", "?a"]}
	assert_ne(actions.get("pickup"), expected_output)


func test_normalize_pddl():
	var pddl = "(define (domain basic) (:requirements :hierarchy :negative-preconditions :method-preconditions))"
	var normalized_pddl = parser.normalize_pddl(pddl)
	var expected_output = " ( define ( domain basic ) ( :requirements :hierarchy :negative-preconditions :method-preconditions ) ) "
	print(normalized_pddl)
	assert_eq(normalized_pddl, expected_output)
