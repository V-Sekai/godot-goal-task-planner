# Magical College Town Apartment Design Planner

## Special Rules

- State is represented as a two-layer nested dictionary.
- Only primitives (actions) can change the state.
- Tasks are a combination of [goals, other tasks, primitives].
- Goals represent the desired target state.
- Simple Temporal Networks (STNs) are used for scheduling and avoiding physical overlaps.
- An existing `path_find` function using A\* algorithm is available for spatial reasoning and layout optimization.

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

### `create_room(apartment_state, room_name, size, style, function)`

- **Scheduled Time**: Early in the design phase, after finalizing the layout.

### `place_furniture(apartment_state, item, room_name, position, orientation)`

- **Scheduled Time**: After room creation, before final design review.

### `change_layout(apartment_state, new_layout)`

- **Scheduled Time**: At the beginning of the redesign process.

## Tasks

- `design_room(apartment_state, room_name, size, style, function)`
- `redesign_apartment(apartment_state, new_layout, room_specifications)`

## Goals

- Goal1: Design a Complete Apartment
- Goal2: Redesign an Existing Apartment

## Implementation of STNs and Path Finding

- STNs and `path_find` function are dynamically used as the design process progresses.
- Regular consistency checks ensure feasible scheduling and practical spatial arrangements.
