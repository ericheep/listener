// OSCVis.ck
// May 6th, 2017
// Eric Heep

public class OSCVis {
    OscOut out;
    out.dest("127.0.0.1", 12000);

    public void update(int idx, dur timeDelay, float decibel) {
        out.start("/u");
        out.add(idx);
        out.add(timeDelay/second);
        out.add(decibel);
        out.send();
    }
}
