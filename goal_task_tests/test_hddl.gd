extends GutTest

var parser = HDDLParser.new()

func test_parse_sexp():
	var sexp = "(define (domain blocks) (:requirements :strips :typing))"
	var expected_output = [["define", ["domain", "blocks"], [":requirements", ":strips", ":typing"]]]
	print(parser.parse_sexp(sexp))
	assert_eq(parser.parse_sexp(sexp), expected_output)
