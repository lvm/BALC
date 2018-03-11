(
// jackd.exe -R -P95 -Xwinmme -S -d portaudio -d "ASIO::Focusrite USB ASIO" -r44100 -p256 -i2 -o4
s = Server.default;
s.options.device = "ASIO : JackRouter";
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
p.quant = 2
;
r = Repetition(p);
m = r.initMIDI("LoopBe Internal MIDI", "LoopBe Internal MIDI");
r.midiEventTypes;  // setup repetition midi stuff
)
