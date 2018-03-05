(
SynthDef(\sample, {
  |out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, sustain = 20|
  var sample;
  sample = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, 1, BufDur.kr(buf)*pos*44100, doneAction:2) * EnvGen.ar(Env.linen(0.01,sustain,0), doneAction:2);
  OffsetOut.ar(out, Pan2.ar(sample * amp, pan));
}).add;


SynthDef(\fm, {
  |out, amp=0.9, attack=0.001, sustain=1, accel, carPartial=1, modPartial=1, index=3, mul=0.25, detune=0.1, pan=0, freq|
  var env, mod, car;
  amp = amp * 0.9;
  env = EnvGen.ar(Env.perc(attack, 0.999, 1, -3), timeScale: sustain / 2, doneAction:2);
  mod = SinOsc.ar(freq * modPartial * Line.kr(1,1+accel, sustain), 0, freq * index * LFNoise1.kr(5.reciprocal).abs);
  car = SinOsc.ar(([freq, freq+detune] * carPartial) + mod,	0, mul);
  OffsetOut.ar(out, Limiter.ar(Pan2.ar(car * env, pan, amp), 0.9));
}, metadata: (credit: "@munshkr")).add;


SynthDef(\fms, {
  |out, amp=0.9, attack=0.001, sustain=1, accel, carPartial=1, modPartial=1, index=3, mul=0.25, detune=0.1, pan=0, freq, mix=0.33, room=0.5, tsdelay, xsdelay = 1|
  var env, mod, car;
  var signal, delayTime, delays, freqs, filtered;
  var size = 12;
  var maxDelayTime = 0.2;

  amp = amp * 0.9;
  env = EnvGen.ar(Env.perc(attack, 0.999, 1, -3), timeScale: sustain / 2, doneAction:2);
  mod = SinOsc.ar(freq * modPartial * Line.kr(1,1+accel, sustain), 0, freq * index * LFNoise1.kr(5.reciprocal).abs);
  car = SinOsc.ar(([freq, freq+detune] * carPartial) + mod,	0, mul);
  car = FreeVerb.ar(Mix.ar(car), mix, room);

  delayTime = tsdelay * maxDelayTime;
  filtered = (1..size).sum { |i|
    var filterFreq = i.linexp(1, size, 40, 17000);
    var sig = BPF.ar(car, filterFreq, 0.01);
    DelayN.ar(sig, maxDelayTime, (i & xsdelay * (1/size) * delayTime) * LFNoise2.kr(10.2 * tsdelay, 2.5).abs);
  };
  car = car * 0.2 + (filtered * 4);

  OffsetOut.ar(out, Limiter.ar(Pan2.ar(car * env, pan, amp), 0.9));
}, metadata: (credit: "based on @munshkr's fm")).add;


// acid

SynthDef(\sc303, {
  |out=0, gate=1, wave=0, lctf=100, hctf=1000, rq=0.5, sustain=0.09, decay=1.0, amp=0.75, pan=0.5, freq|
  var  sig, env, filEnv, volEnv, waves;
  env = EnvGen.kr(Env.asr, gate, doneAction: 2);
  volEnv =  EnvGen .ar( Env .new([10e-10, 1, 1, 10e-10], [0.01, sustain, decay],  \exp ), gate);
  filEnv =  EnvGen .ar( Env .new([10e-10, 1, 10e-10], [0.01, decay],  \exp ), gate);
  waves = [Saw .ar(freq, volEnv),  Pulse .ar(freq, 0.5, volEnv) ] * env;
  sig = RLPF .ar(Select.ar(wave, waves), lctf + (filEnv * hctf), rq) * amp;
  OffsetOut.ar(0, Pan2.ar(sig, pan, amp));
}, metadata:(credit: "based on http://sccode.org/1-4Wy")).add;



// randon

SynthDef(\epic, {
  |out, attack=0.01, sustain=1, amp=0.9, pan, freq|
  var env, gen, fmod, rqmod, snd;
  env = EnvGen.ar(Env.perc(attack, 0.999, 1, -3), timeScale: sustain / 2, doneAction:2);
  freq = { freq * LFNoise2.kr(1,0.01,1) }!24;
  gen = LFSaw.ar(freq) * 0.1;
  fmod = LFCub.kr(1/12).range(1, MouseX.kr(2,16)); // modulate filter with mouse
  rqmod = LFNoise2.kr(1/8).range(0.1,1.0);
  snd = RLPF.ar(gen, freq * fmod, rqmod);
  OffsetOut.ar(out, Limiter.ar(Pan2.ar(Splay.ar(snd) * env, pan, amp), 0.9));
}).add;


SynthDef(\epic2, {
  |out, attack=0.01, sustain=1, mod=0.1, amp=0.9, pan, freq|
  var env, gen, fmod, rqmod, snd;
  env = EnvGen.ar(Env.perc(attack, 0.999, 1, -3), timeScale: sustain / 2, doneAction:2);
  freq = { freq * LFNoise2.kr(1,0.01,1) }!24;
  gen = LFSaw.ar(freq) * 0.1;
  fmod = LFCub.kr(1/12).range(1, FSinOsc.kr(mod).range(2,16)); // modulate filter with mouse
  rqmod = LFNoise2.kr(1/8).range(0.1,1.0);
  snd = RLPF.ar(gen, freq * fmod, rqmod);
  OffsetOut.ar(out, Limiter.ar(Pan2.ar(snd * env, pan, amp), 0.9));
}).add;

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

// ted the trumpet

SynthDef(\rh1,{|out=0 freq=261.6255653006 amp=0.1 gate=1 cutoff=1500 rq=0.5 pan=0.0|
  var sig, filter, env, pulse1, pulse2, pulse3;
  pulse1 = Pulse.ar(freq:freq*1.01, width:0.2, mul:0.7);
  pulse2 = Mix(Pulse.ar(freq:freq*[1,33.5.midiratio], width:[0.2,0.1], mul:[0.7,0.5]));
  pulse3 = Pulse.ar(freq:freq*0.99, width:0.2, mul:0.7);
  sig = [pulse1, pulse2, pulse3];
  sig = Splay.ar(sig, spread: 0.9, center:pan);
  env = EnvGen.ar(Env.adsr(0.0,0.8,0.8,0.5),gate,doneAction:2);
  sig = BLowPass4.ar(sig,(cutoff*(env.squared))+200+freq,rq);
  sig = Compander.ar(3*sig,sig,0.5,1,4);
  Out.ar(out, sig * env * amp * 0.4);
}).add;
SynthDef(\rh2, {
  |
  // standard meanings
  out = 0, freq = 440, gate = 1, pan = 0, amp = 0.1,
  // all of these range from 0 to 1
  vel = 0.8, modIndex = 0.2, mix = 0.2, lfoSpeed = 0.4, lfoDepth = 0.1
  |
  var env1, env2, env3, env4;
  var osc1, osc2, osc3, osc4, snd;
  lfoSpeed = lfoSpeed * 12;
  freq = freq * 2;
  env1 = EnvGen.ar(Env.adsr(0.001, 1.25, 0.0, 0.04, curve: \lin));
  env2 = EnvGen.ar(Env.adsr(0.001, 1.00, 0.0, 0.04, curve: \lin));
  env3 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin), gate, doneAction: 2);
  env4 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin));
  osc4 = SinOsc.ar(freq * 0.5) * 2pi * 2 * 0.535887 * modIndex * env4 * vel;
  osc3 = SinOsc.ar(freq, osc4) * env3 * vel;
  osc2 = SinOsc.ar(freq * 15) * 2pi * 0.108819 * env2 * vel;
  osc1 = SinOsc.ar(freq, osc2) * env1 * vel;
  snd = Mix((osc3 * (1 - mix)) + (osc1 * mix));
  snd = snd * (SinOsc.ar(lfoSpeed) * lfoDepth + 1);
  snd = Pan2.ar(snd, pan, amp);
  Out.ar(out, snd);
}).add;

// foxdot

SynthDef.new(\soprano,
  {|out=0, amp=0.9, attack=0.01, sustain=1, release=0.5, vib=5, slide=0, rate=1, verb=0.5, slidefrom=1, fmod=0, pan=0, freq|
    var osc, env;
    amp = amp * 0.9;
    freq = freq + fmod;
    freq = Line.ar(freq * slidefrom, freq * (1 + slide), sustain);
    freq = Vibrato.kr(freq, rate: vib);
    env = EnvGen.ar(Env.perc(attackTime: attack, releaseTime: release, level: amp), timeScale: sustain, doneAction: 2);
    osc = (SinOsc.ar((freq * 3), mul: amp) + SinOscFB.ar((freq * 3), mul: (amp / 2)));
    osc = osc * env;
    OffsetOut.ar(out, Limiter.ar(Pan2.ar(osc, pan, amp), 0.9));
}, metadata: (credit: "https://github.com/Qirky/FoxDot")).add;


SynthDef.new(\varsaw,
  {|out=0, amp=0.9, vib=0, slide=0, rate=1, attack=0.01, sustain=1, slidefrom=1, fmod=0, pan=0, freq|
    var osc, env;
    amp = amp * 0.9;
    freq = freq + fmod;
    freq = Line.ar(freq * slidefrom, freq * (1 + slide), sustain);
    freq = Vibrato.kr(freq, rate: vib);
    osc=VarSaw.ar([freq, (freq * 1.005)], mul: (amp), width: rate);
    env=EnvGen.ar(Env(levels: [amp, amp, amp], curve: 'lin', times: (sustain / 2)), doneAction: 2);
    osc = (osc * env * EnvGen.ar(Env.perc(attack,sustain), doneAction:2)) * 0.125;
    OffsetOut.ar(out, Limiter.ar(Pan2.ar(osc, pan, amp), 0.9));
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
  OffsetOut.ar(out, Limiter.ar(Pan2.ar(osc, pan, amp), 0.9));
}, metadata: (credit: "https://github.com/Qirky/FoxDot")).add;

)