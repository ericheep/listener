// speaker-test.ck
// Eric Heep

Noise n;
n.gain(0.0015);

6 => int NUM_SPEAKERS;

while (true) {
    for (int i; i < NUM_SPEAKERS; i++) {
        n => dac.chan(i);
        1.0::second => now;
        n =< dac.chan(i);
    }
}
