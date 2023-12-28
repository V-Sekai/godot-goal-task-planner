# Magical College Town Apartment Design Planner

## Special Rules

- State is represented as a two-layer nested dictionary.
- Only primitives (actions) can change the state.
- Tasks are a combination of [goals, other tasks, primitives].
- Goals represent the desired target state.
- Simple Temporal Networks (STNs) are used for scheduling primitives and avoiding physical overlaps.

## State Variables

- `apartment_state`: Dictionary representing the overall state of the apartment.
  - `layout`: Current layout of the apartment (e.g., 'studio', 'one-bedroom').
  - `room_list`: Dictionary of rooms, each with properties like size, style, and function.
  - `furniture_positions`: Dictionary detailing the positions and orientations of furniture items.

## Avoiding Physical Overlaps

- Constraints are implemented to ensure no two objects occupy the same physical space.
- When placing furniture (`place_furniture`), checks are performed against `furniture_positions` to avoid overlap.
- If an overlap is detected, the planner will re-evaluate the placement, adjusting positions or suggesting alternative items.

## Temporal Arrangement of Primitives using STNs

- STNs define the specific times or order in which primitives are executed.
- Temporal constraints ensure that:
  - The `create_room` action occurs before `place_furniture`.
  - The `change_layout` action, if needed, precedes both `create_room` and `place_furniture`.
- This temporal structuring aids in logical progression and efficiency in the design process.

## Primitives (Actions)

### `create_room(apartment_state, room_name, size, style, function)`

- **Scheduled Time**: Early in the design phase, after finalizing the layout.

### `place_furniture(apartment_state, item, room_name, position, orientation)`

- **Scheduled Time**: After room creation, before final design review.

### `change_layout(apartment_state, new_layout)`

- **Scheduled Time**: At the very beginning of the redesign process.

## Tasks

- `design_room(apartment_state, room_name, size, style, function)`
- `redesign_apartment(apartment_state, new_layout, room_specifications)`

## Goals

- Goal1: Design a Complete Apartment
- Goal2: Redesign an Existing Apartment

## Implementation of STNs

- STNs are dynamically updated as the design process progresses, adapting to changes in the project timeline.
- The planner checks STN consistency regularly to ensure feasible scheduling of all tasks and adherence to spatial constraints.
