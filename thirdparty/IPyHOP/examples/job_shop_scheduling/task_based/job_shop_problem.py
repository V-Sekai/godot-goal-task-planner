#!/usr/bin/env python
"""
File Description: Job Shop Scheduling problem - classic MiniZinc problem.
Jobs consist of sequences of tasks that must be performed on specific machines.
Each task has a duration and must be completed before the next task in the job.
"""

from ipyhop import State

# Initialize state
init_state = State('job_shop', initial_time='2025-01-15T08:00:00Z')

# Jobs and their tasks
# Job 1: Task A on Machine 1, Task B on Machine 2
# Job 2: Task C on Machine 2, Task D on Machine 1
init_state.job_tasks = {
    'job1': ['taskA', 'taskB'],
    'job2': ['taskC', 'taskD']
}

# Task status
init_state.job_task_status = {
    'job1': {'taskA': 'pending', 'taskB': 'pending'},
    'job2': {'taskC': 'pending', 'taskD': 'pending'}
}

# Which machine each task requires
init_state.job_task_machine = {
    'job1': {'taskA': 'machine1', 'taskB': 'machine2'},
    'job2': {'taskC': 'machine2', 'taskD': 'machine1'}
}

# Machine availability
init_state.machine_available = {
    'machine1': True,
    'machine2': True
}

# Task lists
task_list_1 = [('schedule_job', 'job1')]
task_list_2 = [
    ('schedule_job', 'job1'),
    ('schedule_job', 'job2')
]

"""
Author(s): K. S. Ernest (iFire) Lee
Temporal extensions: 2025
Based on MiniZinc job shop scheduling problem
"""

