#!/usr/bin/env python
"""
File Description: Temporal metadata class for tracking action durations and timing.
"""

from __future__ import print_function, division
from typing import Optional, Union
from datetime import datetime
# Import directly from utils file to avoid triggering full package imports
import sys
import os
# Add path for direct import
_temporal_utils_path = os.path.join(os.path.dirname(__file__), 'temporal', 'utils.py')
if os.path.exists(_temporal_utils_path):
    import importlib.util
    spec = importlib.util.spec_from_file_location("temporal_utils", _temporal_utils_path)
    temporal_utils = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(temporal_utils)
    parse_iso8601_duration = temporal_utils.parse_iso8601_duration
    format_iso8601_duration = temporal_utils.format_iso8601_duration
    parse_iso8601_datetime = temporal_utils.parse_iso8601_datetime
    format_iso8601_datetime = temporal_utils.format_iso8601_datetime
    calculate_end_time = temporal_utils.calculate_end_time
    now_iso8601 = temporal_utils.now_iso8601
else:
    # Fallback to package import if direct import fails
    from ipyhop.temporal.utils import (
        parse_iso8601_duration,
        format_iso8601_duration,
        parse_iso8601_datetime,
        format_iso8601_datetime,
        calculate_end_time,
        now_iso8601
    )


class TemporalMetadata(object):
    """
    Temporal metadata for planning operations.
    
    Stores duration, start_time, and end_time in ISO 8601 format.
    Similar to aria-planner's TemporalConstraints and TimeRange.
    
    Usage:
        metadata = TemporalMetadata(duration="PT1H30M")
        metadata.set_start_time("2025-01-01T10:00:00Z")
        metadata.calculate_end_from_duration()
    """
    
    def __init__(self, duration: Optional[Union[str, float]] = None,
                 start_time: Optional[Union[str, datetime]] = None,
                 end_time: Optional[Union[str, datetime]] = None):
        """
        Initialize temporal metadata.
        
        :param duration: ISO 8601 duration string (e.g., "PT1H30M") or seconds (float)
        :param start_time: ISO 8601 datetime string or datetime object
        :param end_time: ISO 8601 datetime string or datetime object
        """
        self._duration = None
        self._start_time = None
        self._end_time = None
        
        if duration is not None:
            self.set_duration(duration)
        if start_time is not None:
            self.set_start_time(start_time)
        if end_time is not None:
            self.set_end_time(end_time)
    
    @property
    def duration(self) -> Optional[str]:
        """Get duration as ISO 8601 string."""
        return self._duration
    
    @property
    def start_time(self) -> Optional[str]:
        """Get start time as ISO 8601 string."""
        return self._start_time
    
    @property
    def end_time(self) -> Optional[str]:
        """Get end time as ISO 8601 string."""
        return self._end_time
    
    def set_duration(self, duration: Union[str, float]):
        """
        Set duration.
        
        :param duration: ISO 8601 duration string or seconds (float)
        """
        if isinstance(duration, (int, float)):
            self._duration = format_iso8601_duration(float(duration))
        elif isinstance(duration, str):
            # Validate it's a valid ISO 8601 duration
            if parse_iso8601_duration(duration) is not None:
                self._duration = duration
            else:
                raise ValueError(f"Invalid ISO 8601 duration: {duration}")
        else:
            raise TypeError(f"Duration must be str or float, got {type(duration)}")
    
    def set_start_time(self, start_time: Union[str, datetime]):
        """
        Set start time.
        
        :param start_time: ISO 8601 datetime string or datetime object
        """
        if isinstance(start_time, datetime):
            self._start_time = format_iso8601_datetime(start_time)
        elif isinstance(start_time, str):
            # Validate it's a valid ISO 8601 datetime
            if parse_iso8601_datetime(start_time) is not None:
                self._start_time = start_time
            else:
                raise ValueError(f"Invalid ISO 8601 datetime: {start_time}")
        else:
            raise TypeError(f"Start time must be str or datetime, got {type(start_time)}")
    
    def set_end_time(self, end_time: Union[str, datetime]):
        """
        Set end time.
        
        :param end_time: ISO 8601 datetime string or datetime object
        """
        if isinstance(end_time, datetime):
            self._end_time = format_iso8601_datetime(end_time)
        elif isinstance(end_time, str):
            # Validate it's a valid ISO 8601 datetime
            if parse_iso8601_datetime(end_time) is not None:
                self._end_time = end_time
            else:
                raise ValueError(f"Invalid ISO 8601 datetime: {end_time}")
        else:
            raise TypeError(f"End time must be str or datetime, got {type(end_time)}")
    
    def set_start_now(self):
        """Set start time to current time."""
        self._start_time = now_iso8601()
    
    def set_end_now(self):
        """Set end time to current time."""
        self._end_time = now_iso8601()
    
    def calculate_end_from_duration(self) -> bool:
        """
        Calculate end time from start time and duration.
        
        :return: True if calculation succeeded, False otherwise
        """
        if self._start_time is None or self._duration is None:
            return False
        
        end = calculate_end_time(self._start_time, self._duration)
        if end is not None:
            self._end_time = end
            return True
        return False
    
    def calculate_duration(self) -> bool:
        """
        Calculate duration from start time and end time.
        
        :return: True if calculation succeeded, False otherwise
        """
        if self._start_time is None or self._end_time is None:
            return False
        
        start_dt = parse_iso8601_datetime(self._start_time)
        end_dt = parse_iso8601_datetime(self._end_time)
        
        if start_dt is None or end_dt is None:
            return False
        
        delta = end_dt - start_dt
        if delta.total_seconds() < 0:
            return False
        
        self._duration = format_iso8601_duration(delta.total_seconds())
        return True
    
    def duration_seconds(self) -> Optional[float]:
        """
        Get duration in seconds.
        
        :return: Duration in seconds or None
        """
        if self._duration is None:
            return None
        return parse_iso8601_duration(self._duration)
    
    def copy(self):
        """Create a copy of this temporal metadata."""
        return TemporalMetadata(
            duration=self._duration,
            start_time=self._start_time,
            end_time=self._end_time
        )
    
    def to_dict(self) -> dict:
        """
        Convert to dictionary for serialization.
        
        :return: Dictionary with duration, start_time, end_time
        """
        result = {}
        if self._duration is not None:
            result['duration'] = self._duration
        if self._start_time is not None:
            result['start_time'] = self._start_time
        if self._end_time is not None:
            result['end_time'] = self._end_time
        return result
    
    @classmethod
    def from_dict(cls, data: dict):
        """
        Create TemporalMetadata from dictionary.
        
        :param data: Dictionary with duration, start_time, end_time
        :return: TemporalMetadata instance
        """
        return cls(
            duration=data.get('duration'),
            start_time=data.get('start_time'),
            end_time=data.get('end_time')
        )
    
    def __str__(self):
        parts = []
        if self._duration:
            parts.append(f"duration={self._duration}")
        if self._start_time:
            parts.append(f"start={self._start_time}")
        if self._end_time:
            parts.append(f"end={self._end_time}")
        return f"TemporalMetadata({', '.join(parts)})"
    
    def __repr__(self):
        return self.__str__()


# ******************************************    Demo / Test Routine         ****************************************** #
if __name__ == '__main__':
    print("Testing TemporalMetadata:")
    
    # Test with duration only
    tm1 = TemporalMetadata(duration="PT1H30M")
    print(f"  {tm1}")
    
    # Test with start time
    tm2 = TemporalMetadata(duration="PT30M", start_time="2025-01-01T10:00:00Z")
    tm2.calculate_end_from_duration()
    print(f"  {tm2}")
    
    # Test with start and end
    tm3 = TemporalMetadata(start_time="2025-01-01T10:00:00Z", end_time="2025-01-01T10:30:00Z")
    tm3.calculate_duration()
    print(f"  {tm3}")

"""
Author(s): K. S. Ernest (iFire) Lee
Temporal extensions: 2025
"""

