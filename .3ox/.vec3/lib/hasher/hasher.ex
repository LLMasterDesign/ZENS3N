# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xB962]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // HASHER.EX ▞▞
# ▛▞// HASHER.EX :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [merkle] [kernel] [prism] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.hasher.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for HASHER.EX
# ```

# 


# 


#

#
# ▛//▞ PRISM :: KERNEL
# P:: dual.hash{internal ∙ outbound} ∙ pure.elixir.fallback
# R:: xxh128.emulated ∙ sha256.crypto ∙ merkle.tree
# I:: intent.target={integrity.proof ∙ works.without.rust}
# S:: call → compute → return
# M:: "xxh128:{hex}" ∙ "sha256:{hex}"
# :: ∎
#
# ▛//▞ PiCO :: TRACE
# ⊢ ≔ call{function ∙ data.binary}
# ⇨ ≔ compute{internal ∙ crypto}
# ⟿ ≔ format{prefix ∙ hex}
# ▷ ≔ return{hash.string}
# :: ∎

defmodule Vec3.Hasher do
  @moduledoc """
  Vec3.Hasher - Dual-hash computation for 3OX.Ai
  
  Provides both internal (xxh128) and outbound (sha256) hashing.
  Uses pure Elixir crypto, optionally backed by Rust NIF for speed.
  
  ▛//▞ FUNCTIONS
  xxh128/1       → internal.fast.hash (emulated via sha256 prefix)
  sha256/1       → outbound.crypto.hash  
  dual_hash/1    → %{internal: ..., outbound: ...}
  merkle_root/1  → tree.root.hash
  verify_chain/1 → %{valid: bool, break_index: int}
  :: ∎
  """
  
  @doc """
  Compute xxh128 hash (internal, fast).
  
  Note: Currently emulated using sha256 prefix until Rust NIF is compiled.
  """
  @spec xxh128(String.t() | binary()) :: String.t()
  def xxh128(data) when is_binary(data) do
    # Emulate xxh128 using first 32 hex chars of sha256
    hash = :crypto.hash(:sha256, data) |> Base.encode16(case: :lower)
    "xxh128:#{String.slice(hash, 0, 32)}"
  end
  
  @doc """
  Compute sha256 hash (outbound, cryptographic).
  """
  @spec sha256(String.t() | binary()) :: String.t()
  def sha256(data) when is_binary(data) do
    hash = :crypto.hash(:sha256, data) |> Base.encode16(case: :lower)
    "sha256:#{hash}"
  end
  
  @doc """
  Compute sha256 hash from binary data.
  """
  @spec sha256_bytes(binary()) :: String.t()
  def sha256_bytes(data) when is_binary(data) do
    sha256(data)
  end
  
  @doc """
  Compute both internal (xxh128) and outbound (sha256) hashes.
  Returns map with :internal and :outbound keys.
  """
  @spec dual_hash(String.t() | binary()) :: %{internal: String.t(), outbound: String.t()}
  def dual_hash(data) when is_binary(data) do
    full_hash = :crypto.hash(:sha256, data) |> Base.encode16(case: :lower)
    
    %{
      internal: "xxh128:#{String.slice(full_hash, 0, 32)}",
      outbound: "sha256:#{full_hash}"
    }
  end
  
  @doc """
  Compute Merkle tree root from list of hashes.
  """
  @spec merkle_root([String.t()]) :: String.t()
  def merkle_root([]), do: sha256("")
  def merkle_root([single]), do: single
  def merkle_root(hashes) do
    compute_layer(hashes)
  end
  
  defp compute_layer([single]), do: single
  defp compute_layer(layer) do
    next_layer = layer
      |> Enum.chunk_every(2)
      |> Enum.map(fn
        [a, b] -> sha256(a <> b)
        [a] -> sha256(a <> a)  # Duplicate odd node
      end)
    
    compute_layer(next_layer)
  end
  
  @doc """
  Verify hash chain integrity.
  Returns map with :valid and :break_index keys.
  break_index is -1 if chain is valid.
  """
  @spec verify_chain([{String.t(), String.t()}]) :: %{valid: boolean(), break_index: integer()}
  def verify_chain(entries) when is_list(entries) do
    result = entries
      |> Enum.with_index()
      |> Enum.reduce_while({true, -1}, fn {{_hash, prev_hash}, idx}, {_valid, _break} ->
        if idx == 0 do
          {:cont, {true, -1}}
        else
          {prev_entry_hash, _} = Enum.at(entries, idx - 1)
          if prev_hash == prev_entry_hash do
            {:cont, {true, -1}}
          else
            {:halt, {false, idx}}
          end
        end
      end)
    
    {valid, break_index} = result
    %{valid: valid, break_index: break_index}
  end
end
# :: ∎