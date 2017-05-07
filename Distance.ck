// Distance.ck
// May 6th, 2017
// Eric Heep

public class Distance extends Chubgraph {

    inlet => Gain g => OnePole p => outlet;
    inlet => g;

    3 => g.op;

    0.0 => float m_dB;
    0::samp => dur m_timeout;

    fun void setThreshold(float dB) {
        dB => m_dB;
    }

    fun void setTimeout(dur t) {
        t => m_timeout;
    }

    setThreshold(10.0);
    setTimeout(1::second);

    fun float decibel() {
        return Std.rmstodb(p.last());
    }

    fun dur measure(dur min) {
        0.4 => p.pole;
        g.gain(1.0);
        now => time start;
        while (decibel() < m_dB || (now - start) < min) {
            samp => now;
            if ((now - start) > m_timeout) {
                return m_timeout;
            }
        }
        g.gain(0.0);
        0.0 => p.pole;

        return (now - start);
    }
}
