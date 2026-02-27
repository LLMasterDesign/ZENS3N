# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x4AF7]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // ASK.SH ▞▞
# ▛▞// ASK.SH :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [toml] [token] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.ask.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for ASK.SH
# ```

# 


# 


# ▛//▞ PRISM :: KERNEL
# P:: identity.matrix ∙ context.anchor ∙ execution.flow
# R:: load.context ∙ execute.logic ∙ emit.result
# I:: intent.target={system.stability ∙ function.execution}
# S:: init → process → terminate
# M:: std.io ∙ file.sys ∙ mem.state
# :: ∎

#!/bin/bash
#
# ASK.SH :: LLM Provider Bridge for CMD.BRIDGE
# Ported and adapted from VSO.Agent ask.sh
#

set -euo pipefail

# ============================================================================
# CONFIGURATION & PATHS
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VEC3_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
PROJECT_ROOT="$(cd "$VEC3_ROOT/../../../.." && pwd)"

# Source helpers if available
HELPERS_RB="$VEC3_ROOT/dev/ops/lib/helpers.rb"
if [ -f "$HELPERS_RB" ]; then
    export HELPERS_RB
fi

# Load configuration
CONFIG_FILE="$VEC3_ROOT/rc/infer.toml"
if [ -f "$CONFIG_FILE" ]; then
    # Simple TOML parsing for key values
    parse_toml() {
        local file="$1"
        local section=""
        while IFS= read -r line; do
            # Remove comments and trim
            line=$(echo "$line" | sed 's/#.*$//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
            [ -z "$line" ] && continue

            if [[ $line =~ ^\[(.+)\]$ ]]; then
                section="${BASH_REMATCH[1]}"
            elif [[ $line =~ ^([^=]+)=(.*)$ ]]; then
                local key="${BASH_REMATCH[1]}"
                local value="${BASH_REMATCH[2]}"
                value=$(echo "$value" | sed 's/^["\x27]//' | sed 's/["\x27]$//')
                if [ -n "$section" ]; then
                    eval "${section}_${key//./_}=\"$value\""
                else
                    eval "${key//./_}=\"$value\""
                fi
            fi
        done < "$file"
    }
    parse_toml "$CONFIG_FILE"
fi

# API Keys from secrets
SECRETS_DIR="$VEC3_ROOT/vec3/rc/secrets"
API_KEYS_FILE="$SECRETS_DIR/api.keys"
if [ -f "$API_KEYS_FILE" ]; then
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [ -z "$key" ] && continue

        key=$(echo "$key" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        value=$(echo "$value" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        eval "export $key=\"$value\""
    done < "$API_KEYS_FILE"
fi

# Default configuration
DEFAULT_MODEL="${openai_model:-gpt-4o}"
DEFAULT_PROVIDER="${default_provider:-openai}"
STREAMING="${streaming:-true}"
MAX_TOKENS="${max_tokens:-4096}"
TEMPERATURE="${temperature:-0.7}"

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Get Sirius time if helpers available
    local sirius_time=""
    if command -v ruby >/dev/null 2>&1 && [ -f "$VEC3_ROOT/bin/sirius.clock.rb" ]; then
        sirius_time=$(ruby "$VEC3_ROOT/bin/sirius.clock.rb" 2>/dev/null || echo "")
    fi

    # Log to stderr (for caller to capture if needed)
    echo "[$timestamp] [$level] ASK: $message" >&2

    # Also log via helpers if available
    if [ -f "$HELPERS_RB" ]; then
        ruby -r "$HELPERS_RB" -e "Helpers.log_operation('ask', '$level', '$message')" 2>/dev/null || true
    fi
}

error_exit() {
    local message="$1"
    log "ERROR" "$message"
    echo "Error: $message" >&2
    exit 1
}

# ============================================================================
# PROVIDER FUNCTIONS
# ============================================================================

openai_request() {
    local prompt="$1"
    local system_prompt="$2"
    local model="${3:-$DEFAULT_MODEL}"
    local api_key="${OPENAI_API_KEY:-}"

    [ -z "$api_key" ] && error_exit "OPENAI_API_KEY not found in secrets"

    local payload
    payload=$(cat <<EOF
{
  "model": "$model",
  "messages": [
    {"role": "system", "content": "$system_prompt"},
    {"role": "user", "content": "$prompt"}
  ],
  "max_tokens": $MAX_TOKENS,
  "temperature": $TEMPERATURE,
  "stream": $STREAMING
}
EOF
)

    if [ "$STREAMING" = "true" ]; then
        # Streaming response - process line by line
        if ! curl -s -N -X POST "https://api.openai.com/v1/chat/completions" \
            -H "Authorization: Bearer $api_key" \
            -H "Content-Type: application/json" \
            -d "$payload" 2>/dev/null | while IFS= read -r line; do
                # Parse SSE format: "data: {json}"
                if [[ $line == data:\ * ]]; then
                    json_data="${line#data: }"
                    if [ "$json_data" = "[DONE]" ]; then
                        break
                    fi
                    # Extract content from streaming chunk
                    content=$(echo "$json_data" | jq -r '.choices[0].delta.content // empty' 2>/dev/null || echo "")
                    if [ -n "$content" ] && [ "$content" != "null" ]; then
                        echo -n "$content"
                    fi
                fi
            done; then
            log "ERROR" "OpenAI streaming request failed"
            return 1
        fi
    else
        # Non-streaming response
        local response
        if ! response=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
            -H "Authorization: Bearer $api_key" \
            -H "Content-Type: application/json" \
            -d "$payload" 2>/dev/null); then
            log "ERROR" "OpenAI API request failed"
            return 1
        fi

        # Check for errors
        if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
            local error_msg
            error_msg=$(echo "$response" | jq -r '.error.message // "Unknown OpenAI error"')
            log "ERROR" "OpenAI API error: $error_msg"
            return 1
        fi

        echo "$response" | jq -r '.choices[0].message.content // "No response"' 2>/dev/null
    fi
}

claude_request() {
    local prompt="$1"
    local system_prompt="$2"
    local model="${3:-claude-3-5-sonnet-20241022}"
    local api_key="${ANTHROPIC_API_KEY:-}"

    [ -z "$api_key" ] && error_exit "ANTHROPIC_API_KEY not found in secrets"

    local payload
    payload=$(cat <<EOF
{
  "model": "$model",
  "max_tokens": $MAX_TOKENS,
  "temperature": $TEMPERATURE,
  "system": "$system_prompt",
  "messages": [
    {"role": "user", "content": "$prompt"}
  ],
  "stream": $STREAMING
}
EOF
)

    local response
    if ! response=$(curl -s -X POST "https://api.anthropic.com/v1/messages" \
        -H "x-api-key: $api_key" \
        -H "anthropic-version: 2023-06-01" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>/dev/null); then
        log "ERROR" "Claude API request failed"
        return 1
    fi

    # Extract response content
    if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
        local error_msg
        error_msg=$(echo "$response" | jq -r '.error.message // "Unknown Claude error"')
        log "ERROR" "Claude API error: $error_msg"
        return 1
    fi

    if [ "$STREAMING" = "true" ]; then
        echo "$response" | jq -r '.delta.text // empty' 2>/dev/null || echo ""
    else
        echo "$response" | jq -r '.content[0].text // "No response"' 2>/dev/null
    fi
}

ollama_request() {
    local prompt="$1"
    local system_prompt="$2"
    local model="${3:-llama2}"
    local host="${OLLAMA_HOST:-http://localhost:11434}"

    local payload
    payload=$(cat <<EOF
{
  "model": "$model",
  "prompt": "$prompt",
  "system": "$system_prompt",
  "stream": $STREAMING
}
EOF
)

    local response
    if ! response=$(curl -s -X POST "$host/api/generate" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>/dev/null); then
        log "ERROR" "Ollama API request failed"
        return 1
    fi

    # Extract response content
    if [ "$STREAMING" = "true" ]; then
        echo "$response" | jq -r '.response // empty' 2>/dev/null || echo ""
    else
        echo "$response" | jq -r '.response // "No response"' 2>/dev/null
    fi
}

# ============================================================================
# MAIN ASK FUNCTION WITH FALLBACK
# ============================================================================

ask() {
    local prompt="$1"
    local system_prompt="${2:-You are a helpful AI assistant.}"
    local provider="${3:-$DEFAULT_PROVIDER}"
    local model="$4"
    local response=""

    log "INFO" "Asking provider: $provider, model: ${model:-default}"

    # Try primary provider
    case "$provider" in
        openai)
            if response=$(openai_request "$prompt" "$system_prompt" "$model"); then
                echo "$response"
                return 0
            fi
            ;;
        claude)
            if response=$(claude_request "$prompt" "$system_prompt" "$model"); then
                echo "$response"
                return 0
            fi
            ;;
        ollama)
            if response=$(ollama_request "$prompt" "$system_prompt" "$model"); then
                echo "$response"
                return 0
            fi
            ;;
        *)
            log "ERROR" "Unknown provider: $provider"
            return 1
            ;;
    esac

    # Fallback to Claude if OpenAI failed
    if [ "$provider" = "openai" ] && [ -n "${ANTHROPIC_API_KEY:-}" ]; then
        log "WARNING" "OpenAI failed, trying Claude fallback"
        if response=$(claude_request "$prompt" "$system_prompt"); then
            echo "$response"
            return 0
        fi
    fi

    # Fallback to Ollama if others failed
    if [ -n "${OLLAMA_HOST:-}" ]; then
        log "WARNING" "API providers failed, trying Ollama fallback"
        if response=$(ollama_request "$prompt" "$system_prompt"); then
            echo "$response"
            return 0
        fi
    fi

    log "ERROR" "All providers failed"
    return 1
}

# ============================================================================
# COMMAND LINE INTERFACE
# ============================================================================

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] <prompt>

LLM Provider Bridge for CMD.BRIDGE

OPTIONS:
  -s, --system PROMPT    System prompt (default: helpful assistant)
  -p, --provider NAME    Provider: openai, claude, ollama (default: $DEFAULT_PROVIDER)
  -m, --model NAME       Model name (default: provider-specific)
  -t, --temperature NUM  Temperature (default: $TEMPERATURE)
  -x, --max-tokens NUM   Max tokens (default: $MAX_TOKENS)
  --no-stream            Disable streaming
  -h, --help            Show this help

ENVIRONMENT:
  OPENAI_API_KEY        OpenAI API key (from secrets/api.keys)
  ANTHROPIC_API_KEY     Claude API key (from secrets/api.keys)
  OLLAMA_HOST           Ollama server URL (default: http://localhost:11434)

CONFIG:
  $CONFIG_FILE          Provider configuration

EXAMPLES:
  $0 "Hello, how are you?"
  $0 -p claude -m claude-3-5-sonnet "Explain quantum computing"
  $0 -s "You are a code reviewer" "Review this code: ..."
  echo "What is AI?" | $0 -p ollama

EOF
}

main() {
    local system_prompt="You are a helpful AI assistant operating within the CMD.BRIDGE framework."
    local provider="$DEFAULT_PROVIDER"
    local model=""
    local temperature="$TEMPERATURE"
    local max_tokens="$MAX_TOKENS"
    local streaming="$STREAMING"

    # Check if first argument is a provider name
    if [[ $# -gt 0 ]] && [[ "$1" =~ ^(openai|claude|ollama)$ ]]; then
        provider="$1"
        shift
    fi

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--system)
                system_prompt="$2"
                shift 2
                ;;
            -p|--provider)
                provider="$2"
                shift 2
                ;;
            -m|--model)
                model="$2"
                shift 2
                ;;
            -t|--temperature)
                temperature="$2"
                shift 2
                ;;
            -x|--max-tokens)
                max_tokens="$2"
                shift 2
                ;;
            --no-stream)
                streaming="false"
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                break
                ;;
        esac
    done

    # Get prompt from arguments or stdin
    local prompt=""
    if [ $# -gt 0 ]; then
        prompt="$*"
    elif [ ! -t 0 ]; then
        prompt=$(cat)
    else
        error_exit "No prompt provided. Use '$0 <prompt>' or pipe input."
    fi

    [ -z "$prompt" ] && error_exit "Empty prompt"

    # Set runtime overrides
    export TEMPERATURE="$temperature"
    export MAX_TOKENS="$max_tokens"
    export STREAMING="$streaming"

    # Make the request
    if response=$(ask "$prompt" "$system_prompt" "$provider" "$model"); then
        echo "$response"
        log "COMPLETE" "Response generated (${#response} chars)"
        exit 0
    else
        log "ERROR" "Failed to get response from any provider"
        exit 1
    fi
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# :: ∎