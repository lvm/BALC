(
/**
 * Pure Supercollider
 */

// simple patch cord
SynthDef.new(\patch,{
  |in, out, amp=0.9|
  OffsetOut.ar(out, In.ar(in, 2) * (amp*0.9));
}, metadata: (credit: "http://github.com/lvm/balc")).add;

// in
SynthDef(\in, {
  |out, in = 0, amp=0.9|
  var sound;
  sound = SoundIn.ar([in, in+1]); // stereo in
  OffsetOut.ar(out,sound*(amp*0.9));
}).add;


// filters
SynthDef.new(\lpf,{
  |in, out=0, amp=0.9, freq=19000|
  var sig;
  sig = In.ar(in, 2);
  sig = LPF.ar(sig, freq:freq, mul:amp);
  OffsetOut.ar(out, sig);
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef.new(\hpf,{
  |in, out=0, amp=0.9, freq=10|
  var sig;
  sig = In.ar(in, 2);
  sig = HPF.ar(sig, freq:freq, mul:amp);
  OffsetOut.ar(out, sig);
}, metadata: (credit: "http://github.com/lvm/balc")).add;

// ??????
SynthDef.new(\bpf,{
  |in, out=0, amp=0.9, rq=1, freq=1000|
  var sig;
  sig = In.ar(in, 2);
  sig = BPF.ar(sig, freq:freq, rq:rq, mul:amp);
  OffsetOut.ar(out, sig);
}, metadata: (credit: "http://github.com/lvm/balc")).add;

// fx

SynthDef.new(\reverb,{
  |in, out=0, amp=0.9, mix=0.33, room=0.5, damp=0.5|
  var sig;
  sig = In.ar(in, 2);
  sig = FreeVerb.ar(sig, mix, room, damp, amp);
  OffsetOut.ar(out, sig);
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\delay, {
  |in, out=0, delay=0.0625, decay=0.25, wet=0.5|
  var sig;
	sig = In.ar(in,2);
  sig = AllpassL.ar(sig, delay, delay, decay, add:sig);
	OffsetOut.ar(out, sig);
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef.new(\distort,{
  |in, out=0, amp=0.125, smooth=0.75|
  var sig;
  sig = In.ar(in, 2);
  sig = CrossoverDistortion.ar(sig, amp, smooth);
  OffsetOut.ar(out, sig);
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\tremolo, {
  |in, out=0, freq=1|
  var sig;
  sig = In.ar(in, 2) * SinOsc.ar(freq:freq, phase:0, mul:0.9, add:0);
  OffsetOut.ar(out, sig);
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\wah, {
  |in, out, amp=0.9, low=100, hi=12500, freq=5|
  var sig, env;
  sig = In.ar(in, 2) * (amp*0.9);
  sig = LPF.ar(sig, LinExp.ar(SinOsc.ar(freq), -1, 1, low, hi));
  OffsetOut.ar(out, sig);
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\echo, { |out = 0, in = 0, max = 1.0, delay = 0.5, decay = 3, amp = 0.5, bypass = 0|
	var sig, insig;
	insig = In.ar(in, 2);
	sig = CombL.ar(insig, max, delay, decay, amp, add: insig) * EnvGate();
	Out.ar(out, bypass * insig + ((1 - bypass) * sig));
}, metadata: (credit: "tedthetrumpet: http://sccode.org/1-56x")).add;
)