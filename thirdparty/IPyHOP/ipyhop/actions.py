#!/usr/bin/env python
"""
File Description: File used for definition of Actions Class.
"""

# ******************************************    Libraries to be imported    ****************************************** #
from __future__ import print_function, division
from typing import List, Callable, Union, Any, Dict, Tuple, Optional
# Import State directly to avoid circular imports
import sys
import os
_state_path = os.path.join(os.path.dirname(__file__), 'state.py')
if os.path.exists(_state_path):
    import importlib.util
    spec = importlib.util.spec_from_file_location("state_module", _state_path)
    state_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(state_module)
    State = state_module.State
else:
    from ipyhop.state import State

# Import TemporalMetadata directly
_temporal_metadata_path = os.path.join(os.path.dirname(__file__), 'temporal_metadata.py')
if os.path.exists(_temporal_metadata_path):
    import importlib.util
    spec = importlib.util.spec_from_file_location("temporal_metadata_module", _temporal_metadata_path)
    temporal_metadata_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(temporal_metadata_module)
    TemporalMetadata = temporal_metadata_module.TemporalMetadata
else:
    from ipyhop.temporal_metadata import TemporalMetadata


# ******************************************    Class Declaration Start     ****************************************** #
class Actions(object):
    """
    A class to store all the actions defined in a planning domain.

    *   actions = Actions() tells IPyHOP to create an empty actions container.
        To add actions into it, you should use actions.declare_actions(action_list).
        declare_actions([a1, a2, ..., ak]) tells IPyHOP that a1, a2, ..., ak are all of the planning actions.
        This supersedes any previous call to declare_actions([a1, a2, ..., ak]).

    All the actions are stored in a dictionary member variable named action_dict with the following structure::

        {op_name_1: [op_func_a, ...], op_name_2: [op_func_x, ...]...}

    Use the member function declare_actions to add actions to the action_dict.
    """

    def __init__(self):
        self.action_dict = dict()
        self.action_prob = dict()
        self.action_cost = dict()
        self.action_temporal_dict = dict()  # Maps action name to TemporalMetadata

    # ******************************        Class Method Declaration        ****************************************** #
    def __str__(self):
        a_str = '\n\rACTIONS: ' + ', '.join(self.action_dict)
        return a_str

    # ******************************        Class Method Declaration        ****************************************** #
    def __repr__(self):
        return self.__str__()

    _action_list_type = List[Callable[[Any], Union[State, bool]]]
    _act_prob_dict_type = Dict[str, List]
    _act_cost_dict_type = Dict[str, float]

    # ******************************        Class Method Declaration        ****************************************** #
    def declare_actions(self, action_list: _action_list_type):
        """
        declare_actions([a1, a2, ..., ak]) tells IPyHOP that [a1, a2, ..., ak] are all of the planning actions.
        This supersedes any previous call to declare_actions.

        :param action_list: List of actions in the
        """
        assert type(action_list) == list, "action_list must be a list."
        for action in action_list:
            assert callable(action), "action in action_list should be callable."
        self.action_dict.update({action.__name__: action for action in action_list})
        self.action_prob.update({action.__name__: [1, 0] for action in action_list})
        self.action_cost.update({action.__name__: 1.0 for action in action_list})

    # ******************************        Class Method Declaration        ****************************************** #
    def declare_action_models(self, act_prob_dict: _act_prob_dict_type, act_cost_dict: _act_cost_dict_type):
        self.action_prob.update({action: act_prob_dict[action] for action in act_prob_dict})
        self.action_cost.update({action: act_cost_dict[action] for action in act_cost_dict})

        assert(len(self.action_prob.keys()) == len(self.action_dict.keys()))
        assert (len(self.action_cost.keys()) == len(self.action_dict.keys()))
    
    # ******************************        Class Method Declaration        ****************************************** #
    def declare_temporal_actions(self, temporal_action_list: List[Tuple[Union[str, Callable], Union[str, float, Callable], Optional[Union[str, float]]]]):
        """
        Declare actions with temporal durations.
        
        Supports two formats:
        1. List of tuples: (action_name, action_func, duration)
        2. List of tuples: (action_func, duration) - uses function name
        
        :param temporal_action_list: List of (action_name_or_func, action_func_or_duration, optional_duration)
        """
        assert type(temporal_action_list) == list, "temporal_action_list must be a list."
        
        for item in temporal_action_list:
            if len(item) == 2:
                # Format: (action_func, duration)
                action_func, duration = item
                assert callable(action_func), "action_func must be callable."
                action_name = action_func.__name__
                # Register the action if not already registered
                if action_name not in self.action_dict:
                    self.action_dict[action_name] = action_func
                    self.action_prob[action_name] = [1, 0]
                    self.action_cost[action_name] = 1.0
            elif len(item) == 3:
                # Format: (action_name, action_func, duration)
                action_name, action_func, duration = item
                assert isinstance(action_name, str), "action_name must be a string."
                assert callable(action_func), "action_func must be callable."
                # Register the action
                self.action_dict[action_name] = action_func
                self.action_prob[action_name] = [1, 0]
                self.action_cost[action_name] = 1.0
            else:
                raise ValueError(f"Invalid temporal action format: {item}")
            
            # Create temporal metadata
            temporal_metadata = TemporalMetadata(duration=duration)
            self.action_temporal_dict[action_name] = temporal_metadata
    
    # ******************************        Class Method Declaration        ****************************************** #
    def get_temporal_metadata(self, action_name: str) -> Optional[TemporalMetadata]:
        """
        Get temporal metadata for an action.
        
        :param action_name: Name of the action
        :return: TemporalMetadata or None if action has no temporal info
        """
        return self.action_temporal_dict.get(action_name)
    
    # ******************************        Class Method Declaration        ****************************************** #
    def has_temporal_info(self, action_name: str) -> bool:
        """
        Check if an action has temporal information.
        
        :param action_name: Name of the action
        :return: True if action has temporal metadata, False otherwise
        """
        return action_name in self.action_temporal_dict


# ******************************************    Class Declaration End       ****************************************** #
# ******************************************    Demo / Test Routine         ****************************************** #
if __name__ == '__main__':
    def test_action_1(): return False
    def test_action_2(): return False
    def test_action_3(): return False


    print("Test instantiation of Methods class ...")
    actions = Actions()
    actions.declare_actions([test_action_1, test_action_2, test_action_3])
    print(actions)

"""
Author(s): Yash Bansod
Repository: https://github.com/YashBansod/IPyHOP
"""
