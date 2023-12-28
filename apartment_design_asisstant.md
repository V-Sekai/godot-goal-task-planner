# Magical College Town Apartment Design Planner

## Special Rules

- State is represented as a two-layer nested dictionary.
- Only primitives (actions) can change the state.
- Tasks are a combination of [goals, other tasks, primitives].
- Goals represent the desired target state.

## State Variables

- `apartment_state`: Dictionary representing the overall state of the apartment.
  - `layout`: Current layout of the apartment (e.g., 'studio', 'one-bedroom').
  - `room_list`: Dictionary of rooms, each with properties like size, style, and function.
  - `furniture_positions`: Dictionary detailing the positions and orientations of furniture items.

## Primitives (Actions)

### `create_room(apartment_state, room_name, size, style, function)`

- **Effect**: Adds a new room to `apartment_state['room_list']` with specified properties.

### `place_furniture(apartment_state, item, room_name, position, orientation)`

- **Effect**: Updates `apartment_state['furniture_positions']`, placing an item in a specified room.

### `change_layout(apartment_state, new_layout)`

- **Effect**: Alters the `apartment_state['layout']` of the apartment.

## Tasks

### `design_room(apartment_state, room_name, size, style, function)`

- **Components**:
  - **Goals**: Room designed according to specifications.
  - **Sub-tasks**: N/A.
  - **Primitives**: `create_room(apartment_state, room_name, size, style, function)`, `place_furniture` for selected items.

### `redesign_apartment(apartment_state, new_layout, room_specifications)`

- **Components**:
  - **Goals**: Apartment redesigned to new layout with updated rooms.
  - **Sub-tasks**: `design_room` for each room in `room_specifications`.
  - **Primitives**: `change_layout(apartment_state, new_layout)`.

## Goals

### Goal1: Design a Complete Apartment

- **Target State**:
  - `apartment_state['layout']` set to a specific type.
  - `apartment_state['room_list']` filled with designed rooms.
  - `apartment_state['furniture_positions']` populated with furniture items appropriately placed.

### Goal2: Redesign an Existing Apartment

- **Target State**:
  - `apartment_state['layout']` modified to a new type.
  - `apartment_state['room_list']` and `apartment_state['furniture_positions']` updated to reflect new design requirements.
