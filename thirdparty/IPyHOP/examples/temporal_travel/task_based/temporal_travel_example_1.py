#!/usr/bin/env python
"""
File Description: Temporal Travel example file. Run this file to solve the Temporal Travel planning problem.
"""

# ******************************************    Libraries to be imported    ****************************************** #
from examples.temporal_travel.task_based.temporal_travel_domain import actions, methods
from examples.temporal_travel.task_based.temporal_travel_problem import init_state, task_list_1, task_list_2
from ipyhop import IPyHOP, planar_plot


# ******************************************        Main Program Start      ****************************************** #
def main():
    print("=" * 80)
    print("TEMPORAL PLANNING EXAMPLE")
    print("=" * 80)
    print("\nMethods:")
    print(methods)
    print("\nActions:")
    print(actions)
    print("\nInitial State:")
    print(init_state)
    print(f"Initial Time: {init_state.get_current_time()}")
    
    planner = IPyHOP(methods, actions)
    plan = planner.plan(init_state, task_list_1, verbose=1)
    graph = planner.sol_tree
    
    print("\n" + "=" * 80)
    print("PLAN 1: Alice travels to park")
    print("=" * 80)
    print('\nTemporal Plan:')
    for item in plan:
        if isinstance(item, tuple) and len(item) == 2:
            action, temporal = item
            print(f'\tAction: {action}')
            print(f'\t\tDuration: {temporal.get("duration", "N/A")}')
            print(f'\t\tStart: {temporal.get("start_time", "N/A")}')
            print(f'\t\tEnd: {temporal.get("end_time", "N/A")}')
        else:
            print(f'\tAction: {item}')
    
    # Verify expected actions (without temporal metadata for comparison)
    expected_actions = [('a_call_taxi', 'alice', 'home_a'), ('a_ride_taxi', 'alice', 'park'), ('a_pay_driver', 'alice', 'park')]
    actual_actions = [item[0] if isinstance(item, tuple) and len(item) == 2 else item for item in plan]
    assert actual_actions == expected_actions, f"Result plan {actual_actions} and expected plan {expected_actions} are not same"
    
    # Plot the solution tree
    try:
        planar_plot(graph, root_node=0)
    except Exception as e:
        print(f"\nNote: Could not plot graph: {e}")

    # Try another, more elaborated task.
    print("\n" + "=" * 80)
    print("PLAN 2: Alice and Bob both travel to park")
    print("=" * 80)
    plan = planner.plan(init_state, task_list_2, verbose=1)
    graph = planner.sol_tree

    print('\nTemporal Plan:')
    total_duration = None
    for item in plan:
        if isinstance(item, tuple) and len(item) == 2:
            action, temporal = item
            print(f'\tAction: {action}')
            print(f'\t\tDuration: {temporal.get("duration", "N/A")}')
            print(f'\t\tStart: {temporal.get("start_time", "N/A")}')
            print(f'\t\tEnd: {temporal.get("end_time", "N/A")}')
            # Track the end time of the last action
            if temporal.get("end_time"):
                total_duration = temporal.get("end_time")
        else:
            print(f'\tAction: {item}')
    
    if total_duration:
        print(f'\nTotal plan end time: {total_duration}')
    
    # Verify expected actions
    expected_actions_2 = [('a_call_taxi', 'alice', 'home_a'), ('a_ride_taxi', 'alice', 'park'), 
                         ('a_pay_driver', 'alice', 'park'), ('a_walk', 'bob', 'home_b', 'park')]
    actual_actions_2 = [item[0] if isinstance(item, tuple) and len(item) == 2 else item for item in plan]
    assert actual_actions_2 == expected_actions_2, f"Result plan {actual_actions_2} and expected plan {expected_actions_2} are not same"
    
    # Plot the solution tree
    try:
        planar_plot(graph, root_node=0)
    except Exception as e:
        print(f"\nNote: Could not plot graph: {e}")


# ******************************************        Main Program End        ****************************************** #
# ******************************************    Demo / Test Routine         ****************************************** #
if __name__ == '__main__':
    try:
        main()
        print('\n' + "=" * 80)
        print('File executed successfully!')
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
