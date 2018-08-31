(
// SETUP
~drums = Dictionary.new(n: 19);
/* DRUM NAMES
Crash1 Crash2
HHClsdLH HHClsdRH HHOpn HHPed HHSmiOpn
Kick
Ride RideBell
SnareHrdLH SnareHrdRH SnareLH SnareRH SnareRim
Tom1LH Tom1RH Tom2LH Tom2RH */
p = Platform.userHomeDir +/+ "projects/supercollider/samples/CLudwig/";
PathName.new(path: p).filesDo({ | item |
	var name = item.fileName.split($-)[0].asSymbol;
	var samples = ~drums.atFail(name, { List.new });
	var buf = Buffer.read(s, item.fullPath );
	buf.postln;
	~drums.put(name.asSymbol, samples.add(buf));
});

~drums.postln;
)

(
SynthDef(\player, { arg  out = 0, bufnum;
    Out.ar( out,
		PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum))
    )
}).add;
)

(
// PLAYER
p = Pbind(
        // Use \harpsi, not \default
    \instrument, \player,
	\bufnum, Prand(~drums.at(\Kick), 32),
	// \degree, Pseries(0, 1, 8),-
    \dur, 0.25
).play;

)

(
// CLEANUP
~drums.keys.do({ | item |
	~drums.at(item).do({ | i |
		i.free;
	});
});

~drums.postln;
)

(
x.free;
currentEnvironment.clear;
)
