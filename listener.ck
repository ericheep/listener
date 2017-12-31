// listener.ck
// Dec 30th, 2017
// Eric Heep

[1.0, 1.0, 0.68, 0.48, 0.86, 0.60] @=> float gains[];
// [1.0, 1.0, 1.0, 1.0, 1.0, 1.0] @=> float gains[];
[81, 87, 69, 82, 84, 89] @=> int topHomeRow[];

Hid hi;
HidMsg msg;

if (!hi.openKeyboard(0)) {
    me.exit();
}

2 => int NUM_SPEAKERS;
false => int findAverageThreshold;
false => int adjustGains;
int speakerStates[NUM_SPEAKERS];

1000::ms => dur maxTimeoutDuration;
50::ms => dur minTimeoutDuration;
maxTimeoutDuration => dur initialTimeoutDuration;
maxTimeoutDuration => dur timeoutDuration;

Speaker spkr[NUM_SPEAKERS];
float impulsePeaks[NUM_SPEAKERS];

// connect speakers
for (0 => int i; i < NUM_SPEAKERS; i++) {
    adc => spkr[i] => dac.chan(i);
}

// let things calm down
1.0::second => now;

0.0 => float averageThreshold;
43.0 => float setThreshold;

// analyze "room"
for (0 => int i; i < NUM_SPEAKERS; i++) {
    1 => speakerStates[i];
    spkr[i].setGain(gains[i]);
    spkr[i].setTimeoutDuration(initialTimeoutDuration);
    if (findAverageThreshold) {
        spkr[i].findAverageImpulsePeak(10) => float impulsePeak;
        impulsePeak/NUM_SPEAKERS +=> averageThreshold;
        spkr[i].setDecibelThreshold(averageThreshold + 3);
    }
    spkr[i].setDecibelThreshold(setThreshold);
}

// adjust gains
if (adjustGains) {
    for (0 => int i; i < NUM_SPEAKERS; i++) {
        spkr[i].findImpulseVolume(averageThreshold, 30);
    }
}

fun void impulseAndListen(int idx) {
    spkr[idx].impulse();
    spkr[idx].listenAndWait() => int isTimeout;

    if (isTimeout) {
        15::ms +=> timeoutDuration;
        if (timeoutDuration > maxTimeoutDuration) {
            maxTimeoutDuration => timeoutDuration;
        }
    } else {
        20::ms -=> timeoutDuration;
        if (timeoutDuration < minTimeoutDuration) {
            minTimeoutDuration => timeoutDuration;
        }
    }

    spkr[idx].setTimeoutDuration(timeoutDuration);
}

fun void cycleSpeakers(dur length, int numSpeakers) {
    now => time start;
    while (now - start < length) {
        for (int i; i < numSpeakers; i++) {
            if (speakerStates[i]) {
                impulseAndListen(i);
            }
        }
        0 => int check;
        for (int i; i < NUM_SPEAKERS; i++) {
            speakerStates[i] +=> check;
        }
        if (check == 0) {
            samp => now;
        }
    }
}

spork ~ keyboard();

fun void main() {
    cycleSpeakers(25::minute, NUM_SPEAKERS);
}

fun void keyboard() {
    while (true) {
        hi => now;
        while (hi.recv(msg)) {
            for (int i; i < 6; i++) {
                if (msg.ascii == i + 49) {
                    if (msg.isButtonDown()) {
                        !speakerStates[i] => speakerStates[i];
                        <<< speakerStates[0], speakerStates[1], speakerStates[2],
                            speakerStates[3], speakerStates[4], speakerStates[5] >>>;
                    }
                }
                if (msg.ascii == topHomeRow[i]) {
                    if (msg.isButtonDown()) {
                        for (int j; j < NUM_SPEAKERS; j++) {
                            if (i == j) {
                                1 => speakerStates[j];
                            } else {
                                0 => speakerStates[j];
                            }
                        }
                        <<< speakerStates[0], speakerStates[1], speakerStates[2],
                            speakerStates[3], speakerStates[4], speakerStates[5] >>>;
                    }
                }
            }
        }
    }
}

1::second => now;

main();

