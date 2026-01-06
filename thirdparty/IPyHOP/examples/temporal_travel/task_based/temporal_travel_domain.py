#!/usr/bin/env python
"""
File Description: Temporal Travel domain file. All the actions and methods for Temporal Travel planning domain are
    defined here. This demonstrates temporal planning with action durations.
Derived from: Simple Travel domain by Yash Bansod
"""

from ipyhop import Actions
from ipyhop import Methods


def taxi_rate(dist):
    return 1.5 + 0.5 * dist


def distance(state, x, y):
    return state.rigid['dist'].get((x, y)) or state.rigid['dist'].get((y, x))


def is_a(state, var_, type_):
    return var_ in state.rigid['types'][type_]


def a_walk(state, p, x, y):
    if is_a(state, p, 'person') and is_a(state, x, 'location') and is_a(state, y, 'location') and x != y:
        if state.loc[p] == x:
            state.loc[p] = y
            return state


def a_call_taxi(state, p, x):
    if is_a(state, p, 'person') and is_a(state, x, 'location'):
        state.loc['taxi1'] = x
        state.loc[p] = 'taxi1'
        return state


def a_ride_taxi(state, p, y):
    # if p is a person, p is in a taxi, and y is a location:
    if is_a(state, p, 'person') and is_a(state, state.loc[p], 'taxi') and is_a(state, y, 'location'):
        taxi = state.loc[p]
        x = state.loc[taxi]
        if is_a(state, x, 'location') and x != y:
            state.loc[taxi] = y
            state.owe[p] = taxi_rate(distance(state, x, y))
            return state


def a_pay_driver(state, p, y):
    if is_a(state, p, 'person'):
        if state.cash[p] >= state.owe[p]:
            state.cash[p] = state.cash[p] - state.owe[p]
            state.owe[p] = 0
            state.loc[p] = y
            return state


# Create actions with temporal durations
actions = Actions()
# Declare temporal actions: walking takes 5 minutes per unit distance, 
# calling taxi is instant, riding taxi takes 10 minutes per unit distance,
# paying driver is instant
actions.declare_temporal_actions([
    ('a_walk', a_walk, 'PT5M'),           # 5 minutes to walk
    ('a_call_taxi', a_call_taxi, 'PT0S'), # Instant (0 seconds)
    ('a_ride_taxi', a_ride_taxi, 'PT10M'), # 10 minutes to ride
    ('a_pay_driver', a_pay_driver, 'PT0S') # Instant (0 seconds)
])


def tm_do_nothing(state, p, y):
    if is_a(state, p, 'person') and is_a(state, y, 'location'):
        x = state.loc[p]
        if x == y:
            return []


def tm_travel_by_foot(state, p, y):
    if is_a(state, p, 'person') and is_a(state, y, 'location'):
        x = state.loc[p]
        if x != y and distance(state, x, y) <= 2:
            return [('a_walk', p, x, y)]


def tm_travel_by_taxi(state, p, y):
    if is_a(state, p, 'person') and is_a(state, y, 'location'):
        x = state.loc[p]
        if x != y and state.cash[p] >= taxi_rate(distance(state, x, y)):
            return [('a_call_taxi', p, x), ('a_ride_taxi', p, y), ('a_pay_driver', p, y)]


methods = Methods()
methods.declare_task_methods('travel', [tm_do_nothing, tm_travel_by_foot, tm_travel_by_taxi])

# ******************************************    Demo / Test Routine         ****************************************** #
if __name__ == '__main__':
    raise NotImplementedError("Test run / Demo routine for Temporal Travel Domain isn't implemented.")

"""
Author(s): K. S. Ernest (iFire) Lee
Temporal extensions: 2025
"""
