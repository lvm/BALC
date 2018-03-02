(
// drum
SynthDef(\kick, {
  |out=0, amp=0.9, atk=0.01, sus=1, rel=0.5, accel=0.01, pan=0, freq=80|
  var sig, env, xl;
  amp = amp*0.9;
  xl = XLine.kr(start:freq, end:freq*accel, dur:atk+rel+0.1, mul: amp, doneAction:2);
	env = EnvGen.ar(Env.perc(attackTime: atk, releaseTime: rel, level: amp, curve: -4), timeScale: sus, doneAction: 2);
  sig = HPF.ar(SinOsc.ar(xl), 60);
  sig = sig * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\snare, {
  |out=0, amp=0.9, atk=0.01, sus=1, rel=0.5, pan=0, freq=1250|
  var sig, env;
  amp = amp*0.9;
  env = EnvGen.ar(Env.perc(attackTime:atk, releaseTime:rel, level: amp), timeScale: sus, doneAction:2);
  sig = HPF.ar(WhiteNoise.ar(1) * env, freq);
  sig = sig * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\clap, {
  |out=0, amp=0.9, atk=0.01, sus=1, rel=0.5, rq=1, pan=0, freq|
  var sig, env, sigs, envs, sigl, envl;
  amp = amp*0.9;
  env = EnvGen.ar(Env.perc(atk, rel), timeScale: sus, doneAction:2);
  envs = EnvGen.ar(Env.new(
    [0,         1, 0,   0.9, 0,  0.7, 0,  0.5, 0.1],
    [0.001, 0.009, 0, 0.008, 0, 0.01, 0, 0.03, 0.1],
    [0,        -3, 0,    -3, 0,   -3, 0,   -4,  -4]
  ),  doneAction:2);
  sigs = BPF.ar(LPF.ar(HPF.ar(WhiteNoise.ar(envs), 600), XLine.kr(8000,4000,0.5)), 1500, rq, 3);
  envl = EnvGen.ar(Env.new(
    [0,   1, 0],
    [0, 0.5, 0],
    [0,  -4, 0]
  ), doneAction:2);
  sigl = BPF.ar(LPF.ar(HPF.ar(WhiteNoise.ar(envl), 1250), 8000), 1250, 0.125, amp*2);

  sig = (sigl + sigs) * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\hat, {
  |out=0, amp=0.9, atk=0.01, sus=1, rel=0.05, rq=0.25, pan=0, freq=0|
  var sig, env;
	amp = amp*0.9;
  env = EnvGen.ar(Env.perc(attackTime: atk, releaseTime: rel, level: amp), timeScale: sus, doneAction: 2);
  sig = RHPF.ar(WhiteNoise.ar(1) * env, (freq+10000), rq);
  sig = sig * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;

// strings

SynthDef(\bassy, {
  |out=0, amp=0.9, atk=0.01, sus=0.5, rel=2, lctf=1200, hctf=200, rq = 0.5, detune=0.01, accel=0.01, pan=0, freq|
  var sig, env;
	amp = amp*0.9;
  env = EnvGen.ar(Env.perc(attackTime: atk, releaseTime: rel, level: amp), timeScale: sus, doneAction: 2);
  sig = BHPF.ar(RLPF.ar(SawDPW.ar(freq * Line.kr(1,1+accel, sus+rel),1), lctf*env, rq), freq:hctf);
  sig = sig * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\bassy3, {
  |out=0, amp=0.9, atk=0.01, sus=0.5, rel=2, ffreq=1200, rq = 0.5, dist=0, detune=0.01, accel=0.01, pan=0, freq|
  var sig, env;
	amp = amp*0.9;
  env = EnvGen.ar(Env.perc(attackTime: atk, releaseTime: rel, level: amp), timeScale: sus, doneAction: 2);
  sig = RLPFD.ar(SawDPW.ar(freq * Line.kr(1,1+accel, sus+rel),1), ffreq:ffreq, res:rq, dist:dist, mul:amp*2);
  sig = sig * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\piano, {
  |out=0, amp=0.9, atk=0.01, dec=0.5, sus=1, rel=0.25, gate=0.5, str=0.1, tune=0.5, feed=0.5, pan=0, freq|
  var sig, env;
  amp = amp * 0.9;
  env = EnvGen.ar(Env.perc(atk, rel), timeScale: sus, doneAction:2);
  sig = MdaPiano.ar(freq, gate:gate, stretch:str, tune:tune, decay:dec, sustain: sus, release:rel, stereo:pan, mul:amp);
  sig = sig * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;


SynthDef(\sc303, {
  |out=0, gate=1, wave=0, lctf=100, hctf=1000, rq=0.5, sustain=0.09, decay=1.0, amp=0.75, pan=0.5, freq|
  var  sig, env, filEnv, volEnv, waves;
  env = EnvGen.kr(Env.asr, gate, doneAction: 2);
  volEnv =  EnvGen .ar( Env .new([10e-10, 1, 1, 10e-10], [0.01, sustain, decay],  \exp ), gate);
  filEnv =  EnvGen .ar( Env .new([10e-10, 1, 10e-10], [0.01, decay],  \exp ), gate);
  waves = [ Saw .ar(freq, volEnv),  Pulse .ar(freq, 0.5, volEnv)] * env;
  sig = RLPF .ar(  Select .ar(wave, waves), lctf + (filEnv * hctf), rq).dup * amp;
  OffsetOut.ar(0, Pan2.ar(sig, pan, amp));
}, metadata:(credit: "based on http://sccode.org/1-4Wy")).add;


// other

SynthDef(\23, {
  |out, amp=0.9, atk=0.01, sus=0.5, rel=0.25, fb=0, detune=1.01, pan=0, freq|
  var par, tri, sig, env;
	env = EnvGen.ar(Env.linen(attackTime:atk, sustainTime:sus, releaseTime:rel), timeScale:sus/2, doneAction:2);
  par = LFPar.ar(XLine.kr(freq/2,freq, sus*10, doneAction:2), mul:amp); // 2
  tri = LFTri.ar(freq:freq*((detune/100)+1), mul:amp); // 3
  sig = SinOscFB.ar(freq+tri, feedback:par, mul: amp);
	sig = sig * env;
  Out.ar(out, Pan2.ar(LeakDC.ar(sig), pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\c23, {
  |out, amp, atk=0.01, rel=1, fb=0, lctf=400, rq=0.5, detune=1.01, pan=0, freq|
  var par, tri, sig, env;
	env = EnvGen.ar(Env.perc(attackTime:atk+0.1, releaseTime:rel), doneAction:2);
  par = LFPar.ar(XLine.kr(freq/2,freq, rel*10, doneAction:2)); // 2
  tri = LFTri.ar(freq:freq*((detune/100)+1)); // 3
  sig = SinOscFB.ar(freq+tri, feedback:par);
  sig = FreeVerb.ar(sig, 0.9) * env;
  sig = RLPF.ar(sig, lctf, rq);
  OffsetOut.ar(out, Pan2.ar(LeakDC.ar(sig), pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\pium, {
  |out=0, amp=0.9, atk=0.01, dec=0.5, sus=1, rel=0.5, accel=0.01, pan=0, freq=80|
  var sig, env, xl;
  amp = amp*0.9;
  xl = XLine.kr(start:freq, end:freq*accel, dur:rel, mul: amp, doneAction:2);
  env = EnvGen.ar(Env.perc(attackTime: atk, releaseTime: rel, level: amp, curve: -8), timeScale: sus, doneAction: 2);
  sig = LPF.ar(Ringz.ar(Impulse.ar(1), freq, dec, amp), 800) * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;


SynthDef.new(\kell,{
  |out, amp=0.9, atk=0.01, dec=0.05, sus=1, rel=0.25, gate=1, vib=0.1, mix=0.33, room=0.5, damp=0.5, pan=0, wave=0, freq|
  var sig, env;
  amp = amp * 0.9;
  // env = EnvGen.ar(Env.perc, doneAction:2);
  env = Select.ar(wave, [
    EnvGen.ar(Env.adsr(atk, dec, sus, rel), gate:gate, doneAction: 2),
    EnvGen.ar(Env.perc, doneAction:2)
  ]);
  freq = Vibrato.kr(freq, rate: vib);
  sig = Klang.ar(`[
    freq*[0.5,2,1.5],
    0.25!3,
    pi.rand!3], 1, 0)*amp;
  sig = FreeVerb.ar(sig, mix, room, damp) * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\kfm, {
  |out, amp=0.9, atk=0.01, sus=1, accel=0, carPartial=1, modPartial=1, index=3, mix=0.33, room=0.5, damp=0.5, mul=0.25, detune=0.1, pan=0.5, freq|
  var env, mod, car, sig;
  env = EnvGen.ar(Env.perc(atk, 0.999, 1, -3), timeScale: sus*0.5, doneAction:2);
  mod = SinOsc.ar(freq * modPartial * Line.kr(1,1+accel, sus), 0, freq * index * LFNoise1.kr(5.reciprocal).abs);
  car = SinOsc.ar(([freq, freq+detune] * carPartial) + mod,	0, mul) + Klang.ar(`[
    ([freq, freq+detune] * carPartial) + mod,
    1!2,
    pi.rand!2], 1, 0)*0.25;
  sig = FreeVerb.ar(car, mix, room, damp) * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "based on \fm by @munshkr")).add;

SynthDef(\bkfm, {
  |out, amp=0.9, atk=0.01, sus=1, accel=0, carPartial=1, modPartial=1, index=3, nharm=2, mul=0.25, detune=0.1, pan=0.5, freq|
  var ffreq, env, snd, mod, car, sig;
  env = EnvGen.ar(Env.perc, doneAction:2);
  mod = SinOsc.ar(freq * modPartial * Line.kr(1,1+accel, sus), 0, freq * index * LFNoise1.kr(5.reciprocal).abs);
  car = SinOsc.ar(([freq, freq+detune] * carPartial) + mod,	0, mul) + Klang.ar(`[
    ([freq, freq+detune] * carPartial) + mod,
    1!2,
    pi.rand!2], 1, 0)*0.25;
  ffreq = freq * [1.9953843530485*0.5, 1.9953843530485];
  // ffreq = freq * [1, 1.9953843530485];
	snd = LeakDC.ar(Mix(car,Blip.ar(freq, nharm, env)));
  OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
}, metadata: (credit: "based on \fm by @munshkr")).add;


SynthDef(\dust, {
  |out=0, amp=0.9, atk=0.01, sus=1, rel=0.25, rq=0.25, detune=1, pan=0, freq|
  var sig, env;
  amp = amp*0.9;
  env = EnvGen.ar(Env.perc(atk, rel), timeScale: sus, doneAction:2);
  sig = LPF.ar(Ringz.ar(Dust.ar(freq), freq*2.rand.max(9000)), 8000)*0.5;
  sig = sig * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\pulse, {
  |out, amp=0.9, atk=0.001, sus=1, rel=0.5, accel=0.01, detune=0.1, ffreq=1250, pan=0, freq|
  var sig, env;
  amp = amp*0.9;
	env = EnvGen.ar(Env.perc(atk, rel), timeScale: sus/ 2, doneAction:2);
	sig = RLPF.ar(LFPulse.ar([freq, freq],0.5), freq:ffreq, rq:1, mul:amp);
  sig = sig * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;


SynthDef(\can, {
  |out=0, amp=0.9, atk=0.01, sus=1, rel=0.25, bits=24, crush=1, phase=0.5, shift=0, pan=0, wave=0, freq|
  var sig, env;
	amp = amp*0.9;
  env = EnvGen.ar(Env.perc(attackTime: atk, releaseTime: rel, level: amp), timeScale: sus, doneAction: 2);
  sig = Select.ar(wave, [LFTri.ar(freq, phase), LFCub.ar(freq, phase)]);
  sig = Decimator.ar(FreqShift.ar(sig, shift), 44100/crush, bits);
  sig = sig * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;

// SynthDef(\fm, { |out, amp=1, attack=0.001, sustain=1, pan=0, accelerate=0, freq=440, carPartial=1, modPartial=1, index=3, mul=0.1, detune=0.1|
//   var env = EnvGen.ar(Env.perc(attack, 0.999, 1, -3), timeScale: sustain / 2, doneAction: 2);
//   var mod = SinOsc.ar(freq * modPartial * Line.kr(1,1+accelerate, sustain), 0, freq * index * LFNoise1.kr(5.reciprocal).abs);
//   var car = SinOsc.ar(([freq, freq+detune] * carPartial) + mod, 0, mul);
//   OffsetOut.ar(out, Pan2.ar(car * env, pan, amp));
// }, metadata: (credit: "@munshkr")).add;
//
// SynthDef(\fmg, { |out, amp=1, attack=0.001, sustain=1, pan=0, accelerate=0, freq=440, trig=1, fdur=0.1, carPartial=1, modPartial=1, index=3, mul=0.1, detune=0.1|
//   var env = EnvGen.ar(Env.perc(attack, 0.999, 1, -3), timeScale: sustain / 2, doneAction: 2);
//   var mod = freq * modPartial * Line.kr(1,1+accelerate, sustain);
//   var car = ([freq, freq+detune] * carPartial) + mod;
//   var sig = FMGrain.ar(trigger: Impulse.kr(trig), dur: sustain, carfreq: car, modfreq: mod, index: index, mul: 1, add: 0);
//   OffsetOut.ar(out, Pan2.ar(sig * env, pan, amp));
// }).add;

SynthDef(\fm, {
  |out, amp=0.9, attack=0.001, sustain=1, accel, carPartial=1, modPartial=1, index=3, mul=0.25, detune=0.1, pan=0, freq|
  var env, mod, car;
  amp = amp * 0.9;
  env = EnvGen.ar(Env.perc(attack, 0.999, 1, -3), timeScale: sustain / 2, doneAction:2);
  mod = SinOsc.ar(freq * modPartial * Line.kr(1,1+accel, sustain), 0, freq * index * LFNoise1.kr(5.reciprocal).abs);
  car = SinOsc.ar(([freq, freq+detune] * carPartial) + mod,	0, mul);
  OffsetOut.ar(out, Limiter.ar(Pan2.ar(car * env, pan, amp), 0.9));
}, metadata: (credit: "@munshkr")).add;

SynthDef(\fmr, {
  |out, amp=0.9, attack=0.001, sustain=1, accel, carPartial=1, modPartial=1, index=3, mul=0.25, detune=0.1, pan=0, freq, mix=0.33, room=0.5, crush=1, bits=24, wave=0|
  var env, mod, car;
  amp = amp * 0.9;
  env = EnvGen.ar(Env.perc(attack, 0.999, 1, -3), timeScale: sustain / 2, doneAction:2);
  mod = SinOsc.ar(freq * modPartial * Line.kr(1,1+accel, sustain), 0, freq * index * LFNoise1.kr(5.reciprocal).abs);
  car = SinOsc.ar(([freq, freq+detune] * carPartial) + mod,	0, mul);
  car = FreeVerb.ar(car, mix, room);
  car = Select.ar(wave, [car, Decimator.ar(car, 44100/crush, bits)]);
  OffsetOut.ar(out, Pan2.ar(car * env, pan, amp));
}, metadata: (credit: "based on @munshkr's fm")).add;

SynthDef(\sin, {
  |out, amp=0.9, atk=0.001, sus=1, rel=1, accel=0, detune=0.1, pan=0, freq|
  var sig, env;
  amp = amp*0.9;
	env = EnvGen.ar(Env.perc(atk, rel), timeScale: sus / 2, doneAction: 2);
	sig = SinOsc.ar([freq, freq+detune] * Line.kr(1,1+accel, sus));
  sig = sig * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "@munshkr")).add;

SynthDef(\saw, {
  |out, amp=0.9, atk=0.001, sus=1, rel=0.5, accel=0.01, detune=0.1, pan=0, freq|
  var sig, env;
  amp = amp*0.9;
	env = EnvGen.ar(Env.perc(atk, rel), timeScale: sus/ 2, doneAction:2);
	sig = SawDPW.ar([freq, freq+detune] * Line.kr(1,1+accel, sus)) * env;
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "@munshkr")).add;

// foxdot

SynthDef.new(\soprano,
  {|out=0, amp=0.9, atk=0.01, sus=1, rel=0.5, vib=5, slide=0, rate=1, verb=0.5, slidefrom=1, fmod=0, pan=0, freq|
  var osc, env;
  amp = amp * 0.9;
  freq = freq + fmod;
  freq = Line.ar(freq * slidefrom, freq * (1 + slide), sus);
  freq = Vibrato.kr(freq, rate: vib);
  env = EnvGen.ar(Env.perc(attackTime: atk, releaseTime: rel, level: amp), timeScale: sus, doneAction: 2);
  osc = (SinOsc.ar((freq * 3), mul: amp) + SinOscFB.ar((freq * 3), mul: (amp / 2)));
  osc = osc * env;
  OffsetOut.ar(out, Pan2.ar(osc, pan, amp));
}, metadata: (credit: "https://github.com/Qirky/FoxDot")).add;


SynthDef.new(\varsaw,
  {|out=0, amp=0.9, vib=0, slide=0, rate=1, atk=0.01, sus=1, slidefrom=1, fmod=0, pan=0, freq|
    var osc, env;
    amp = amp * 0.9;
    freq = freq + fmod;
    freq = Line.ar(freq * slidefrom, freq * (1 + slide), sus);
    freq = Vibrato.kr(freq, rate: vib);
    osc=VarSaw.ar([freq, (freq * 1.005)], mul: (amp), width: rate);
    env=EnvGen.ar(Env(levels: [amp, amp, amp], curve: 'lin', times: (sus / 2)), doneAction: 2);
    osc = (osc * env * EnvGen.ar(Env.perc(atk,sus), doneAction:2)) * 0.125;
    OffsetOut.ar(out, Pan2.ar(osc, pan, amp));
}, metadata: (credit: "https://github.com/Qirky/FoxDot")).add;

SynthDef.new(\pluck, {
  |out=0, amp=0.9, vib=0, slide=0, attack=0.01, sustain=1, slidefrom=1, fmod=0, rate=1, bits=0, pan=0, freq|
  var osc, env;
  amp = amp * 0.9;
  freq = freq + fmod;
  freq = Line.ar(freq * slidefrom, freq * (1 + slide), sustain);
  freq = Vibrato.kr(freq, rate: vib);
  freq=[freq, (freq + LFNoise2.ar(50).range(-2, 2))];
  osc=(SinOsc.ar((freq * 1.002), phase: VarSaw.ar(freq, width: Line.ar(1, 0.2, 2))) + (SinOsc.ar(freq*rate, phase: VarSaw.ar(freq, width: Line.ar(1, 0.2, 2))) ));
  osc=osc * XLine.ar(amp, (amp / 10000), (sustain * 4), doneAction: 2)*0.25;
  osc = osc * EnvGen.ar(Env.perc(attack,sustain), doneAction:2) * 0.35;
  OffsetOut.ar(out, Pan2.ar(osc, pan, amp));
}, metadata: (credit: "https://github.com/Qirky/FoxDot")).add;

// noise

SynthDef.new(\crunch,
  {|out=0, amp=0.9, vib=0, slide=0, rate=1, sus=1, slidefrom=1, fmod=0, pan=0, freq|
  var osc, env;
  freq = freq + fmod;
  freq = Line.ar(freq * slidefrom, freq * (1 + slide), sus);
  freq = Vibrato.kr(freq, rate: vib);
  env = EnvGen.ar(Env.perc(level: (amp),curve: 0,attackTime: 0.01,releaseTime: 0.1+sus), doneAction: 2);
  osc = LFNoise0.ar(((Crackle.kr(1.75) * freq) * 30), mul: amp);
  osc = osc * env;
  OffsetOut.ar(out, Pan2.ar(osc, pan, amp));
}, metadata: (credit: "https://github.com/Qirky/FoxDot")).add;

SynthDef.new(\noise,
  {|out=0, amp=0.9, atk=0.01, dec=0.5, sus=1, rel=0.5, vib=0, slide=0, rate=1,  slidefrom=1, fmod=0, rq=1, lctf=800, pan=0, freq|
    var osc, env;
    freq = freq + fmod;
    freq = Line.ar(freq * slidefrom, freq * (1 + slide), sus);
    freq = Vibrato.kr(freq, rate: vib);
    osc = RLPF.ar(LFNoise0.ar(freq, amp), lctf, rq, amp);
    env=EnvGen.ar(Env.adsr(attackTime: atk, decayTime:dec, sustainLevel:sus, releaseTime:rel), doneAction:2);
  osc = osc * env;
  OffsetOut.ar(out, Pan2.ar(osc, pan, amp));
}, metadata: (credit: "https://github.com/Qirky/FoxDot")).add;

// samples
SynthDef(\break,
  {|out, amp=0.9, bufnum=0, sample=0, pan=0|
    var pb, brk, env, sr;
    amp = amp * 0.9;
    sr = 44100;
    env = EnvGen.ar(Env.perc, doneAction:2);
    pb = PlayBuf.ar(2, sample, loop:0);
    brk = Breakcore.ar(bufnum, pb, Impulse.kr(LFNoise0.kr(4,10,12)), Rand(sr/4, sr), 0) * env;
  OffsetOut.ar(out, Pan2.ar(brk, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\sampler,
  {|out, amp=0.9, atk=0.01, rel=1, pos=0, sample=0, rate=1, pan=0|
    var sig, env, begin, sr;
    sr = 44100;
    begin = BufDur.kr(sample)*sr * pos;
//    env = EnvGen.ar(Env.linen(0.0,rel,0.0,1));
    sig = PlayBuf.ar(2, sample, rate:BufRateScale.ir(sample) * rate, trigger:1, startPos:begin, loop:0, doneAction:2);
  OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc")).add;

SynthDef(\wavet, {
  |out, amp = 0.9, atk=0.01, rel=1, buf, pan=0, freq=1|
  var sig, env;
  env = EnvGen.ar(Env.perc(atk,rel),doneAction:2);
  sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * freq, 1, 0, 1, doneAction:2) * env;
  Out.ar(out, Pan2.ar(sig, pan, amp));
}, metadata: (credit: "http://github.com/lvm/balc based on @theseanco Synthdef")).add;

SynthDef(\blips2, {
  |out=0, amp=0.9, atk=0.01, rel=1, nharm = 10, pan = 0.5, freq|
	var snd, env;
	env = Env.perc(atk, rel).kr(doneAction: 2);
  freq = freq * [1, 1.9953843530485];
	snd = LeakDC.ar(Mix(Blip.ar(freq, nharm, env))) * env;
  Out.ar(out, Pan2.ar(snd, pan, amp));

}, metadata: (credit: "based on \blips1 by someone [need to find this person]")).add;

SynthDef( \juno, { | out = 0, sus = 2, amp = 0.35, slide = 2, jshape = 0.75, freq = 220, fsust = 0.5, fmod = 10, speed = 2, end=1, pan = 0, gate = 1 |
  var     pwm, saw, mix, env, sound;
  env = EnvGen.ar(Env.asr(jshape, 1, 1 - jshape), gate, timeScale: sus, doneAction:2 );
  freq = SinOsc.ar(
    { 2.9 rrand: 3.1 }!3,
    { 2pi.rand }!3
  ).exprange( 0.995, 1.005 ) * (
    ( fmod * freq ) * env * fsust.clip(1, 2) ).clip( 0.1, end * (freq * fmod).lag(slide) );
  pwm = SinOsc.kr( {2.0 rrand: 4.0}!3 ).range(0.125, 0.875);
  saw = (
    LFSaw.ar( freq * [
      LFDNoise3.ar( 1, freq.reciprocal, 0.25),
      LFDNoise3.ar( 1, freq.reciprocal, 0.5),
      1
    ],
    LFDNoise3.ar( 1, freq.reciprocal, 1)
    ).clip2(0.8) * ( 1 - LFPulse.ar( freq * [
      LFDNoise3.ar( 1, 0.125, 0.5 ),
      LFDNoise3.ar( 1, 0.125, 1 ),
      LFDNoise3.ar( 1, 0.125, 2 )
    ],
    0, pwm ).clip2(0.2) )
  );

  mix = saw + LFPar.ar( freq * 0.25, LFDNoise1.ar(0.25, 0.125), 0.1 );
  mix = BPeakEQ.ar( mix, 6000, 0.5, 3 );
  mix = BPeakEQ.ar( mix, 3500, 0.5, 6 );
  mix = Balance2.ar( Mix(mix[1]) + Mix(mix[0]) + (Mix(mix[2]) * 0.33), Mix(mix[2]) + Mix(mix[0]) + (Mix(mix[1]) * 0.33));
  sound = mix + CombL.ar( mix, 1/200, SinOsc.kr( 3, [0.5pi, 1.5pi] ).range(1/300,1/200), 0.0 ) * amp * env;
  OffsetOut.ar( out, Pan2.ar(sound * -35.dbamp, pan, env) );
}, metadata: (credit: "by @skmecs")).add;


SynthDef(\eric, {
  |out=0, pan, amp=0.9, sustain = 1, freq = 440, speed = 1, begin=0, end=1, wave=0, vib=0.1|
  var line = Line.ar(begin, end, sustain, doneAction:2);
  var env = Env([0, 1, 0], [0.05, 0.5], curve:-3);
  var envGen = IEnvGen.ar(env, line*env.times.sum);
  var sound = Mix.ar(Array.fill(20,{|i|Pulse.ar(ExpRand.new(100.0,1000.0),0.05)}));
  sound = Mix.ar(BPF.ar(sound,DC.ar(Array.fill(10,{|i| i+{Rand(1,23)}}))*freq, (4/1000))*DC.ar(Array.fill(10,{|i| 1.0/(i+1)})));
  OffsetOut.ar(out, Pan2.ar(sound, pan, amp) * envGen);
}, metadata: (credit: "by @efairbanks")).add;


SynthDef(\eric2, {
  |out=0, pan, amp=0.9, sustain = 1, freq = 440, speed = 1, begin=0, end=1, wave=0, vib=0.1|
  var line = Line.ar(begin, end, sustain, doneAction:2);
  var env = Env([0, 1, 0], [0.05, 0.5], curve:-3);
  var envGen = IEnvGen.ar(env, line*env.times.sum);
  var sound = Mix.ar(Array.fill(10,{|i|Pulse.ar(ExpRand.new(100.0,1000.0),0.05)}));
  sound = Mix.ar(BPF.ar(sound,DC.ar(Array.fill(5,{|i| i+1}))*freq, (4/1000))*DC.ar(Array.fill(5,{|i| 1.0/(i+1)})));
  OffsetOut.ar(out, Pan2.ar(sound, pan, amp) * envGen);
}, metadata: (credit: "by @efairbanks")).add;


SynthDef(\wip, {
|out, sustain = 1, freq = 440, begin=0, end=1, vib=0.1, pan, accelerate|
var line = Line.ar(begin, end, sustain, doneAction:2);
var env = Env([0, 1, 0], [0.05, 0.5], curve:[1,-1]);
var envGen = IEnvGen.ar(env, line*env.times.sum);
var sound = Mix.ar(Array.fill(20,{|i|Pulse.ar(ExpRand.new(20.0,12000.0),0.1)}));
var fs = Array.fill(10, {|i| i+{Rand(1,5)}});
sound = Mix.ar(BPF.ar(sound,DC.ar(fs**1.585)*freq, (4/2000))*DC.ar(1.0/(fs**1.5)));
sound = FreeVerb.ar(sound, 0.9, 0.9) * SinOsc.kr(vib);
// sound = Select.ar(vib > 0.0, [sound * SinOsc.kr(vib), sound]);
OffsetOut.ar(out, DirtPan.ar(sound * 20.dbamp, ~dirt.numChannels, pan, envGen));
}).add;


// Originally called \ChicagoPad2
/*SynthDef(\chicago, { |out, freq, note, cutfreq=1250, velocity = 0.2, gate=1, speed=1, sus=0.5, dec=0.01, pan, begin=0, end=1, up = 0 |

    var freq2,freq3,snd, env, envGen, line;

	dec = dec * 0.1;
	// freq = (note + up).midicps;
  // freq2 = (note2 + up).midicps;
  // freq3 = (note3 + up).midicps;
  freq2 = (freq.cpsmidi.round + 5 + up).midicps;
  freq3 = (freq.cpsmidi.round + 7 + up).midicps;

	//freq = note;
	//freq2 = note2;
	//freq3 = note3;

	freq = freq + SinOsc.kr(freq*1/2, 0, freq/2, 0);

    snd = Saw.ar([freq, freq+1, freq-1, freq2, freq3] * [0.99,1])*0.1;

    snd = snd + VarSaw.ar(0.99*[freq, freq+1, freq-1, freq2, freq3, freq2+1, freq3+1],0, LFTri.kr(7.13).range(0.00,0.1))*0.1;

    snd = Mix(snd);
  snd = FreeVerb.ar(snd, 0.51,10,0.1)*2;
    snd = snd *8;
    snd = RLPF.ar(snd, SinOsc.kr([0.1,4.2], 0, [1700,480], [4000,700,5000])/[20.51,20], SinOsc.ar(0.1,1.5*pi)+1.05)/3;
    snd = Mix(snd);

    snd = MoogFF.ar(snd, SinOsc.kr(0.08, 0.5, cutfreq/10, cutfreq), 3, 0);

  // line = Line.ar(begin, end, sustain, doneAction:2);
	env = Env([0, 1, 0],[1, 5], curve:\sqr);
	envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));

	//env = EnvGen.ar(Env.adsr(0.4, 0.01,sustain,0.4), gate, doneAction:2);

	//snd = snd * envGen;
    //snd = snd * EnvGen.ar(Env.adsr(0.4, 0.01,0.8,0.4), gate, doneAction:2);

    snd = [snd , AllpassC.ar(snd, dec, 0.05+SinOsc.ar(0.11).range(0,0.045), 0.3)];
	//snd = snd.tanh*2;

	OffsetOut.ar(out, Pan2.ar(snd, pan, envGen));

}, metadata: (credit: "https://github.com/pixelpusher")).add;*/
)
