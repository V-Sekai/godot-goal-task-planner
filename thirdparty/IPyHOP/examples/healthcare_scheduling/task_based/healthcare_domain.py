#!/usr/bin/env python
"""
File Description: Healthcare Scheduling domain with temporal planning.
Real-world problem: Scheduling surgeries with preparation, operation, and recovery times.
"""

from ipyhop import Actions
from ipyhop import Methods


def a_prepare_room(state, room, surgery_type):
    """Prepare operating room for surgery."""
    if state.room_status[room] in ['available', 'cleaned'] and state.room_equipment[room] == surgery_type:
        state.room_status[room] = 'prepared'
        return state


def a_perform_surgery(state, patient, room, surgery_type):
    """Perform the actual surgery."""
    if (state.room_status[room] == 'prepared' and 
        state.patient_location[patient] == room and
        state.patient_surgery_type[patient] == surgery_type):
        state.room_status[room] = 'in_use'
        state.surgery_complete[patient] = True
        return state


def a_recover_patient(state, patient, room):
    """Move patient to recovery."""
    if state.surgery_complete[patient] and state.patient_location[patient] == room:
        state.patient_location[patient] = 'recovery'
        state.room_status[room] = 'available'
        return state


def a_clean_room(state, room):
    """Clean room after surgery."""
    if state.room_status[room] == 'available':
        state.room_status[room] = 'cleaned'
        return state


# Create actions with realistic temporal durations
actions = Actions()
actions.declare_temporal_actions([
    ('a_prepare_room', a_prepare_room, 'PT30M'),      # 30 minutes to prepare room
    ('a_perform_surgery', a_perform_surgery, 'PT2H'),  # 2 hours for surgery
    ('a_recover_patient', a_recover_patient, 'PT15M'), # 15 minutes to move to recovery
    ('a_clean_room', a_clean_room, 'PT20M'),          # 20 minutes to clean room
])


def tm_schedule_surgery(state, patient, room, surgery_type):
    """Method to schedule a complete surgery procedure."""
    if (state.room_status[room] == 'available' and
        state.room_equipment[room] == surgery_type and
        state.patient_surgery_type[patient] == surgery_type):
        return [
            ('a_prepare_room', room, surgery_type),
            ('a_perform_surgery', patient, room, surgery_type),
            ('a_recover_patient', patient, room),
            ('a_clean_room', room)
        ]


def tm_schedule_simple_surgery(state, patient, room, surgery_type):
    """Simplified method for pre-cleaned rooms (skip preparation and cleaning)."""
    if (state.room_status[room] in ['cleaned', 'available'] and
        state.room_equipment[room] == surgery_type and
        state.patient_surgery_type[patient] == surgery_type and
        state.patient_location[patient] == room):
        # For pre-cleaned rooms, we can skip preparation
        # But we need to mark room as prepared first
        return [
            ('a_prepare_room', room, surgery_type),
            ('a_perform_surgery', patient, room, surgery_type),
            ('a_recover_patient', patient, room),
            # Skip cleaning if room was already cleaned
        ]


methods = Methods()
methods.declare_task_methods('schedule_surgery', [tm_schedule_surgery, tm_schedule_simple_surgery])


# ******************************************    Demo / Test Routine         ****************************************** #
if __name__ == '__main__':
    raise NotImplementedError("Test run / Demo routine for Healthcare Scheduling Domain isn't implemented.")

"""
Author(s): K. S. Ernest (iFire) Lee
Temporal extensions: 2025
"""

