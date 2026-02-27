// VEC3.CORE.JS :: State management and math functions

export const archetypes = {
    VOID: { glyph: '○', desc: 'Dormant. No history, no activity, no authority.' },
    SAGE: { glyph: '📚', desc: 'Deep memory, minimal activity. Wisdom over action.' },
    STORM: { glyph: '⚡', desc: 'High activity, low history. Speed over memory.' },
    ORACLE: { glyph: '👁️', desc: 'High authority, low activity. Gatekeeping.' },
    FLAME: { glyph: '🔥', desc: 'Active with memory. Learning and doing.' },
    WEAVER: { glyph: '🕸️', desc: 'Memory plus authority. Architect role.' },
    TIDE: { glyph: '🌊', desc: 'Active and authorized. Full executor.' },
    CROWN: { glyph: '👑', desc: 'Maximum engagement. Deity mode.' },
    MIRROR: { glyph: '🪞', desc: 'Balanced state. Reflects input without bias.' }
};

// Initialize state - all top 3 lit up initially
export let state = { x: 0.5, y: 0.5, z: 0.5 };
export let trails = [];

// Track locked axes (top 3 cards lock their axis when ON)
export const lockedAxes = { x: false, y: false, z: false };

export function magnitude(x, y, z) {
    return Math.sqrt(x*x + y*y + z*z);
}

export function normalize(x, y, z) {
    const mag = magnitude(x, y, z);
    if (mag === 0) return { x: 0, y: 0, z: 0 };
    return { x: x/mag, y: y/mag, z: z/mag };
}

// Archetype thresholds tuned so each MODE has a slice of the slider range (0–1)
export function getArchetype(x, y, z) {
    const mag = magnitude(x, y, z);
    if (mag < 0.18) return 'VOID';       // 0–~0.17
    const dir = normalize(x, y, z);
    if (dir.x > 0.78) return 'SAGE';     // TAPE dominant
    if (dir.y > 0.78) return 'STORM';    // PULSE dominant
    if (dir.z > 0.78) return 'ORACLE';   // WARDEN dominant
    if (dir.x > 0.52 && dir.y > 0.52 && dir.z < 0.38) return 'FLAME';
    if (dir.x > 0.52 && dir.z > 0.52 && dir.y < 0.38) return 'WEAVER';
    if (dir.y > 0.52 && dir.z > 0.52 && dir.x < 0.38) return 'TIDE';
    if (dir.x > 0.48 && dir.y > 0.48 && dir.z > 0.48) return 'CROWN';  // all high
    return 'MIRROR';  // balanced
}

export function getHealthText(x, y, z) {
    const mag = magnitude(x, y, z);
    if (mag < 0.2) return 'Agent dormant. Increase activity or permissions.';
    if (mag > 1.5) return 'Maximum capacity. All systems engaged. Monitor for burnout.';
    const insights = [];
    if (x > 0.7) insights.push('Rich history.');
    if (x < 0.3) insights.push('Limited history.');
    if (y > 0.7) insights.push('High activity.');
    if (y < 0.3) insights.push('Low activity.');
    if (z > 0.7) insights.push('Full permissions.');
    if (z < 0.3) insights.push('Restricted permissions.');
    return insights.length > 0 ? insights.join(' ') : 'Balanced operational state. Ready.';
}

// Map 7-step slider (0-6) to normalized value (0-1)
export function sliderToValue(sliderValue) {
    return sliderValue / 6;
}

// Map normalized value (0-1) to step label — 7 slices, each maps to a MODE zone
export function valueToStepLabel(value) {
    const step = Math.min(6, Math.max(0, Math.round(value * 6)));
    const labels = ['VOID', 'LOW', 'LOW+', 'MID', 'MID+', 'HIGH', 'MAX'];
    return labels[step];
}

// Convert state value (0-1) to nearest slider step (0-6)
export function valueToSliderStep(val) {
    return Math.round(val * 6);
}
