// Distance.ck
// May 13th, 2017
// Eric Heep

public class Distance extends Chubgraph {

    inlet => Gain g => OnePole p => outlet;
    inlet => g;

    3 => g.op;

    0.0 => float m_dB;
    0::samp => dur m_timeout;
    0::samp => dur m_maxTimeout;
    1000::samp => dur m_minLength;
    0 => int m_timeoutState;

    fun void setThreshold(float dB) {
        dB => m_dB;
    }

    fun void setTimeout(dur t) {
        t => m_timeout;
    }

    fun void setMinLength(dur l) {
        l => m_minLength;
    }

    fun void setMaxTimeout(dur m) {
        m => m_maxTimeout;
    }

    setThreshold(10.0);
    setTimeout(1::second);
    setMaxTimeout(1::second);

    fun float decibel() {
        return Std.rmstodb(p.last());
    }

    fun int getTimeoutState() {
        return m_timeoutState;
    }

    fun void resetFollower() {
        g.gain(0.0);
        0.0 => p.pole;
    }

    fun dur measureDistance() {
        0.2 => p.pole;
        g.gain(1.0);

        now => time start;
        while (decibel() < m_dB || (now - start) < m_minLength) {
            samp => now;

            if ((now - start) > m_timeout) {
                resetFollower();
                true => m_timeoutState;
                return m_timeout;
            }
            if ((now - start) > m_maxTimeout) {
                resetFollower();
                true => m_timeoutState;
                return m_maxTimeout;
            }
        }
        resetFollower();
        false => m_timeoutState;

        return (now - start);
    }
}
