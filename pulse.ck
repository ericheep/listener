// pulse.ck
// May 6th, 2017
// Eric Heep


4 => int NUM_SPEAKERS;
4.0 => float dB;
1::second => dur timeout;
1.0 => float multiplier;
100::samp => dur minimumLength;

Distance dist[NUM_SPEAKERS];
Impulse imp[NUM_SPEAKERS];
Noise nois[NUM_SPEAKERS];

for (0 => int i; i < NUM_SPEAKERS; i++) {
    adc => dist[i] => blackhole;
    imp[i] => dac.chan(i);
    nois[i] => dac.chan(i);
    nois[i].gain(0.0);

    dist[i].setThreshold(dB);
    dist[i].setTimeout(timeout);
}

// spork ~ show();

while (true) {
    for (0 => int i; i < NUM_SPEAKERS; i++) {
        0::samp => dur length;

        imp[i].next(1.0);
        dist[i].measure() => length;;

        <<< i, length, dist[i].decibel() >>>;

        if (length < minimumLength) {
            timeout => now;
        } else if (length != timeout) {
            length * multiplier => now;
        } else {
            timeout => now;
        }

    }
}

fun void show() {
    while (true) {
        1::ms => now;
    }
}
