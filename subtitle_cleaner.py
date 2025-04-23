#!/usr/bin/env python3
"""
Advanced SRT Subtitle Cleaner

This script thoroughly cleans .srt subtitle files by removing duplicate lines between 
consecutive entries. It specifically addresses the issue where the first line(s) of 
one subtitle entry duplicate the last line(s) of the previous entry.

Usage:
    python subtitle_cleaner_v2.py input.srt output.srt
"""

import re
import sys
from dataclasses import dataclass
from typing import List, Tuple


@dataclass
class SubtitleEntry:
    """Represents a single subtitle entry in an SRT file."""
    number: int
    start_time: str
    end_time: str
    text_lines: List[str]
    
    def is_empty(self) -> bool:
        """Check if the subtitle entry contains meaningful text."""
        return not any(line.strip() for line in self.text_lines)
    
    def get_cleaned_lines(self) -> List[str]:
        """Return non-empty text lines."""
        return [line for line in self.text_lines if line.strip()]


def parse_srt(content: str) -> List[SubtitleEntry]:
    """
    Parse SRT file content into SubtitleEntry objects.
    
    Args:
        content: Raw SRT file content
        
    Returns:
        List of SubtitleEntry objects
    """
    entries = []
    
    # Regular expression to match SRT blocks
    # Each block has: number, timing, and one or more lines of text
    block_pattern = re.compile(r'(\d+)\s*\n(\d{2}:\d{2}:\d{2},\d{3})\s*-->\s*(\d{2}:\d{2}:\d{2},\d{3})\s*\n((?:.+\n?)+?)(?:\n\s*\n|$)', re.MULTILINE)
    
    # Find all blocks in the content
    for match in block_pattern.finditer(content):
        number = int(match.group(1))
        start_time = match.group(2)
        end_time = match.group(3)
        text_block = match.group(4)
        
        # Split text into lines
        text_lines = [line for line in text_block.split('\n') if line]
        
        entry = SubtitleEntry(number, start_time, end_time, text_lines)
        entries.append(entry)
    
    return entries


def remove_duplicates(entries: List[SubtitleEntry]) -> List[SubtitleEntry]:
    """
    Remove duplicate lines between consecutive subtitle entries.
    
    Args:
        entries: List of subtitle entries
        
    Returns:
        Cleaned list of subtitle entries
    """
    if not entries:
        return []
    
    result = [entries[0]]  # Start with the first entry
    
    for i in range(1, len(entries)):
        prev = entries[i-1]
        current = entries[i]
        
        # Skip if either entry is empty
        if prev.is_empty() or current.is_empty():
            result.append(current)
            continue
        
        # Get non-empty lines
        prev_lines = prev.get_cleaned_lines()
        current_lines = current.get_cleaned_lines()
        
        # Check if the first line of current entry matches the last line of previous entry
        if current_lines and prev_lines and current_lines[0] == prev_lines[-1]:
            # Remove the duplicated line from the current entry
            current.text_lines = current.text_lines[1:] if len(current.text_lines) > 1 else []
            
            # Skip this entry if it's now empty
            if current.is_empty():
                continue
        
        result.append(current)
    
    return result


def perform_deep_cleaning(entries: List[SubtitleEntry]) -> List[SubtitleEntry]:
    """
    Perform multiple cleaning passes to catch all duplicate lines.
    
    This function runs removal multiple times to handle cases where:
    1. After removing one duplicate, another duplicate is revealed
    2. Entries become empty after cleaning
    
    Args:
        entries: List of subtitle entries
        
    Returns:
        Deeply cleaned list of subtitle entries
    """
    # Run multiple cleaning passes (5 should be more than enough)
    cleaned = entries
    for _ in range(5):
        prev_count = len(cleaned)
        cleaned = remove_duplicates(cleaned)
        if len(cleaned) == prev_count:
            # No more entries were removed, we're done
            break
    
    # Remove any remaining empty entries
    cleaned = [entry for entry in cleaned if not entry.is_empty()]
    
    # Renumber the entries
    for i, entry in enumerate(cleaned, 1):
        entry.number = i
    
    return cleaned


def format_srt(entries: List[SubtitleEntry]) -> str:
    """
    Format subtitle entries back to SRT format.
    
    Args:
        entries: List of subtitle entries
        
    Returns:
        Formatted SRT content
    """
    lines = []
    for entry in entries:
        lines.append(str(entry.number))
        lines.append(f"{entry.start_time} --> {entry.end_time}")
        lines.extend(entry.text_lines)
        lines.append("")  # Empty line between entries
    
    return "\n".join(lines)


def main():
    """Main function to process SRT files."""
    if len(sys.argv) != 3:
        print("Usage: python subtitle_cleaner_v2.py input.srt output.srt")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    try:
        # Read input file
        with open(input_file, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
        
        # Parse SRT
        entries = parse_srt(content)
        original_count = len(entries)
        
        # Clean duplicates
        cleaned_entries = perform_deep_cleaning(entries)
        
        # Format back to SRT
        cleaned_content = format_srt(cleaned_entries)
        
        # Write output file
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(cleaned_content)
        
        # Print statistics
        print(f"Successfully cleaned subtitles from {input_file} to {output_file}")
        print(f"Original entries: {original_count}, Cleaned entries: {len(cleaned_entries)}")
        
    except Exception as e:
        print(f"Error processing file: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
