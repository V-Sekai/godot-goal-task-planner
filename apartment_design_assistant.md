# Magical College Town Apartment Design Planner

## Special Rules

- State is represented as a two-layer nested dictionary.
- Only primitives (actions) can change the state.
- Tasks are a combination of [goals, other tasks, primitives].
- Goals represent the desired target state.
- Simple Temporal Networks (STNs) are used for scheduling and avoiding physical overlaps.
- An existing `path_find` function using A\* algorithm is available for spatial reasoning and layout optimization.
- Footprint data can be used to create Constructive Solid Geometry (CSG) shapes for collision detection and gameplay programming.

## State Variables

- `apartment_state`: Dictionary representing the overall state of the apartment.
  - `layout`: Current layout of the apartment (e.g., 'studio', 'one-bedroom').
  - `room_list`: Dictionary of rooms, each with properties like size, style, and function.
  - `furniture_positions`: Dictionary detailing the positions and orientations of furniture items.

## Spatial Reasoning with Path Finding

- `path_find` function is utilized for optimizing movement paths and spatial configuration within the apartment.
- Ensures that furniture and room layouts allow for unobstructed movement and adhere to practical design principles.

## Avoiding Physical Overlaps

- Constraints are implemented to ensure no two objects occupy the same physical space.
- Checks are performed when placing furniture to avoid overlap and optimize spatial layout.

## Temporal Arrangement of Primitives using STNs

- STNs define the specific times or order in which primitives are executed.
- Temporal constraints ensure that actions are logically ordered and efficiently scheduled.

## Primitives (Actions)

### `create_room(apartment_state, room_name, size, style, function, pivot, footprint, time)`

- **Proof of Concept**:

```gdscript
["create_room", "bedroom1", "medium", "modern", "sleep", {"pivot": [0, 0, 0], "footprint": [5, 5, 3]}, 10]
```

### `place_furniture(apartment_state, item, room_name, position, orientation, pivot, footprint, time)`

- **Proof of Concept**:

```gdscript
["place_furniture", "bed", "bedroom1", "north-wall", "facing-south", {"pivot": [2, 2, 0], "footprint": [3, 2, 1]}, 15]
```

### `change_layout(apartment_state, new_layout)`

## Tasks

- `design_room(apartment_state, room_name, size, style, function)`
- `redesign_apartment(apartment_state, new_layout, room_specifications)`

## Goals

- Goal1: Design a Complete Apartment
- Goal2: Redesign an Existing Apartment

## Implementation of STNs and Path Finding

- STNs and `path_find` function are dynamically used as the design process progresses.
- Regular consistency checks ensure feasible scheduling and practical spatial arrangements.

## Example Scenario

```gdscript
var plan = planner.find_plan(apartment_state.duplicate(true), [
    ["design_room", "bedroom1", "medium", "modern", "sleep"],
    ["design_room", "bedroom2", "small", "vintage", "study"]
]);

assert_eq(plan, [
    ["create_room", "bedroom1", "medium", "modern", "sleep", {"pivot": [0, 0, 0], "footprint": [5, 5, 3]}, 10],
    ["place_furniture", "bed", "bedroom1", "north-wall", "facing-south", {"pivot": [2, 2, 0], "footprint": [3, 2, 1]}, 15],
    ["place_furniture", "wardrobe", "bedroom1", "east-wall", "facing-west", {"pivot": [4, 2, 0], "footprint": [1, 2, 2]}, 20],
    ["create_room", "bedroom2", "small", "vintage", "study", {"pivot": [6, 0, 0], "footprint": [4, 4, 3]}, 30],
    ["place_furniture", "desk", "bedroom2", "west-wall", "facing-east", {"pivot": [7, 2, 0], "footprint": [2, 1, 1]}, 35],
    ["place_furniture", "bookshelf", "bedroom2", "south-wall", "facing-north", {"pivot": [8, 3, 0], "footprint": [1, 2, 2]}, 40]
]);
```

## References

1. [Skyrim's Modular Level Design GDC 2013](http://blog.joelburgess.com/2013/04/skyrims-modular-level-design-gdc-2013.html?m=1)
