# Magical College Town Apartment Design Planner

## Special Rules

- State is represented as a two-layer nested dictionary.
- Only primitives (actions) can change the state.
- Tasks are a combination of [goals, other tasks, primitives].
- Goals represent the desired target state.
- Simple Temporal Networks (STNs) are used to arrange the order of design operations temporally.

## State Variables

- `apartment_state`: Dictionary representing the overall state of the apartment.
  - `layout`: Current layout of the apartment (e.g., 'studio', 'one-bedroom').
  - `room_list`: Dictionary of rooms, each with properties like size, style, and function.
  - `furniture_positions`: Dictionary detailing the positions and orientations of furniture items.

## Using STNs for Temporal Arrangement

- STNs are employed to schedule and sequence the design tasks.
- The order of design operations (room creation, furniture placement, etc.) is managed temporally to optimize the workflow.
- Constraints are set to ensure that certain tasks are completed before others, respecting dependencies and logical sequences in the design process.

## Primitives (Actions)

- `create_room(apartment_state, room_name, size, style, function)`
- `place_furniture(apartment_state, item, room_name, position, orientation)`
- `change_layout(apartment_state, new_layout)`

## Tasks

- `design_room(apartment_state, room_name, size, style, function)`
- `redesign_apartment(apartment_state, new_layout, room_specifications)`

## Goals

- Goal1: Design a Complete Apartment
  - Sequential tasks: Layout creation, room designing, furniture placement.
- Goal2: Redesign an Existing Apartment
  - Temporal constraints: Adjust layout before room redesign, update furniture post-room modifications.
