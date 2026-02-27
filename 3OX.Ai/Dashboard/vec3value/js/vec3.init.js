// VEC3.INIT.JS :: Initialization and event listeners

import { state, trails, sliderToValue, valueToSliderStep } from './vec3.core.js';
import { activeCards, computeStateFromCards, stateSatisfiesCard } from './vec3.cards.js';
import { initDisplayElements, updateDisplay, updateTrails } from './vec3.display.js';

// Wait for DOM to be ready
function init() {
    console.log('VEC3: Initializing...');

    // Initialize DOM elements
    try {
        initDisplayElements();
        console.log('VEC3: Display elements initialized');
    } catch (e) {
        console.error('VEC3: Failed to init display:', e);
        return;
    }

    // Get slider elements
    const tapeSlider = document.getElementById('tape-slider');
    const pulseSlider = document.getElementById('pulse-slider');
    const gateSlider = document.getElementById('gate-slider');

    if (!tapeSlider || !pulseSlider || !gateSlider) {
        console.error('VEC3: Sliders not found!', { tapeSlider, pulseSlider, gateSlider });
        return;
    }

    console.log('VEC3: Sliders found, setting up handlers');

    let skipCardsSync = false;  // true when applyState is driving sliders (card click)

    function applyState(newState) {
        trails.push({ ...state });
        if (trails.length > 3) trails.shift();

        state.x = newState.x;
        state.y = newState.y;
        state.z = newState.z;

        skipCardsSync = true;
        tapeSlider.value = valueToSliderStep(state.x);
        pulseSlider.value = valueToSliderStep(state.y);
        gateSlider.value = valueToSliderStep(state.z);
        setTimeout(() => { skipCardsSync = false; }, 100);

        updateTrails();
        updateDisplay();
    }

    function updateSnapClasses(slider, rawVal) {
        const dist = Math.abs(rawVal - Math.round(rawVal));
        slider.classList.toggle('snap-zone', dist < 0.15);
    }

    function handleSliderInput() {
        trails.push({ ...state });
        if (trails.length > 3) trails.shift();
        const tv = parseFloat(tapeSlider.value);
        const pv = parseFloat(pulseSlider.value);
        const gv = parseFloat(gateSlider.value);
        state.x = sliderToValue(tv);
        state.y = sliderToValue(pv);
        state.z = sliderToValue(gv);
        updateSnapClasses(tapeSlider, tv);
        updateSnapClasses(pulseSlider, pv);
        updateSnapClasses(gateSlider, gv);
        updateTrails();
        updateDisplay();
    }

    function handleSliderChange() {
        const tapeVal = Math.round(parseFloat(tapeSlider.value));
        const pulseVal = Math.round(parseFloat(pulseSlider.value));
        const gateVal = Math.round(parseFloat(gateSlider.value));
        tapeSlider.value = tapeVal;
        pulseSlider.value = pulseVal;
        gateSlider.value = gateVal;
        [tapeSlider, pulseSlider, gateSlider].forEach(s => {
            s.classList.remove('snap-zone');
            s.classList.add('snap-bounce');
            setTimeout(() => s.classList.remove('snap-bounce'), 260);
        });
        state.x = sliderToValue(tapeVal);
        state.y = sliderToValue(pulseVal);
        state.z = sliderToValue(gateVal);
        if (!skipCardsSync) {
            const CARD_IDS_SYNC = ['value-tape', 'value-pulse', 'value-gate', 'value-flame', 'value-watcher', 'value-weaver', 'value-crown'];
            CARD_IDS_SYNC.forEach(id => {
                if (stateSatisfiesCard(id, state)) activeCards.add(id);
                else activeCards.delete(id);
            });
        }
        updateTrails();
        updateDisplay();
    }

    tapeSlider.addEventListener('input', handleSliderInput);
    tapeSlider.addEventListener('change', handleSliderChange);
    pulseSlider.addEventListener('input', handleSliderInput);
    pulseSlider.addEventListener('change', handleSliderChange);
    gateSlider.addEventListener('input', handleSliderInput);
    gateSlider.addEventListener('change', handleSliderChange);

    const CARD_IDS = ['value-tape', 'value-pulse', 'value-gate', 'value-flame', 'value-watcher', 'value-weaver', 'value-crown'];
    const LOWER_CARDS = ['value-flame', 'value-watcher', 'value-weaver', 'value-crown'];

    document.querySelectorAll('.value-item').forEach(card => {
        card.addEventListener('click', () => {
            const cardId = card.id;
            if (!CARD_IDS.includes(cardId)) return;

            // Toggle based on state: if state satisfies card, turn OFF (remove); else turn ON (add)
            const turningOff = stateSatisfiesCard(cardId, state);
            if (turningOff) {
                if (cardId === 'value-crown') {
                    // Mythic OFF → Architect value
                    activeCards.clear();
                    activeCards.add('value-tape');
                    activeCards.add('value-pulse');
                    activeCards.add('value-gate');
                    activeCards.add('value-flame');
                    activeCards.add('value-watcher');
                    activeCards.add('value-weaver');
                } else if (cardId === 'value-watcher') {
                    // Watcher OFF → previous card value (Adaptive Learning: base3 + AL)
                    activeCards.clear();
                    activeCards.add('value-tape');
                    activeCards.add('value-pulse');
                    activeCards.add('value-gate');
                    activeCards.add('value-flame');
                } else if (cardId === 'value-flame') {
                    // Adaptive Learning OFF → base3 only
                    activeCards.delete('value-flame');
                    activeCards.delete('value-watcher');
                    activeCards.delete('value-weaver');
                    activeCards.delete('value-crown');
                } else if (cardId === 'value-weaver') {
                    // Architect OFF → previous card value (Watcher: base3 + AL + Watcher)
                    activeCards.clear();
                    activeCards.add('value-tape');
                    activeCards.add('value-pulse');
                    activeCards.add('value-gate');
                    activeCards.add('value-flame');
                    activeCards.add('value-watcher');
                } else if (activeCards.has('value-crown')) {
                    // Mythic is on: must remove Mythic first so lower-card OFF takes effect
                    activeCards.delete('value-crown');
                    activeCards.delete(cardId);
                } else {
                    activeCards.delete(cardId);
                }
            } else {
                if (LOWER_CARDS.includes(cardId)) {
                    activeCards.add('value-tape');
                    activeCards.add('value-pulse');
                    activeCards.add('value-gate');
                }
                activeCards.add(cardId);
                // Architect ON → Watcher and Adaptive Learning must also be on (state pulls from same source)
                if (cardId === 'value-weaver') {
                    activeCards.add('value-flame');
                    activeCards.add('value-watcher');
                }
                // Real-Time (value-pulse) ON → pulse stays at 0.5, do NOT turn on Adaptive Learning; drop higher cards so state stays consistent
                if (cardId === 'value-pulse') {
                    activeCards.delete('value-flame');
                    activeCards.delete('value-watcher');
                    activeCards.delete('value-weaver');
                    activeCards.delete('value-crown');
                }
            }

            let newState = computeStateFromCards();
            applyState(newState);
        });
    });

    // Initial state from activeCards (top 3 default on)
    applyState(computeStateFromCards());

    console.log('VEC3: Initialization complete');
}

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}
