(
s = Server.default;
s.options.numBuffers = 1024 * 64;
s.options.memSize = 65536 * 4; // 8192 * 16;
s.options.maxNodes = 1024 * 32;
s.options.sampleRate = 44100;
s.options.numOutputBusChannels = 16;
s.options.numInputBusChannels = 16;
s.reboot
;
//start proxyspace
p = ProxySpace.push(s);
p.makeTempoClock;
p.clock.tempo = 2;
p.quant = 4
;
r = Repetition(p);
m = r.initMIDI("Midi Through", "Midi Through Port-0")
;
("./balc.synthdefs.scd").loadRelative
;
("./snippets.scd").loadRelative;
TinySnippets.enable("y", z)
;
Task({
  var cfg = ();
  // setup repetition midi stuff
  r.midiEventTypes;
  // load drum kits
  r.loadKit("/home/mauro/baku/livecode/BALC/sf2/kits/");
  2.wait;
  // setup fluidsynth
  f = FluidSynth(\jack, 16, 16); // multichan
  // f = FluidSynth.new; // simple stereo
  f.setGain(0.95);
  // setup fluidsynth
  f.loadSoundfont("~/baku/livecode/BALC/sf2/balc.min.sf2");
  1.wait;
  f.selectInstruments([
    // vox
    (\chan: 1, \sfont: 1, \bank: 1, \prog: 2), // vox
    (\chan: 2, \sfont: 1, \bank: 1, \prog: 1), // numbers
    // bass
    (\chan: 3, \sfont: 1, \bank: 3, \prog: 9), // tbBqass9
    //stabs
    (\chan: 4, \sfont: 1, \bank: 0, \prog: 4), // synTone
    (\chan: 5, \sfont: 1, \bank: 0, \prog: 1), // stab
    (\chan: 6, \sfont: 1, \bank: 0, \prog: 2), // miniRave
    // percs
    (\chan: 7, \sfont: 1, \bank: 127, \prog: 4), // think
    (\chan: 8, \sfont: 1, \bank: 127, \prog: 5), // amen
    // drums
    (\chan: 9, \sfont: 1, \bank: 128, \prog: 10), // ichor
    (\chan: 10, \sfont: 1, \bank: 128, \prog: 10), // ichor
    (\chan: 11, \sfont: 1, \bank: 128, \prog: 4), // microStudies
    (\chan: 12, \sfont: 1, \bank: 128, \prog: 3), // studies
    (\chan: 13, \sfont: 1, \bank: 128, \prog: 11), // Rome
    (\chan: 14, \sfont: 1, \bank: 128, \prog: 16), // Mark
  ]);
  f.listChannels;
  f.pr_send("reverb 0");
  f.pr_send("chorus 0");
  4.wait
  ;
  // setup aconnect
  cfg.ac = Aconnect();
  cfg.fluid = cfg.ac.outByName("fluid synth");
  cfg.midithru = cfg.ac.inByName("midi through");
  cfg.ac.connect(cfg.fluid.port, cfg.midithru.port)
  ;
  5.wait;
  cfg.jc = JackConnect.new
  ;
  // disconnect 'wrong' connections first.
  (1..4).collect {
    |i|
    cfg.jc.disconnectClients("SuperCollider:out_%".format(i), "system:playback_%".format(i));
    if (i <= 2) {
      ["l", "r"].collect{ |letter| cfg.jc.disconnectClients("fluidsynth:%_00".format(letter), "system:playback_%".format(i)); }
    } {
      ["l", "r"].collect{ |letter| cfg.jc.disconnectClients("fluidsynth:%_01".format(letter), "system:playback_%".format(i)); }
    };
  }
  ;
  // Connect fluidsynth:{l,r} to SC:in
  (0..15).collect {
    |i|
    var idx = i.asString.padLeft(2,"0");
    cfg.jc.connectClients("fluidsynth:l_%".format(idx), "SuperCollider:in_%".format(i+1));
    cfg.jc.connectClients("fluidsynth:r_%".format(idx), "SuperCollider:in_%".format(i+1));
  }
  ;
  // Connect SC:out to System:playback
  (1..16).collect { |i| cfg.jc.connectClients("SuperCollider:out_%".format(i), "system:playback_%".format(((i-1)%2)+1)); }
  ;
  "-> BALC MIDI Loaded".postln;
}).start;
)

(

var lsys = Prewrite(0.25,
	(
		0.25: #[0.25,0.25,0.25,0.5],
		0.5: #[0.25,0.5,0.125,0.125,0.125,0.125],
		0.125: #[0.375,0.125],
		0.375: #[0.375,0.375,1],
		1: #[0.75,0.25],
		0.75: #[16]
),60)
;
var linda = Prewrite(
  0.25,
  (
    0.125: #[0.25, 0.5, 12],
    0.25: #[1, 0.5, 0.75, 0],
    0.5: #[0.25, 0.75, 1, 3, 1],
    0.75: #[0.25, 3, 0.5, 0, 1],
    1: #[0.75, 0.5, 1, 0.25],
    3: #[12, 0.25, 5],
    5: #[3, 1, 0.25, 7],
    7: #[5, 3, 0.125, 1],
    12: #[5, 7, 0.25, 3],
  ),
  4
);
var minilinda = Prewrite(
  0.5,
  (
    0.25: #[0.5, 0.25, 0.25, 0.25],
    0.5:  #[0.25, 0.25, 0.5, 0.75],
    0.75: #[0.25, 0.25, 0.5, 0.75],
  ),
  23
);
var microlinda = Prewrite(
  0.25,
  (
    0.125: #[0.125, 0.25, 0.125, 0.25],
    0.25: #[0.5, 0.25, 0.25, 0.25, 0.125],
    0.5:  #[0.25, 0.125, 0.5, 1, 0.75],
    0.75: #[0.25, 0.25, 0.5, 0.75, 0.125],
    1: #[0.25, 0.25, 0.5, 0.75, 1],
  ),
  5
);
var stut = Prewrite(
  1,
  (
    1: #[1, 1, 2, 1, 1, 1, 1,],
    2: #[2, 1, 16, 4, 1, 1, 1],
    4: #[1, 2, 1, 4, 2, 8, 1],
    8: #[2, 1, 8, 4, 16, 32,1,1],
    16: #[2, 32, 1, 4, 1, 1, 1],
    32: #[2, 1, 16, 4, 1, 1, 32],
  ),
  16
);
)