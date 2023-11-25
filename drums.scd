(
s.quit;
s.boot;
)


(
// SETUP

// Function to generate a series of numbers where each number is half of the previous one
// and the sum is 1 - thanks chatgpt
~calcWeights = { |size|
    var numbers = (0..size-1).collect { |i| 0.5.pow(i) };
    var totalSum = numbers.sum;

    // Normalize to ensure the sum is 1
    numbers = numbers / totalSum;
    numbers;
};

~drums = Dictionary.new(n: 19);
~weights = Dictionary.new(n: 16);
/* DRUM NAMES
-> Set[ SabHHXEvo20_Dyn, Rodgers_DynRH, ZildMstrsnd_DynPed, Rodgers_HrdRH, Rodgers_RimClck, ZildMstrsnd_DynClsdLH, ZildMstrsnd_DynSmiOpn, Rodgers_HrdLH, CLudwigKick_Dyn, ZildjinCrsh1_Dyn, SabHHXEvo20_Bell, CLudwigTom1_DynLH, CLudwigTom2_DynLH, CLudwigTom1_DynRH, CLudwigTom2_DynRH, Rodgers_DynLH, ZildjinCrsh2_Dyn, ZildMstrsnd_DynClsdRH, ZildMstrsnd_DynOpn ]
*/
p = Platform.userHomeDir +/+ "Projects/samples/CLudwig/";
PathName.new(path: p).filesDo({ | item |
    var fname = item.fileName.split($.)[0];
    var dynData = fname.findRegexp("[0-9]{2}").last;
    var splitAt = dynData[0];
    var name = fname.copyRange(0, splitAt - 1).replace("-", "_").replace(" ", "").asSymbol;
    var samples = ~drums.atFail(name, { List.new });
    var buf = Buffer.read(s, item.fullPath );
    ~drums.put(name.asSymbol, samples.add(buf));
});

~drums.keys.do({ |key|
    ~weights.put(key, ~calcWeights.value(~drums[key].size).reverse);
});

~drums.postln;
~weights.postln;

SynthDef(\player, { arg  out = 0, bufnum;
    Out.ar( out,
        PlayBuf.ar(numChannels: 2, bufnum: bufnum, rate: BufRateScale.kr(bufnum), doneAction: 2)
    )
}).add;
)



(
TempoClock.default.tempo = 174 / 60;
// PLAYER
~kick = Pbind(
    \instrument, \player,
    \bufnum, Pwrand(~drums.at(\CLudwigKick_Dyn), ~weights.at(\CLudwigKick_Dyn), 2),
    \dur, Pseq([2.5, 1.5], 2)
);

~snare = Pbind(
    \instrument, \player,
    \bufnum, Pwrand(~drums.at(\Rodgers_DynRH), ~weights.at(\Rodgers_DynRH), 4),
    \dur, Pseq([Rest(1), 1, Rest(1), 1], 4)
);

~hats = Pbind(
    \instrument, \player,
    \bufnum, Pwrand(~drums.at(\ZildMstrsnd_DynClsdRH), ~weights.at(\ZildMstrsnd_DynClsdRH), 8),
    \dur, 0.5
);
)

p = Ppar([~kick, ~snare, ~hats], 16).play;
p.stop;

(
// CLEANUP
~drums.keys.do({ | item |
    ~drums.at(item).do({ | i |
        i.free;
    });
});

~drums.postln;

~weights.keys.do({ | item |
    ~weights.at(item).do({ | i |
        i.free;
    });
});

~weights.postln;
)
