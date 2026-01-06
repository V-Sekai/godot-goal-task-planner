#!/usr/bin/env python
"""
File Description: Temporal Travel problem file. Initial state and task list for the temporal planning problem is defined here.
"""

from ipyhop import State

rigid_relations = dict()
rigid_relations['types'] = {'person': ['alice', 'bob'],
                            'location': ['home_a', 'home_b', 'park', 'station', 'downtown'],
                            'taxi': ['taxi1', 'taxi2']}
rigid_relations['dist'] = {('home_a', 'park'): 8, ('home_b', 'park'): 2, ('station', 'home_a'): 1,
                           ('station', 'home_b'): 7, ('downtown', 'home_a'): 3,
                           ('downtown', 'home_b'): 7, ('station', 'downtown'): 2}

# Initialize state with a starting time for temporal planning
init_state = State('init_state', initial_time='2025-01-01T10:00:00Z')
init_state.rigid = rigid_relations
init_state.loc = {'alice': 'home_a', 'bob': 'home_b', 'taxi1': 'park', 'taxi2': 'station'}
init_state.cash = {'alice': 20, 'bob': 15}
init_state.owe = {'alice': 0, 'bob': 0}

task_list_1 = [('travel', 'alice', 'park')]
task_list_2 = [('travel', 'alice', 'park'), ('travel', 'bob', 'park')]

"""
Author(s): K. S. Ernest (iFire) Lee
Temporal extensions: 2025
"""

