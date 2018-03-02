// init
(
"-> Loading SuperDirt".postln;
s.options.numBuffers = 1024 * 64;
s.options.memSize = 8192 * 16;
s.options.maxNodes = 1024 * 32;
s.options.sampleRate = 44100;
s.options.numOutputBusChannels = 18;
s.options.numInputBusChannels = 4;
s.waitForBoot {
  StageLimiter.activate;
  ~dirt = SuperDirt(2, s);
  s.sync;
  ~dirt.start(57120, [0, 2, 4, 6, 8, 10, 12, 14, 16]);
  // 3.wait;
  ~dirt.loadSoundFiles;
  1.wait;
  SuperDirt.default = ~dirt;
  TempoClock.default.tempo = 120/60;
  1.wait;
  //("fix.scd").loadRelative;
  ("synths.scd").loadRelative;
  ("fx.scd").loadRelative;
  ("../braks.scd").loadRelative;
  ("../theory.scd").loadRelative;
  ("../snippets.scd").loadRelative;
  0.25.wait;
  TinySnippets.enable("y", ~snippets);
  "-> SuperDirt Loaded".postln;
  //s.plotTree;
};
)

(
// m.clear;
~mand = MandelHub.start(\balc);
~mand.gui();
~mand.changeTempo(120/60);
)


(
~linda = Prewrite(
  [0.25],
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
~minilinda = Prewrite(
  [0.5],
  (
    0.25: #[0.5, 0.25, 0.25, 0.25],
    0.5:  #[0.25, 0.25, 0.5, 0.75],
    0.75: #[0.25, 0.25, 0.5, 0.75],
  ),
  23
);
~microlind = Prewrite(
  [0.25],
  (
    0.125: #[0.125, 0.25, 0.125, 0.0625],
    0.25: #[0.5, 0.25, 0.25, 0.25, 0.125],
    0.5:  #[0.25, 0.125, 0.5, 1, 0.75],
    0.75: #[0.25, 0.25, 0.5, 0.75, 0.125],
    1: #[0.25, 0.25, 0.5, 0.75, 1],
  ),
  5
);
~stut = Prewrite(
  [1],
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

(
~dirt.orbits.do { |x| x.outBus = 0 };
~busses.do { |x| x.free };
~busses = ~dirt.orbits.collect { |each|
	var bus = Bus.audio(~dirt.server, ~dirt.numChannels);
	each.outBus = bus;
	bus
}
);
// just route all to [0,1]
(
Ndef(\mix, {
  var gain = 0.9;
	var all = ~busses.collect { |each| InBus.ar(each, each.numChannels) };
  Mix.ar(all)*gain;
}).play;
);

// algorave mastering
// https://mccormick.cx/news/entries/heuristic-for-algorave-mastering
(
Ndef(\algomix, {
	var level = 0.9;
	var distortion = 0.125;
	var reverbFeedback = 0.125;
	var all = ~busses.collect { |each| InBus.ar(each, each.numChannels) };
	var mix = all.sum { |x|
		var d = { 0.01.rand } ! x.size;
		DelayN.ar(x, d, d)
	};
	var loop = LocalIn.ar(~dirt.numChannels);
	5.do { loop = AllpassL.ar(loop, 0.15, { ExpRand(0.03, 0.15) } ! 2, 3) };
	mix = loop * reverbFeedback + mix;
	mix = LeakDC.ar(mix);
	LocalOut.ar(mix);
	mix = Compander.ar(mix, mix, 0.3, slopeBelow:1, slopeAbove:0.5, clampTime:0.01, relaxTime:0.01);
	mix = (mix * distortion).tanh * (level / distortion.max(1));
	mix
}).play;
);
/*
cleaning up when you're done:
*/
(
~dirt.orbits.do { |x| x.outBus = 0 };
Ndef(\mix).clear;
Ndef(\algomix).clear;
~busses.do { |x| x.free };
);