// VEC3.DISPLAY.JS :: UI update functions

import { state, trails, magnitude, getArchetype, getHealthText, valueToStepLabel, archetypes } from './vec3.core.js';
import { stateSatisfiesCard } from './vec3.cards.js';

let tapeValue, pulseValue, gateValue, stateText, magnitudeText, magnitudeBar;
let agentPoint, archetypePanel, archetypeGlyph, archetypeName, archetypeDesc;
let valueTape, valuePulse, valueGate, valueWatcher, valueFlame, valueWeaver, valueCrown;
let healthText;

export function initDisplayElements() {
    tapeValue = document.getElementById('tape-value');
    pulseValue = document.getElementById('pulse-value');
    gateValue = document.getElementById('gate-value');
    stateText = document.getElementById('state-text');
    magnitudeText = document.getElementById('magnitude-text');
    magnitudeBar = document.getElementById('magnitude-bar');
    agentPoint = document.getElementById('agent-point');
    archetypePanel = document.getElementById('archetype-panel');
    archetypeGlyph = document.getElementById('archetype-glyph');
    archetypeName = document.getElementById('archetype-name');
    archetypeDesc = document.getElementById('archetype-desc');
    valueTape = document.getElementById('value-tape');
    valuePulse = document.getElementById('value-pulse');
    valueGate = document.getElementById('value-gate');
    valueWatcher = document.getElementById('value-watcher');
    valueFlame = document.getElementById('value-flame');
    valueWeaver = document.getElementById('value-weaver');
    valueCrown = document.getElementById('value-crown');
    healthText = document.getElementById('health-text');
}

export function updateDisplay() {
    // Display step labels instead of decimal values
    tapeValue.textContent = valueToStepLabel(state.x);
    pulseValue.textContent = valueToStepLabel(state.y);
    gateValue.textContent = valueToStepLabel(state.z);
    stateText.textContent = `( ${state.x.toFixed(2)}, ${state.y.toFixed(2)}, ${state.z.toFixed(2)} )`;
    
    const mag = magnitude(state.x, state.y, state.z);
    const maxMag = magnitude(1, 1, 1);
    magnitudeText.textContent = mag.toFixed(2);
    magnitudeBar.style.width = `${(mag / maxMag) * 100}%`;
    
    const scale = 120;
    // Center the orb at origin, then translate in 3D space
    agentPoint.style.transform = `translate3d(${state.x * scale}px, ${-state.y * scale}px, ${state.z * scale}px)`;
    
    const archetype = getArchetype(state.x, state.y, state.z);
    archetypePanel.className = `archetype-panel archetype-${archetype}`;
    archetypeGlyph.textContent = archetypes[archetype].glyph;
    archetypeName.textContent = archetype;
    archetypeDesc.textContent = archetypes[archetype].desc;
    
    // Card dim = state doesn't satisfy threshold (values pulled from same state; higher auto-lights lesser)
    valueTape.classList.toggle('dim', !stateSatisfiesCard('value-tape', state));
    valuePulse.classList.toggle('dim', !stateSatisfiesCard('value-pulse', state));
    valueGate.classList.toggle('dim', !stateSatisfiesCard('value-gate', state));
    valueFlame.classList.toggle('dim', !stateSatisfiesCard('value-flame', state));
    valueWatcher.classList.toggle('dim', !stateSatisfiesCard('value-watcher', state));
    valueWeaver.classList.toggle('dim', !stateSatisfiesCard('value-weaver', state));
    valueCrown.classList.toggle('dim', !stateSatisfiesCard('value-crown', state));
    
    healthText.textContent = getHealthText(state.x, state.y, state.z);
}

export function updateTrails() {
    const scale = 120;
    trails.forEach((t, i) => {
        const trail = document.getElementById(`trail-${i + 1}`);
        if (trail) {
            trail.style.transform = `translate3d(${t.x * scale - 3}px, ${-t.y * scale - 3}px, ${t.z * scale}px)`;
            trail.style.opacity = 0.1 + (i * 0.1);
        }
    });
}
