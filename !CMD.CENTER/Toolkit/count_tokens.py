#!/usr/bin/env python3
"""Token counter using tiktoken"""

import sys
import tiktoken

def count_tokens(filepath):
    """Count tokens in a file using tiktoken"""
    try:
        # Use cl100k_base encoding (GPT-4, Claude)
        enc = tiktoken.get_encoding('cl100k_base')
        
        with open(filepath, 'r', encoding='utf-8') as f:
            text = f.read()
        
        tokens = enc.encode(text)
        
        print(f"═══════════════════════════════════════════")
        print(f"TOKEN COUNT REPORT")
        print(f"═══════════════════════════════════════════")
        print(f"File: {filepath}")
        print(f"Total tokens: {len(tokens):,}")
        print(f"Total characters: {len(text):,}")
        print(f"Chars per token: {len(text)/len(tokens):.2f}")
        print(f"Lines: {text.count(chr(10)) + 1}")
        print(f"═══════════════════════════════════════════")
        
        return len(tokens)
        
    except Exception as e:
        print(f"Error: {e}")
        return None

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python count_tokens.py <filepath>")
        sys.exit(1)
    
    count_tokens(sys.argv[1])

