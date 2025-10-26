#!/usr/bin/env python3
"""
Banner Token Counter
Measures token count and performance impact of Line One banner
"""

import tiktoken

# The actual Line One banner
BANNER = "///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂"

# Test variations
VARIATIONS = {
    "Current (30 chars)": "///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂",
    "Short (20 chars)": "///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂",
    "Medium (25 chars)": "///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂",
    "Long (40 chars)": "///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂",
    "No Unicode (30 chars)": "///#######____________________",
    "Opening blocks only": "///▙▖▙▖▞▞▙",
}

def count_tokens(text, encoding_name="cl100k_base"):
    """Count tokens using specified encoding (default: GPT-4/Claude)"""
    encoding = tiktoken.get_encoding(encoding_name)
    tokens = encoding.encode(text)
    return len(tokens), tokens

def analyze_banner(name, banner):
    """Analyze a banner variant"""
    char_count = len(banner)
    token_count, tokens = count_tokens(banner)
    
    # Calculate efficiency
    chars_per_token = char_count / token_count if token_count > 0 else 0
    
    print(f"\n{'='*60}")
    print(f"VARIANT: {name}")
    print(f"{'='*60}")
    print(f"Character count: {char_count}")
    print(f"Token count:     {token_count}")
    print(f"Chars/token:     {chars_per_token:.2f}")
    print(f"Raw banner:      {banner}")
    print(f"Token IDs:       {tokens[:10]}{'...' if len(tokens) > 10 else ''}")
    
    return {
        "name": name,
        "banner": banner,
        "chars": char_count,
        "tokens": token_count,
        "efficiency": chars_per_token
    }

def main():
    print("BANNER TOKEN ANALYSIS")
    print("=" * 60)
    print(f"Encoding: cl100k_base (GPT-4/Claude)")
    
    results = []
    for name, banner in VARIATIONS.items():
        result = analyze_banner(name, banner)
        results.append(result)
    
    # Summary comparison
    print(f"\n\n{'='*60}")
    print("SUMMARY COMPARISON")
    print(f"{'='*60}")
    print(f"{'Variant':<25} {'Chars':<8} {'Tokens':<8} {'Efficiency':<12}")
    print("-" * 60)
    
    for r in results:
        print(f"{r['name']:<25} {r['chars']:<8} {r['tokens']:<8} {r['efficiency']:<12.2f}")
    
    # Performance impact analysis
    print(f"\n\n{'='*60}")
    print("PERFORMANCE IMPACT")
    print(f"{'='*60}")
    
    # Context: Typical file sizes
    context_sizes = {
        "Small file (500 tokens)": 500,
        "Medium file (2000 tokens)": 2000,
        "Large file (5000 tokens)": 5000,
    }
    
    current = next(r for r in results if r['name'] == "Current (30 chars)")
    
    for context_name, context_tokens in context_sizes.items():
        overhead = (current['tokens'] / context_tokens) * 100
        print(f"{context_name:<30} Banner overhead: {overhead:.3f}%")
    
    # Overhang analysis
    print(f"\n\n{'='*60}")
    print("OVERHANG ANALYSIS")
    print(f"{'='*60}")
    print(f"Banner width: {len(BANNER)} characters")
    print(f"\nTypical editor widths:")
    widths = [80, 100, 120, 140]
    for width in widths:
        overhangs = "YES (overhangs)" if len(BANNER) > width else "NO (fits)"
        print(f"  {width} columns: {overhangs}")

if __name__ == "__main__":
    main()

