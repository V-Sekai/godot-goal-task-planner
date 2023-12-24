class_name HDDLParser

var types = {}
var objects = {}
var actions = {}
var methods = {}

func parse_method_preconditions(method):
    var lines = method.split("\n")
    var method_name = ""
    var parameters = {}
    var task = ""
    var precondition = ""
    var ordered_subtasks = []
    for i in range(lines.size()):
        var line = lines[i].strip()
        if line.begins_with("(:method"):
            method_name = line.replace("(:method ", "").replace(")", "")
        elif line.begins_with(":parameters"):
            var params_def = line.replace(":parameters (", "").replace(")", "").split(" - ")
            parameters[params_def[0]] = params_def[1]
        elif line.begins_with(":task"):
            task = line.replace(":task (", "").replace(")", "")
        elif line.begins_with(":precondition"):
            while not lines[i].strip().ends_with(")"):
                i += 1
                precondition += lines[i].strip()
        elif line.begins_with(":ordered-subtasks"):
            while not lines[i].strip().ends_with(")"):
                i += 1
                ordered_subtasks.append(lines[i].strip())
    methods[method_name] = {"parameters": parameters, "task": task, "precondition": precondition, "ordered_subtasks": ordered_subtasks}


func parse_definition(definition):
    var lines = definition.split("\n")
    for i in range(lines.size()):
        var line = lines[i].strip()
        if line.begins_with("(:types"):
            while not lines[i].strip().ends_with(")"):
                i += 1
                var type_def = lines[i].strip().split(" - ")
                types[type_def[0]] = type_def[1]
        elif line.begins_with("(:objects"):
            while not lines[i].strip().ends_with(")"):
                i += 1
                var object_def = lines[i].strip().split(" - ")
                objects[object_def[0]] = object_def[1]

func parse_initialization(initialization):
    var lines = initialization.split("\n")
    for i in range(lines.size()):
        var line = lines[i].strip()
        if line.begins_with("(:object-instances"):
            while not lines[i].strip().ends_with(")"):
                i += 1
                var instance_def = lines[i].strip().split(" {")
                var instance_name = instance_def[0]
                var instance_properties = instance_def[1].replace("}", "").split(", ")
                var properties = {}
                for prop in instance_properties:
                    var prop_def = prop.split(" = ")
                    properties[prop_def[0]] = prop_def[1]
                objects[instance_name] = properties

func parse_action(action):
    var lines = action.split("\n")
    var action_name = ""
    var parameters = {}
    var duration = 0
    var precondition = ""
    var effect = ""
    for i in range(lines.size()):
        var line = lines[i].strip()
        if line.begins_with("(:action"):
            action_name = line.replace("(:action ", "").replace(")", "")
        elif line.begins_with(":parameters"):
            var params_def = line.replace(":parameters (", "").replace(")", "").split(" - ")
            parameters[params_def[0]] = params_def[1]
        elif line.begins_with(":duration"):
            duration = int(line.replace(":duration (= ?duration ", "").replace(")", ""))
        elif line.begins_with(":precondition"):
            while not lines[i].strip().ends_with(")"):
                i += 1
                precondition += lines[i].strip()
        elif line.begins_with(":effect"):
            while not lines[i].strip().ends_with(")"):
                i += 1
                effect += lines[i].strip()
    actions[action_name] = {"parameters": parameters, "duration": duration, "precondition": precondition, "effect": effect}
