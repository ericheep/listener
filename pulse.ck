// pulse.ck
// May 6th, 2017
// Eric Heep

4 => int NUM_SPEAKERS;

10.0 => float threshold;
1.00 => float multiplier;

0.5::second => dur timeout;
400::samp => dur minimumLength;

Distance dist[NUM_SPEAKERS];
Impulse imp[NUM_SPEAKERS];

for (0 => int i; i < NUM_SPEAKERS; i++) {
    adc => dist[i] => blackhole;
    imp[i] => dac.chan(i);

    dist[i].setThreshold(threshold);
    dist[i].setTimeout(timeout);
}

while (true) {
    for (0 => int i; i < NUM_SPEAKERS; i++) {
        0::samp => dur timeDelay;

        imp[i].next(1.0);
        dist[i].measure(minimumLength) => timeDelay;;

        chout <= (timeDelay/second * 1150) + " ";

        if (timeDelay != timeout) {
            timeDelay * multiplier => now;
        } else {
            timeout => now;
        }
    }

    chout.flush();
    chout <= "\n";
}
