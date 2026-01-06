#!/usr/bin/env python
"""
File Description: Healthcare Scheduling problem - scheduling multiple surgeries with temporal constraints.
"""

from ipyhop import State

# Initialize state with hospital setup
init_state = State('hospital_state', initial_time='2025-01-15T08:00:00Z')

# Operating rooms and their equipment
init_state.room_status = {
    'OR1': 'available',
    'OR2': 'available',
    'OR3': 'cleaned'  # One room is already cleaned
}
init_state.room_equipment = {
    'OR1': 'cardiac',
    'OR2': 'orthopedic',
    'OR3': 'cardiac'
}

# Patients and their surgery requirements
init_state.patient_location = {
    'patient1': 'OR1',
    'patient2': 'OR2',
    'patient3': 'OR3'
}
init_state.patient_surgery_type = {
    'patient1': 'cardiac',
    'patient2': 'orthopedic',
    'patient3': 'cardiac'
}
init_state.surgery_complete = {
    'patient1': False,
    'patient2': False,
    'patient3': False
}

# Task lists
task_list_1 = [('schedule_surgery', 'patient1', 'OR1', 'cardiac')]
task_list_2 = [
    ('schedule_surgery', 'patient1', 'OR1', 'cardiac'),
    ('schedule_surgery', 'patient2', 'OR2', 'orthopedic')
]
task_list_3 = [
    ('schedule_surgery', 'patient1', 'OR1', 'cardiac'),
    ('schedule_surgery', 'patient3', 'OR3', 'cardiac')  # Uses pre-cleaned room
]

"""
Author(s): K. S. Ernest (iFire) Lee
Temporal extensions: 2025
"""

