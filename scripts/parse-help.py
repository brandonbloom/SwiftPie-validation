#!/usr/bin/env python3
"""
Parse HTTPie help output and extract features.

This script reads http --help output and extracts structured feature information
for use by the checklist-curator agent.

Usage:
  ./parse-help.py < /path/to/help.txt
  cat help.txt | ./parse-help.py
"""

import sys
import re
import json

def parse_help_output(help_text):
    """
    Parse http --help output and extract features.

    Returns a list of dicts with keys: name, flag, description, slug
    """
    features = []
    lines = help_text.split('\n')

    current_section = None
    i = 0

    while i < len(lines):
        line = lines[i]

        # Skip empty lines
        if not line.strip():
            i += 1
            continue

        # Detect section headers (all caps, no leading spaces)
        if line and line[0] not in (' ', '\t') and line.isupper():
            current_section = line.strip()
            i += 1
            continue

        # Look for flag patterns: "  -X, --flag-name" or "  -X" or "  --flag-name"
        flag_match = re.match(r'^\s+(-[a-zA-Z])?(?:,\s+)?(--[\w-]+)?', line)
        if flag_match:
            # Extract the flag(s) and description
            flag_part = line.split(maxsplit=1)[0] if line.strip() else ''

            # Description is the rest of the line after flags
            rest = line.lstrip()
            # Skip past the flags
            desc_start = 0
            for j, char in enumerate(rest):
                if char not in '-,. \t':
                    desc_start = j
                    break

            description = rest[desc_start:].strip() if desc_start < len(rest) else ''

            # Generate slug from flag
            slug = flag_match.group(2) if flag_match.group(2) else flag_match.group(1)
            if slug:
                slug = slug.lstrip('-').replace('-', '-')

            if description and slug:
                features.append({
                    'name': description.split('\n')[0][:60],  # First 60 chars
                    'flag': flag_part.strip(),
                    'description': description.split('\n')[0],
                    'section': current_section,
                    'slug': slug
                })

        i += 1

    return features

if __name__ == '__main__':
    help_text = sys.stdin.read()
    features = parse_help_output(help_text)

    for feature in features:
        print(json.dumps(feature))
