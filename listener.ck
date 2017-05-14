// listener.ck
// May 13th, 2017
// Eric Heep

6 => int NUM_SPEAKERS;
10.0 => float THRESHOLD;
2.00 => float TIMEOUT_MULTIPLIER;
1000::samp => dur MIN_LENGTH;
1.00::second => dur MAX_TIMEOUT;

0.0::samp => dur m_timeout;

Distance dist[NUM_SPEAKERS];
Impulse imp[NUM_SPEAKERS];
dur timeDelays[NUM_SPEAKERS];

for (0 => int i; i < NUM_SPEAKERS; i++) {
    adc => dist[i] => blackhole;
    imp[i] => dac.chan(i);

    MAX_TIMEOUT => timeDelays[i];
    dist[i].setMinLength(MIN_LENGTH);
    dist[i].setThreshold(THRESHOLD);
    dist[i].setMaxTimeout(MAX_TIMEOUT);
}

fun dur mean(dur arr[]) {
    0::samp => dur sum;
    for (0 => int i; i < arr.size(); i++) {
        arr[i] +=> sum;
    }
    return sum/arr.size();
}

10::second => now;

while (true) {
    for (0 => int i; i < NUM_SPEAKERS; i++) {
        mean(timeDelays) => m_timeout;
        dist[i].setTimeout(m_timeout * TIMEOUT_MULTIPLIER);

        imp[i].next(1.0);
        dist[i].measureDistance() => timeDelays[i];

        if (dist[i].getTimeoutState()) {
            m_timeout * TIMEOUT_MULTIPLIER => now;
            chout <= "TIMEOUT\t";
        } else {
            chout <= (timeDelays[i]/samp)$int + "\t";
        }


    }

    chout <= "| Avg: " + (mean(timeDelays)/samp)$int;
    chout.flush();
    chout <= "\n";
}

