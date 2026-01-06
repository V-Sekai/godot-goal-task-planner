#!/usr/bin/env python
"""
File Description: Healthcare Scheduling example - Real-world temporal planning problem.
Demonstrates scheduling surgeries with preparation, operation, and recovery times.
"""

# ******************************************    Libraries to be imported    ****************************************** #
from examples.healthcare_scheduling.task_based.healthcare_domain import actions, methods
from examples.healthcare_scheduling.task_based.healthcare_problem import init_state, task_list_1, task_list_2, task_list_3
from ipyhop import IPyHOP


# ******************************************        Main Program Start      ****************************************** #
def main():
    print("=" * 80)
    print("HEALTHCARE SCHEDULING - TEMPORAL PLANNING EXAMPLE")
    print("=" * 80)
    print("\nThis example demonstrates real-world temporal planning:")
    print("  - Scheduling surgeries with preparation time (30 min)")
    print("  - Surgery duration (2 hours)")
    print("  - Patient recovery transfer (15 min)")
    print("  - Room cleaning (20 min)")
    print()
    
    print("Initial State:")
    print(f"  Start Time: {init_state.get_current_time()}")
    print(f"  Rooms: {init_state.room_status}")
    print(f"  Patients: {list(init_state.patient_surgery_type.keys())}")
    
    planner = IPyHOP(methods, actions)
    
    # Problem 1: Single surgery
    print("\n" + "=" * 80)
    print("PROBLEM 1: Schedule one cardiac surgery")
    print("=" * 80)
    plan1 = planner.plan(init_state, task_list_1, verbose=0)
    
    print("\nTemporal Plan:")
    total_time = None
    for item in plan1:
        if isinstance(item, tuple) and len(item) == 2:
            action, temporal = item
            print(f"  {action[0]}: {action[1:]}")
            print(f"    Duration: {temporal.get('duration')}")
            print(f"    Start: {temporal.get('start_time')}")
            print(f"    End: {temporal.get('end_time')}")
            total_time = temporal.get('end_time')
        else:
            print(f"  {item}")
    
    if total_time:
        print(f"\nTotal procedure time: {total_time}")
        print("Expected: ~3 hours 5 minutes (30min prep + 2h surgery + 15min recovery + 20min clean)")
    
    # Problem 2: Two surgeries in parallel rooms
    print("\n" + "=" * 80)
    print("PROBLEM 2: Schedule two surgeries in parallel (different rooms)")
    print("=" * 80)
    plan2 = planner.plan(init_state, task_list_2, verbose=0)
    
    print("\nTemporal Plan:")
    last_end_time = None
    for item in plan2:
        if isinstance(item, tuple) and len(item) == 2:
            action, temporal = item
            print(f"  {action[0]}: {action[1:]}")
            print(f"    Duration: {temporal.get('duration')}")
            print(f"    Start: {temporal.get('start_time')}")
            print(f"    End: {temporal.get('end_time')}")
            last_end_time = temporal.get('end_time')
        else:
            print(f"  {item}")
    
    if last_end_time:
        print(f"\nLast action completes at: {last_end_time}")
        print("Note: Surgeries can run in parallel in different rooms")
    
    # Problem 3: Surgery using pre-cleaned room
    print("\n" + "=" * 80)
    print("PROBLEM 3: Schedule surgery using pre-cleaned room (optimized)")
    print("=" * 80)
    plan3 = planner.plan(init_state, task_list_3, verbose=0)
    
    print("\nTemporal Plan:")
    last_end_time = None
    for item in plan3:
        if isinstance(item, tuple) and len(item) == 2:
            action, temporal = item
            print(f"  {action[0]}: {action[1:]}")
            print(f"    Duration: {temporal.get('duration')}")
            print(f"    Start: {temporal.get('start_time')}")
            print(f"    End: {temporal.get('end_time')}")
            last_end_time = temporal.get('end_time')
        else:
            print(f"  {item}")
    
    if last_end_time:
        print(f"\nLast action completes at: {last_end_time}")
        print("Note: Using pre-cleaned room saves 20 minutes of cleaning time")
    
    print("\n" + "=" * 80)
    print("REAL-WORLD APPLICATIONS:")
    print("=" * 80)
    print("This temporal planning approach can be used for:")
    print("  - Hospital surgery scheduling")
    print("  - Operating room resource optimization")
    print("  - Patient flow management")
    print("  - Staff scheduling based on procedure durations")
    print("  - Equipment utilization planning")


# ******************************************        Main Program End        ****************************************** #
# ******************************************    Demo / Test Routine         ****************************************** #
if __name__ == '__main__':
    try:
        main()
        print('\n' + "=" * 80)
        print('Healthcare scheduling example executed successfully!')
        print("=" * 80 + '\n')
    except KeyboardInterrupt:
        print('\nProcess interrupted by user. Bye!')
    except Exception as e:
        print(f'\nError: {e}')
        import traceback
        traceback.print_exc()

"""
Author(s): K. S. Ernest (iFire) Lee
Temporal extensions: 2025
"""

