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
