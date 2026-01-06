#!/usr/bin/env python
"""
File Description: Temporal utilities for ISO 8601 duration parsing and time arithmetic.
"""

from __future__ import print_function, division
from datetime import datetime, timedelta
import re
from typing import Union, Optional, Tuple


def parse_iso8601_duration(duration_str: str) -> Optional[float]:
    """
    Parse an ISO 8601 duration string into seconds.
    
    Supports formats like:
    - PT1H30M (1 hour 30 minutes)
    - PT5M (5 minutes)
    - PT30S (30 seconds)
    - PT1H30M45S (1 hour 30 minutes 45 seconds)
    - PT0.5S (0.5 seconds)
    
    :param duration_str: ISO 8601 duration string (e.g., "PT1H30M")
    :return: Duration in seconds as float, or None if parsing fails
    """
    if not duration_str or not isinstance(duration_str, str):
        return None
    
    # Remove PT prefix
    if not duration_str.startswith('PT'):
        return None
    
    duration_str = duration_str[2:]
    
    # Pattern to match time components: H, M, S with optional decimal seconds
    pattern = r'(?:(\d+(?:\.\d+)?)H)?(?:(\d+(?:\.\d+)?)M)?(?:(\d+(?:\.\d+)?)S)?'
    match = re.match(pattern, duration_str)
    
    if not match:
        return None
    
    hours = float(match.group(1) or 0)
    minutes = float(match.group(2) or 0)
    seconds = float(match.group(3) or 0)
    
    total_seconds = hours * 3600 + minutes * 60 + seconds
    return total_seconds


def format_iso8601_duration(seconds: float) -> str:
    """
    Format seconds into an ISO 8601 duration string.
    
    :param seconds: Duration in seconds
    :return: ISO 8601 duration string (e.g., "PT1H30M45S")
    """
    if seconds < 0:
        seconds = 0
    
    hours = int(seconds // 3600)
    remaining = seconds % 3600
    minutes = int(remaining // 60)
    secs = remaining % 60
    
    parts = []
    if hours > 0:
        parts.append(f"{hours}H")
    if minutes > 0:
        parts.append(f"{minutes}M")
    if secs > 0 or (hours == 0 and minutes == 0):
        # Format seconds, handling decimals
        if secs == int(secs):
            parts.append(f"{int(secs)}S")
        else:
            # Format with up to 6 decimal places, remove trailing zeros
            secs_str = f"{secs:.6f}".rstrip('0').rstrip('.')
            parts.append(f"{secs_str}S")
    
    return "PT" + "".join(parts) if parts else "PT0S"


def parse_iso8601_datetime(datetime_str: str) -> Optional[datetime]:
    """
    Parse an ISO 8601 datetime string.
    
    :param datetime_str: ISO 8601 datetime string (e.g., "2025-01-01T10:00:00Z")
    :return: datetime object or None if parsing fails
    """
    try:
        # Try parsing with timezone
        if datetime_str.endswith('Z'):
            datetime_str = datetime_str[:-1] + '+00:00'
        return datetime.fromisoformat(datetime_str.replace('Z', '+00:00'))
    except (ValueError, AttributeError):
        return None


def format_iso8601_datetime(dt: datetime) -> str:
    """
    Format a datetime object into an ISO 8601 string.
    
    :param dt: datetime object
    :return: ISO 8601 datetime string
    """
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=datetime.now().astimezone().tzinfo)
    return dt.isoformat().replace('+00:00', 'Z')


def add_duration_to_datetime(dt: Union[datetime, str], duration: Union[float, str]) -> Optional[datetime]:
    """
    Add a duration to a datetime.
    
    :param dt: datetime object or ISO 8601 string
    :param duration: duration in seconds (float) or ISO 8601 duration string
    :return: new datetime object or None if parsing fails
    """
    if isinstance(dt, str):
        dt = parse_iso8601_datetime(dt)
        if dt is None:
            return None
    
    if isinstance(duration, str):
        duration_seconds = parse_iso8601_duration(duration)
        if duration_seconds is None:
            return None
    else:
        duration_seconds = duration
    
    return dt + timedelta(seconds=duration_seconds)


def calculate_end_time(start_time: Union[datetime, str], duration: Union[float, str]) -> Optional[str]:
    """
    Calculate end time from start time and duration.
    
    :param start_time: datetime object or ISO 8601 string
    :param duration: duration in seconds (float) or ISO 8601 duration string
    :return: ISO 8601 datetime string or None if calculation fails
    """
    end_dt = add_duration_to_datetime(start_time, duration)
    if end_dt is None:
        return None
    return format_iso8601_datetime(end_dt)


def duration_to_seconds(duration: Union[str, float]) -> Optional[float]:
    """
    Convert duration to seconds.
    
    :param duration: ISO 8601 duration string or seconds (float)
    :return: duration in seconds or None if parsing fails
    """
    if isinstance(duration, (int, float)):
        return float(duration)
    elif isinstance(duration, str):
        return parse_iso8601_duration(duration)
    return None


def now_iso8601() -> str:
    """
    Get current time as ISO 8601 string.
    
    :return: ISO 8601 datetime string
    """
    return format_iso8601_datetime(datetime.utcnow())


# ******************************************    Demo / Test Routine         ****************************************** #
if __name__ == '__main__':
    # Test parsing
    test_durations = ["PT1H30M", "PT5M", "PT30S", "PT1H30M45S", "PT0.5S", "PT2H"]
    print("Testing duration parsing:")
    for d in test_durations:
        seconds = parse_iso8601_duration(d)
        print(f"  {d} -> {seconds} seconds")
    
    # Test formatting
    test_seconds = [5400, 300, 30, 5445, 0.5, 7200]
    print("\nTesting duration formatting:")
    for s in test_seconds:
        formatted = format_iso8601_duration(s)
        print(f"  {s} seconds -> {formatted}")
    
    # Test datetime operations
    print("\nTesting datetime operations:")
    start = "2025-01-01T10:00:00Z"
    duration = "PT1H30M"
    end = calculate_end_time(start, duration)
    print(f"  Start: {start}, Duration: {duration}, End: {end}")

"""
Author(s): K. S. Ernest (iFire) Lee
Temporal extensions: 2025
"""

