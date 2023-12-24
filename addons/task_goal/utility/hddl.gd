# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# hddl.gd  
# SPDX-License-Identifier: MIT

class_name HDDLParser

var types = {}
var objects = {}
var actions = {}
var methods = {}


func parse_sexp(expression: String) -> Array[Array]:
	var stack: Array[Array] = [[]]
	var word: String = ""
	for char in expression:
		if char == '(':
			stack.append([])
		elif char == ')':
			if word != "":
				stack[stack.size() - 1].append(word.strip_edges())
				word = ""
			var temp: Array[Array] = [stack.pop_back()]
			stack[stack.size() - 1].append(temp)
		elif char == ' ':
			if word != "":
				stack[stack.size() - 1].append(word.strip_edges())
				word = ""
		else:
			word += char
	return stack


func parse_method_preconditions(sexp):
	for s in sexp:
		if s[0] == ":method":
			var method_name = s[1]
			var parameters = {}
			var task = ""
			var precondition = []
			var ordered_subtasks = []
			
			for i in range(2, len(s)):
				var sublist = s[i]
				if sublist is Array and sublist.size() > 0:
					if sublist[0] == ":parameters":
						for j in range(1, sublist.size(), 2):
							parameters[sublist[j]] = sublist[j+1]
					elif sublist[0] == ":task":
						task = sublist[1]
					elif sublist[0] == ":precondition":
						precondition = sublist.slice(1, sublist.size()-1)
					elif sublist[0] == ":ordered-subtasks":
						ordered_subtasks = sublist.slice(1, sublist.size()-1)
					
			methods[method_name] = {"parameters": parameters, "task": task, "precondition": precondition, "ordered_subtasks": ordered_subtasks}


func parse_definition(sexp):
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


func parse_action(sexp: Array) -> Dictionary:
	var actions = {}
	for s in sexp:
		if s is Array:
			var action_dict = {
				"action_name": "",
				"parameters": [],
				"precondition": [],
				"effect": []
			}
			action_dict = _parse_sublist(s, action_dict)
			var action_name = action_dict.get("action_name") 
			if not action_name.is_empty():
				actions[action_dict["action_name"]] = { "parameters": action_dict["parameters"], "precondition":action_dict["effect"], "effect": action_dict["effect"]}
	return actions

func _parse_sublist(sublist: Array, action_dict):
	if sublist.size() > 0:
		if typeof(sublist[0]) == TYPE_STRING:
			if sublist[0] == ":action":
				action_dict["action_name"] = sublist[1]
			elif sublist[0] == ":parameters":
				action_dict["parameters"] = sublist.slice(1, sublist.size())
			elif sublist[0] == ":precondition":
				action_dict["precondition"] = sublist.slice(1, sublist.size())
			elif sublist[0] == ":effect":
				action_dict["effect"] = sublist.slice(1, sublist.size())
		else:
			for item in sublist:
				if item is Array:
					action_dict = _parse_sublist(item, action_dict)
	return action_dict


var regex = RegEx.new()


func normalize_pddl(pddl: String) -> String:
	var lines = pddl.split("\n")
	var normalized_lines = []
	regex.compile("\\s+")
	for line in lines:
		var stripped_line: String = line.strip_edges()
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
		var sexp = parse_sexp(section)
		var first_token = sexp[0]
		if first_token == ":types" or first_token == ":objects":
			parse_definition(sexp)
		elif first_token == ":action":
			parse_action(sexp)
		elif first_token == ":method":
			parse_method_preconditions(sexp)
		elif first_token == ":object-instances":
			parse_initialization(sexp)
