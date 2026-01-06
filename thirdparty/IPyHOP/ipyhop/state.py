#!/usr/bin/env python
"""
File Description: File used for definition of State Class.
"""

# ******************************************    Libraries to be imported    ****************************************** #
from copy import deepcopy
from typing import Optional, List, Tuple
# Import directly from utils file to avoid triggering full package imports
import sys
import os
_temporal_utils_path = os.path.join(os.path.dirname(__file__), 'temporal', 'utils.py')
if os.path.exists(_temporal_utils_path):
    import importlib.util
    spec = importlib.util.spec_from_file_location("temporal_utils", _temporal_utils_path)
    temporal_utils = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(temporal_utils)
    now_iso8601 = temporal_utils.now_iso8601
else:
    # Fallback to package import if direct import fails
    from ipyhop.temporal.utils import now_iso8601


# ******************************************    Class Declaration Start     ****************************************** #
class State(object):
    """
    A state is just a collection of variable bindings.

    *   state = State('foo') tells IPyHOP to create an empty state object named 'foo'.
        To put variables and values into it, you should do assignments such as foo.var1 = val1
    """

    def __init__(self, name: str, initial_time: Optional[str] = None):
        """
        Initialize a state.
        
        :param name: Name of the state
        :param initial_time: Initial time as ISO 8601 string (defaults to current time)
        """
        self.__name__ = name
        # Temporal tracking
        if initial_time is not None:
            self._current_time = initial_time
            self._initial_time_set = True  # Mark that time was explicitly set
        else:
            self._current_time = now_iso8601()
            self._initial_time_set = False  # Mark that time was auto-generated
        self._timeline = []  # List of (action, start_time, end_time) tuples

    # ******************************        Class Method Declaration        ****************************************** #
    def __str__(self):
        if self:
            var_str = "\r{state_name}.{var_name} = {var_value}\n"
            state_str = ""
            for name, val in self.__dict__.items():
                if name != "__name__":
                    _str = var_str.format(state_name=self.__name__, var_name=name, var_value=val)
                    _str = '\n\t\t'.join(_str[i:i+120] for i in range(0, len(_str), 120))
                    state_str += _str
            return state_str[:-1]
        else:
            return "False"

    # ******************************        Class Method Declaration        ****************************************** #
    def __repr__(self):
        return str(self.__class__) + ", " + self.__name__

    # ******************************        Class Method Declaration        ****************************************** #
    def update(self, state):
        self.__dict__.update(state.__dict__)
        return self

    # ******************************        Class Method Declaration        ****************************************** #
    def copy(self):
        return deepcopy(self)
    
    # ******************************        Temporal Methods        ****************************************** #
    def get_current_time(self) -> str:
        """
        Get the current time in the state.
        
        :return: ISO 8601 datetime string
        """
        return self._current_time
    
    def set_current_time(self, time: str):
        """
        Set the current time in the state.
        
        :param time: ISO 8601 datetime string
        """
        self._current_time = time
    
    def add_to_timeline(self, action: Tuple, start_time: str, end_time: str):
        """
        Add an action to the timeline.
        
        :param action: Action tuple (e.g., ('a_walk', 'alice', 'home_a', 'park'))
        :param start_time: Start time as ISO 8601 string
        :param end_time: End time as ISO 8601 string
        """
        self._timeline.append((action, start_time, end_time))
    
    def get_timeline(self) -> List[Tuple[Tuple, str, str]]:
        """
        Get the timeline of executed actions.
        
        :return: List of (action, start_time, end_time) tuples
        """
        return self._timeline.copy()
    
    def clear_timeline(self):
        """Clear the timeline."""
        self._timeline = []


# ******************************************    Class Declaration End       ****************************************** #
# ******************************************    Demo / Test Routine         ****************************************** #
if __name__ == '__main__':
    print("Test instantiation of State class ...")
    test_state = State('test_state')
    test_state.test_var_1 = {'key1': 'val1'}
    test_state.test_var_2 = {'key1': 0}
    test_state.test_var_3 = {'key2': {'key3': 5}, 'key3': {'key2': 5}}
    print(test_state)

"""
Author(s): Yash Bansod
Repository: https://github.com/YashBansod/IPyHOP
"""
