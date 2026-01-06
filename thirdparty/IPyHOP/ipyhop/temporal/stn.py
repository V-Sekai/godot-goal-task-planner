#!/usr/bin/env python
"""
File Description: Simple Temporal Network (STN) for temporal constraint checking.
"""

from __future__ import print_function, division
from typing import Dict, Set, Tuple, Optional, List
from collections import defaultdict
import math


class STN(object):
    """
    Simple Temporal Network for temporal constraint checking.
    
    Represents temporal constraints as a network of time points connected by
    distance constraints. Uses Floyd-Warshall algorithm for consistency checking.
    
    Simplified version of aria-planner's STN implementation.
    
    Usage:
        stn = STN()
        stn.add_time_point("action1_start")
        stn.add_time_point("action1_end")
        stn.add_constraint("action1_start", "action1_end", (10, 15))  # 10-15 seconds
        if stn.consistent():
            print("Temporal constraints are consistent")
    """
    
    def __init__(self, time_unit: str = 'second'):
        """
        Initialize an empty STN.
        
        :param time_unit: Unit of time ('second', 'minute', 'hour', etc.)
        """
        self.time_points: Set[str] = set()
        self.constraints: Dict[Tuple[str, str], Tuple[float, float]] = {}
        self._distance_matrix: Optional[Dict[Tuple[str, str], float]] = None
        self._consistent: Optional[bool] = None
        self.time_unit = time_unit
    
    def add_time_point(self, point: str):
        """
        Add a time point to the network.
        
        :param point: Name of the time point
        """
        self.time_points.add(point)
        self._consistent = None  # Invalidate consistency check
        self._distance_matrix = None
    
    def add_constraint(self, from_point: str, to_point: str, 
                      constraint: Tuple[float, float]):
        """
        Add a temporal constraint between two time points.
        
        :param from_point: Source time point
        :param to_point: Target time point
        :param constraint: Tuple (min_distance, max_distance) in time_unit
        """
        self.add_time_point(from_point)
        self.add_time_point(to_point)
        
        min_dist, max_dist = constraint
        if min_dist > max_dist:
            raise ValueError(f"Invalid constraint: min ({min_dist}) > max ({max_dist})")
        
        # Store constraint (from_point, to_point) -> (min, max)
        self.constraints[(from_point, to_point)] = (min_dist, max_dist)
        self._consistent = None  # Invalidate consistency check
        self._distance_matrix = None
    
    def add_interval(self, start_point: str, end_point: str, 
                    duration: Tuple[float, float]):
        """
        Add an interval constraint (duration between start and end).
        
        :param start_point: Start time point
        :param end_point: End time point
        :param duration: Tuple (min_duration, max_duration)
        """
        self.add_constraint(start_point, end_point, duration)
    
    def _build_distance_matrix(self):
        """
        Build distance matrix using Floyd-Warshall algorithm.
        
        The distance matrix stores the shortest path between all pairs of time points.
        """
        points = list(self.time_points)
        n = len(points)
        
        if n == 0:
            self._distance_matrix = {}
            return
        
        # Initialize distance matrix with infinity
        dist = defaultdict(lambda: defaultdict(lambda: math.inf))
        
        # Distance from a point to itself is 0
        for point in points:
            dist[point][point] = 0.0
        
        # Add constraints as edges
        for (from_pt, to_pt), (min_dist, max_dist) in self.constraints.items():
            # Constraint: to_pt - from_pt <= max_dist
            # This means: to_pt <= from_pt + max_dist
            # In distance matrix: dist[from_pt][to_pt] = max_dist
            if dist[from_pt][to_pt] > max_dist:
                dist[from_pt][to_pt] = max_dist
            
            # Reverse constraint: from_pt - to_pt <= -min_dist
            # This means: from_pt <= to_pt - min_dist
            # In distance matrix: dist[to_pt][from_pt] = -min_dist
            if dist[to_pt][from_pt] > -min_dist:
                dist[to_pt][from_pt] = -min_dist
        
        # Floyd-Warshall algorithm
        for k in points:
            for i in points:
                for j in points:
                    if dist[i][k] != math.inf and dist[k][j] != math.inf:
                        if dist[i][j] > dist[i][k] + dist[k][j]:
                            dist[i][j] = dist[i][k] + dist[k][j]
        
        # Convert to regular dict for easier access
        self._distance_matrix = {
            (i, j): dist[i][j] for i in points for j in points
        }
    
    def consistent(self) -> bool:
        """
        Check if the STN is consistent (no negative cycles).
        
        :return: True if consistent, False otherwise
        """
        if self._consistent is not None:
            return self._consistent
        
        if self._distance_matrix is None:
            self._build_distance_matrix()
        
        # Check for negative cycles: if dist[i][i] < 0 for any i, there's a cycle
        points = list(self.time_points)
        for point in points:
            if self._distance_matrix.get((point, point), 0) < 0:
                self._consistent = False
                return False
        
        self._consistent = True
        return True
    
    def get_distance(self, from_point: str, to_point: str) -> Optional[float]:
        """
        Get the shortest distance between two time points.
        
        :param from_point: Source time point
        :param to_point: Target time point
        :return: Distance or None if points don't exist
        """
        if from_point not in self.time_points or to_point not in self.time_points:
            return None
        
        if self._distance_matrix is None:
            self._build_distance_matrix()
        
        dist = self._distance_matrix.get((from_point, to_point), math.inf)
        return dist if dist != math.inf else None
    
    def get_intervals(self) -> List[Tuple[str, str, float, float]]:
        """
        Get all interval constraints.
        
        :return: List of (start_point, end_point, min_duration, max_duration)
        """
        intervals = []
        for (from_pt, to_pt), (min_dur, max_dur) in self.constraints.items():
            intervals.append((from_pt, to_pt, min_dur, max_dur))
        return intervals
    
    def check_interval_conflicts(self, start_point: str, end_point: str, 
                                 min_duration: float, max_duration: float) -> bool:
        """
        Check if adding an interval would create a conflict.
        
        :param start_point: Start time point
        :param end_point: End time point
        :param min_duration: Minimum duration
        :param max_duration: Maximum duration
        :return: True if conflict exists, False otherwise
        """
        # Create a temporary STN with the new constraint
        temp_stn = STN(self.time_unit)
        temp_stn.time_points = self.time_points.copy()
        temp_stn.constraints = self.constraints.copy()
        temp_stn.add_constraint(start_point, end_point, (min_duration, max_duration))
        
        return not temp_stn.consistent()
    
    def find_free_slots(self, duration: float, window_start: float = 0.0, 
                       window_end: float = 1000.0) -> List[Tuple[float, float]]:
        """
        Find free time slots of at least the given duration.
        
        This is a simplified implementation. For a full implementation,
        we would need to track actual scheduled intervals.
        
        :param duration: Required duration
        :param window_start: Start of time window
        :param window_end: End of time window
        :return: List of (start, end) tuples for free slots
        """
        # Simplified: return the entire window if no conflicts
        # A full implementation would analyze scheduled intervals
        if self.consistent():
            if window_end - window_start >= duration:
                return [(window_start, window_end)]
        return []
    
    def copy(self):
        """Create a copy of this STN."""
        new_stn = STN(self.time_unit)
        new_stn.time_points = self.time_points.copy()
        new_stn.constraints = self.constraints.copy()
        return new_stn
    
    def __str__(self):
        return f"STN(time_points={len(self.time_points)}, constraints={len(self.constraints)}, consistent={self.consistent()})"
    
    def __repr__(self):
        return self.__str__()


# ******************************************    Demo / Test Routine         ****************************************** #
if __name__ == '__main__':
    print("Testing STN:")
    
    # Create STN
    stn = STN()
    
    # Add time points
    stn.add_time_point("action1_start")
    stn.add_time_point("action1_end")
    stn.add_time_point("action2_start")
    stn.add_time_point("action2_end")
    
    # Add constraints
    stn.add_constraint("action1_start", "action1_end", (10, 15))  # 10-15 seconds
    stn.add_constraint("action1_end", "action2_start", (0, 5))  # 0-5 seconds gap
    stn.add_constraint("action2_start", "action2_end", (20, 25))  # 20-25 seconds
    
    # Check consistency
    print(f"  STN consistent: {stn.consistent()}")
    print(f"  Distance from action1_start to action2_end: {stn.get_distance('action1_start', 'action2_end')}")

"""
Author(s): K. S. Ernest (iFire) Lee
Temporal extensions: 2025
"""

