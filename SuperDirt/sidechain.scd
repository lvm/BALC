

(
~inBus.free;
~cleanBus.free;
~wahBus.free;
~ecInBus.free;
~ecOutBus.free;
~inBus = Bus.audio(s, ~dirt.numChannels);
~cleanBus = Bus.audio(s, ~dirt.numChannels);
~wahBus = Bus.audio(s, ~dirt.numChannels);
~ecInBus = Bus.audio(s, ~dirt.numChannels);
~ecOutBus = Bus.audio(s, ~dirt.numChannels);
~dirt.orbits[1].outBus = ~inBus;
~dirt.orbits[2].outBus = ~inBus;
~dirt.orbits[3].outBus = ~cleanBus;
~dirt.orbits[4].outBus = ~cleanBus;
)

t = Synth(\echo, [\in, ~ecInBus, \out, ~ecOutBus], addAction:\addToTail);
t.set(\delay, 0.25);
t.set(\decay, 5);

(
Ndef(\mix, {
  var in, out, eco, control, clean, mix;
  var numChan = ~dirt.numChannels;
  eco = InBus.ar(~ecOutBus, numChan);
  in = InBus.ar(~inBus, numChan);
  clean = InBus.ar(~cleanBus, numChan);
  control = InBus.ar(~dirt.orbits[0].dryBus, numChan).tanh.sin*2;
  out = Compander.ar(in, control, thresh:0.01, slopeBelow:1, slopeAbove: 0.1, clampTime:0.02, relaxTime:0.1);
  Splay.ar([out, eco, clean])*0.125;
}).play;
)


///

(
~bus.free
~bus = Bus.audio(s, numChannels:2); // assuming stereo, expand if needed
~dirt.orbits[0].outBus = ~bus; // play into that bus.
Ndef(\x, {
  var control = InBus.ar(~dirt.orbits[1].dryBus, 2).sum;
  var dirt = InBus.ar(~bus, 2);
  Compander.ar(dirt, control, thresh:0.01, slopeBelow:1, slopeAbove: 0.1, clampTime:0.02, relaxTime:0.1)
}).play;
)