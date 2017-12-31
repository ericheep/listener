// speaker-test.ck
// Eric Heep

Noise n;
n.gain(0.0115);

6 => int NUM_SPEAKERS;

while (true) {
    for (int i; i < NUM_SPEAKERS; i++) {
        n => dac.chan(i);
        0.5::second => now;
        n =< dac.chan(i);
    }
}
