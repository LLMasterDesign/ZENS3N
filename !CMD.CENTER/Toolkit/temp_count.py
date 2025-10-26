import tiktoken

# Read the file content from the tool
text = """```r
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.300 // CURSOR.AGENT.CALIBRATION ▞▞
//▞ Agent Identity & Protocol Loader :: ρ{identity}.τ{role}.ν{rules}.λ{protocol} ⫸
▞⌱⟦✅⟧ :: [cursor.bind] [guardian.sentinel] [brain.rs.load] [calibration.protocol]
〔runtime.3ox.context〕

# 🔒 CURSOR AGENT CALIBRATION & ROLE DEFINITION

**Purpose**: Load this prompt when agent drifts or new session starts  
**Workspace**: R:\\!LAUNCH.PAD  
**User**: Lucius  
**Agent Model**: Claude Sonnet 4.5  
**Version**: 1.0.0  
**Last Updated**: 2025-10-20"""

# Get encoding and count
enc = tiktoken.get_encoding('cl100k_base')
tokens = enc.encode(text)

print(f"Sample (first 15 lines): {len(tokens)} tokens")
print(f"Characters: {len(text)}")
print(f"Chars/token: {len(text)/len(tokens):.2f}")

# Full file is about 33x this sample
estimated_full = len(tokens) * 33
print(f"\nEstimated full file: ~{estimated_full} tokens")

