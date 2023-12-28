# Example Scenario

```swift
var plan = planner.find_plan(apartment_state.duplicate(true), [["design_room", "bedroom1", "medium", "modern", "sleep"], ["design_room", "bedroom2", "small", "vintage", "study"]])
assert_eq(plan, [
    ["create_room", "bedroom1", "medium", "modern", "sleep"],
    ["place_furniture", "bed", "bedroom1", "north-wall", "facing-south"],
    ["place_furniture", "wardrobe", "bedroom1", "east-wall", "facing-west"],
    ["create_room", "bedroom2", "small", "vintage", "study"],
    ["place_furniture", "desk", "bedroom2", "west-wall", "facing-east"],
    ["place_furniture", "bookshelf", "bedroom2", "south-wall", "facing-north"]
])
```

#### Domain State

- **Initial State (`apartment_state`)**:
  - `layout`: "two-bedroom"
  - `room_list`: {"bedroom1": {"size": "medium", "style": "modern", "function": "sleep"}, "bedroom2": {"size": "small", "style": "vintage", "function": "study"}}
  - `furniture_positions`: {}

#### Plan

1. **Goal**: Design a complete two-bedroom apartment with a modern bedroom and a vintage study room.
2. **Tasks**:

   - `design_room(apartment_state, "bedroom1", "medium", "modern", "sleep")`
   - `design_room(apartment_state, "bedroom2", "small", "vintage", "study")`

3. **Primitives to be Executed**:
   - `create_room(apartment_state, "bedroom1", "medium", "modern", "sleep")`
   - `place_furniture(apartment_state, "bed", "bedroom1", "north-wall", "facing-south")`
   - `place_furniture(apartment_state, "wardrobe", "bedroom1", "east-wall", "facing-west")`
   - `create_room(apartment_state, "bedroom2", "small", "vintage", "study")`
   - `place_furniture(apartment_state, "desk", "bedroom2", "west-wall", "facing-east")`
   - `place_furniture(apartment_state, "bookshelf", "bedroom2", "south-wall", "facing-north")`

#### Resulting Primitives Execution

- **For Bedroom 1 (Modern Bedroom)**:

  - Create the bedroom with medium size and modern style.
  - Place a bed against the north wall, facing south.
  - Set up a wardrobe against the east wall, facing west.

- **For Bedroom 2 (Vintage Study Room)**:
  - Create the study room with small size and vintage style.
  - Install a desk against the west wall, facing east.
  - Position a bookshelf on the south wall, facing north.

In this scenario, the tasks are derived from the initial goal of designing a complete two-bedroom apartment with specific styles and functions for each room. The primitives are the actionable steps that directly change the state, implementing the design aspects defined in the tasks. By following this plan, the apartment state is transformed from its initial setup to the desired layout with fully designed rooms and placed furniture, adhering to the specified styles and functions.
