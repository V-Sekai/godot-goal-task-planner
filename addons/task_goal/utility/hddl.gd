class_name HDDLParser

var types = {}
var objects = {}
var actions = {}
var methods = {}


func parse_sexp(sexp: String) -> Array:
    var stack = [[]]
    var word = ""
    for char in sexp:
        if char == '(':
            stack.append([])
        elif char == ')':
            if word:
                stack[-1].append(word.strip())
                word = ""
            temp = stack.pop()
            stack[-1].append(temp)
        elif char == ' ':
            if word:
                stack[-1].append(word.strip())
                word = ""
        else:
            word += char
    return stack[0]


func parse_method_preconditions(method):
    var sexp = parse_sexp(method)
    var method_name = sexp[1]
    var parameters = {}
    var task = ""
    var precondition = ""
    var ordered_subtasks = []
    
    for i in range(2, sexp.size()):
        var sublist = sexp[i]
        if sublist[0] == ":parameters":
            for j in range(1, sublist.size(), 2):
                parameters[sublist[j]] = sublist[j+1]
        elif sublist[0] == ":task":
            task = sublist[1]
        elif sublist[0] == ":precondition":
            precondition = sublist.slice(1, sublist.size())
        elif sublist[0] == ":ordered-subtasks":
            ordered_subtasks = sublist.slice(1, sublist.size())
            
    methods[method_name] = {"parameters": parameters, "task": task, "precondition": precondition, "ordered_subtasks": ordered_subtasks}
    

func parse_definition(definition):
    var sexp = parse_sexp(definition)
    for sublist in sexp:
        if sublist[0] == ":types":
            types[sublist[1]] = sublist[2]
        elif sublist[0] == ":objects":
            objects[sublist[1]] = sublist[2]
        elif sublist[0] == ":action":
            parse_action(sublist)
        elif sublist[0] == ":method":
            parse_method_preconditions(sublist)


func parse_initialization(initialization):
    var sexp = parse_sexp(initialization)
    for sublist in sexp:
        if sublist[0] == ":object-instances":
            var instance_name = sublist[1]
            var properties = {}
            for i in range(2, len(sublist), 2):
                properties[sublist[i]] = sublist[i+1]
            objects[instance_name] = properties


func parse_action(action):
    var sexp = parse_sexp(action)
    var action_name = sexp[1]
    var parameters = {}
    var duration = 0
    var precondition = []
    var effect = []
    
    for i in range(2, sexp.size()):
        var sublist = sexp[i]
        if sublist[0] == ":parameters":
            for j in range(1, sublist.size(), 2):
                parameters[sublist[j]] = sublist[j+1]
        elif sublist[0] == ":duration":
            duration = int(sublist[1])
        elif sublist[0] == ":precondition":
            for j in range(1, sublist.size()):
                precondition.append(sublist[j])
        elif sublist[0] == ":effect":
            for j in range(1, sublist.size()):
                effect.append(sublist[j])
                
    actions[action_name] = {"parameters": parameters, "duration": duration, "precondition": precondition, "effect": effect}


var regex = RegEx.new()


func normalize_pddl(pddl: String) -> String:
	var lines = pddl.split("\n")
	var normalized_lines = []
	regex.compile("\\s+")
	for line in lines:
		var stripped_line: String = line.strip()
		if not stripped_line.begins_with(";;"):
			stripped_line = stripped_line.replace("(", " ( ")
			stripped_line = stripped_line.replace(")", " ) ")
			stripped_line = regex.sub(stripped_line, " ", true)
			normalized_lines.append(stripped_line)
	return "\n".join(normalized_lines)


func parse_pddl(pddl: String):
	var normalized_pddl = normalize_pddl(pddl)
	var sections = normalized_pddl.split("\n\n")
	for section in sections:
		if section.begins_with("(:types") or section.begins_with("(:objects"):
			parse_definition(section)
		elif section.begins_with("(:action"):
			parse_action(section)
		elif section.begins_with("(:method"):
			parse_method_preconditions(section)
		elif section.begins_with("(:object-instances"):
			parse_initialization(section)
