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
	~drums.put(name, samples.add(Buffer.read(s, item.fullPath )));
});

x = SynthDef(\player, { arg  out = 0, bufnum, channels;
    Out.ar( out,
        PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum))
    )
});
)

(
// PLAYER
~drums.keys.do({ | item |
	~drums.at(item)[0].postln;
	x.play(s, [\bufnum, ~drums.at(item)[0]]);
	/*~drums.at(item).do({ | i |
		i.postln;
		// x.play(s, [\bufnum, i]);
	});*/
});

)

(
// CLEANUP
~drums.keys.do({ | item |
	~drums.at(item).do({ | i |
		i.free;
	});
});

x.free;
currentEnvironment.clear;
)
