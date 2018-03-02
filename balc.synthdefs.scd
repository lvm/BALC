(
SynthDef(\in, { |out, in = 0, amp=0.9| OffsetOut.ar(out, SoundIn.ar(in)!2 * amp); }).add;


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
  car = FreeVerb.ar(Mix.ar(car), mix, room);
  car = Select.ar(wave, [car, Decimator.ar(car, 44100/crush, bits)]);
  OffsetOut.ar(out, Limiter.ar(Pan2.ar(car * env, pan, amp), 0.9));
}, metadata: (credit: "based on @munshkr's fm")).add;


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
  waves = [ Saw .ar(freq, volEnv),  Pulse .ar(freq, 0.5, volEnv)] * env;
  sig = RLPF .ar(  Select .ar(wave, waves), lctf + (filEnv * hctf), rq).dup * amp;
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