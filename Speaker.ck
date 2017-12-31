// December, 2017

// Speaker.ck
// Eric Heep

public class Speaker extends Chubgraph {

    inlet => Gain g => blackhole;
    inlet => g;
    3 => g.op;

    Impulse impls => Gain implsGain => outlet;

    1.0 => float m_gainValue;
    0.0 => float m_threshold;
    1.0 => float m_impulseVolume;
    0::samp => dur m_timeoutDuration;
    852::samp => dur m_minLength;
    0 => int m_timeoutState;

    setTimeoutDuration(1::second);

    fun void setDecibelThreshold(float t) {
        t => m_threshold;
    }

    fun void setTimeoutDuration(dur t) {
        t => m_timeoutDuration;
    }

    fun dur getTimeoutDuration() {
        return m_timeoutDuration;
    }

    fun void setMinLength(dur l) {
        l => m_minLength;
    }

    fun float getDecibelLevel() {
        return Std.powtodb(g.last());
    }

    fun int getTimeoutState() {
        return m_timeoutState;
    }

    fun void turnOffListener() {
        g.gain(0.0);
    }

    fun void turnOnListener() {
        g.gain(m_gainValue);
    }

    fun void setGain(float gn) {
        gn => m_gainValue;
        g.gain(gn);
    }

    fun int isBelowAudioThreshold() {
        return getDecibelLevel() < m_threshold;
    }

    fun int isBeforeTimeThreshold(time start) {
        return (now - start) < m_minLength;
    }

    fun void impulse() {
        impls.next(m_impulseVolume);
    }

    fun int listenAndWait() {
        turnOnListener();
        now => time start;

        while (isBeforeTimeThreshold(start) || isBelowAudioThreshold()) {
            samp => now;

            if (now - start > m_timeoutDuration) {
                turnOffListener();
                return 1;
            }
        }

        turnOffListener();
        return 0;
    }

    fun float findImpulsePeak(int samplesToScan) {
        turnOnListener();
        impls.next(1.0);

        float decibelMax;
        int whatSampleHit;
        for (0 => int i; i < samplesToScan; i++) {
            if (getDecibelLevel() > decibelMax) {
                getDecibelLevel() => decibelMax;
                i => whatSampleHit;
            }
            samp => now;
        }
        return decibelMax;
    }

    fun float findImpulseVolume(float dbToMatch, int iterations) {
        float finalDb;
        for (0 => int i; i < iterations; i++) {
            findImpulsePeak(1500) => float impulsePeak;
            0.05::second => now;

            if (impulsePeak < dbToMatch) {
                if (implsGain.gain() < 1.0) {
                    implsGain.gain() + 0.02 => implsGain.gain;
                }
            } else {
                if (implsGain.gain() > 0.0) {
                    implsGain.gain() - 0.02 => implsGain.gain;
                }
            }

            impulsePeak => finalDb;
        }
        <<< finalDb, implsGain.gain() >>>;
    }

    fun float findAverageImpulsePeak(int iterations) {
        float sum;
        iterations => int n;
        for (0 => int i; i < iterations; i++) {
            findImpulsePeak(1500) => float impulsePeak;
            0.05::second => now;
            if (impulsePeak > 0) {
                impulsePeak +=> sum;
            } else {
               n--;
            }
        }
        return sum/n;
    }
}
