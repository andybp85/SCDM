(
~drums = Dictionary.new(n: 19);
/* DRUM NAMES
Crash1 Crash2
HHClsdLH HHClsdRH HHOpn HHPed HHSmiOpn
Kick
Ride RideBell
SnareHrdLH SnareHrdRH SnareLH SnareRH SnareRim
Tom1LH Tom1RH Tom2LH Tom2RH
*/

p = Platform.userHomeDir +/+ "projects/supercollider/samples/CLudwig/";
PathName.new(path: p).filesDo({ | item |
	var name = item.fileName.split($-)[0].asSymbol;
	var samples = ~drums.atFail(name, { List.new });
	~drums.put(name, samples.add(Buffer.read(s, item.fullPath )));
});

x = SynthDef("tutorial-PlayBuf",{ arg out = 0, bufnum;
    Out.ar( out,
        PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum))
    )
});

~drums.keys.do({ | item |
	~drums.at(item).do({ | i |
		i.postln;
		x.play(s, [\bufnum, i]);
	});
});

x.free;
currentEnvironment.clear;
)



/*// now play it
(
x = SynthDef(\help_Buffer, { arg out = 0, bufnum;
    Out.ar( out,
        PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum))
    )
}).play(s,[\bufnum, b]);
)
x.free; b.free;

// with an action function
// note that the vars are not immediately up-to-date
(
b = Buffer.read(s, p, action: { arg buffer;
    ("After update:" + buffer.numFrames).postln;
    x = { PlayBuf.ar(1, buffer, BufRateScale.kr(buffer)) }.play;
});
("Before update:" + b.numFrames).postln;
)
x.free; b.free;*/