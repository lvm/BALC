(
z = Dictionary[
  \prep->
  "Pbind("
  "\\midinote, e.midinote.pseq,"
  "\\chan, e.chan.pseq,"
  "\\dur, e.dur.pseq,"
  "\\type, \md,"
  ")",
  \pdef->
  "Pdef(\\foo,\n"
  "\tPbind(\n"
  "\t\t\\instrument, \\default,\n"
  "\t\t\\amp, 0.9,\n"
  "\t\t\\dur, 1,\n"
  "\t\t\\out, 0,\n"
  "\t)\n"
  ").play(quant:4);",
  \pdirt->
  "Pdef(\\foo,\n"
  "\tPbind(\n"
  "\t\t\\type, \\dirt,\n"
  "\t\t\\s, \\default,\n"
  "\t\t\\gain, 0.9,\n"
  "\t\t\\dur, 1,\n"
  "\t\t\\orbit, 0,\n"
  "\t)\n"
  ").play(quant:4);",
  \pmidi->
  "Pdef(\\moo,\n"
  "\tPbind(\n"
  "\t\t\\type, \\midi,\n"
  "\t\t\\midiout, ~midiOut,\n"
  "\t\t\\chan, 0,\n"
  "\t\t\\amp, 0.9,\n"
  "\t\t\\dur, 1,\n"
  "\t)\n"
  ").play(quant:4);",
  \pbmidi->
  "Pbindef(\\moo,\n"
  "\t\t\\type, \\midi,\n"
  "\t\t\\midiout, ~midiOut,\n"
  "\t\t\\chan, 0,\n"
  "\t\t\\amp, 0.9,\n"
  "\t\t\\dur, 1,\n"
  ").play(quant:4);",
  \pmcontrol ->
  "Pbind(\n"
  "\t\t\\type, \\midi,\n"
  "\t\t\\midiout, ~midiOut,\n"
  "\t\t\\midicmd, \\control,\n"
  "\t\t\\control, Pseq([].midiRange, inf),\n"
  "\t\t\\ctlNum, 0,\n"
  "\t\t\\chan, 0,\n"
  ").play(quant:4);",
  \pstop-> "Pdef.all.do{|p| p.stop; p.clear; }",
  \tempo-> "(\nTempoClock.default.tempo = 2\n)",
];
)
