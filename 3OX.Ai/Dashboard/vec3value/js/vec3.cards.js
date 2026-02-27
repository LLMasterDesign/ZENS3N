// VEC3.CARDS.JS :: Card state and toggle logic
// Uses explicit activeCards Set — no more inferring from state

const TOP_THREE = ['value-tape', 'value-pulse', 'value-gate'];

// Which cards are currently ON (explicit, not derived from state)
export const activeCards = new Set(TOP_THREE);

// Compute (x,y,z) from active cards. Deterministic, additive stacking.
export function computeStateFromCards() {
    let x = 0, y = 0, z = 0;

    // Mythic overrides everything
    if (activeCards.has('value-crown')) {
        return { x: 1, y: 1, z: 1 };
    }

    // Top 3: each sets its axis to MID when on
    if (activeCards.has('value-tape')) x = 0.5;
    if (activeCards.has('value-pulse')) y = 0.5;
    if (activeCards.has('value-gate')) z = 0.5;

    // Lower cards ADD (never remove). Each only boosts axes that top 3 have turned on.
    // Adaptive Learning: boosts TAPE+PULSE only when those top-3 cards are ON
    if (activeCards.has('value-flame')) {
        if (activeCards.has('value-tape')) x = Math.max(x, 0.67);
        if (activeCards.has('value-pulse')) y = Math.max(y, 0.67);
    }
    // Watcher: mid+ on all three axes (when their top-3 is ON), does not affect Adaptive Learning
    if (activeCards.has('value-watcher')) {
        if (activeCards.has('value-tape')) x = Math.max(x, 0.67);
        if (activeCards.has('value-pulse')) y = Math.max(y, 0.67);
        if (activeCards.has('value-gate')) z = Math.max(z, 0.67);
    }
    if (activeCards.has('value-weaver')) {
        if (activeCards.has('value-tape')) x = Math.max(x, 0.83);
        if (activeCards.has('value-gate')) z = Math.max(z, 0.83);
    }

    return { x, y, z };
}

// Toggle a card: add if off, remove if on. Returns true if card is now ON.
export function toggleCard(cardId) {
    if (activeCards.has(cardId)) {
        activeCards.delete(cardId);
        return false;
    }
    activeCards.add(cardId);
    return true;
}

export function isCardActive(cardId) {
    return activeCards.has(cardId);
}

// Does current state satisfy this card's threshold? (for display + toggle decision)
// Cards pull from same state — higher cards auto-light lesser ones when state satisfies both
export function stateSatisfiesCard(cardId, s) {
    const t = 0.03;  // small tolerance
    switch (cardId) {
        case 'value-tape':    return s.x >= 0.5 - t;
        case 'value-pulse':   return s.y >= 0.5 - t;
        case 'value-gate':    return s.z >= 0.5 - t;
        case 'value-flame':   return s.x >= 0.67 - t && s.y >= 0.67 - t;  // mid+ x2
        case 'value-watcher': return s.x >= 0.67 - t && s.y >= 0.67 - t && s.z >= 0.67 - t;  // mid+ x3
        case 'value-weaver':  return s.x >= 0.83 - t && s.z >= 0.83 - t;
        case 'value-crown':   return s.x >= 0.95 - t && s.y >= 0.95 - t && s.z >= 0.95 - t;
        default: return false;
    }
}

export const neutralState = { x: 0.17, y: 0.17, z: 0.17 };
