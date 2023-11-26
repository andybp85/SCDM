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

~kit = Dictionary.new(n: 19);
/* DRUMS, Dyn Levels
[ SabHHXEvo20_Dyn, 16 ]
[ Rodgers_DynRH, 16 ]
[ ZildMstrsnd_DynPed, 10 ]
[ Rodgers_HrdRH, 8 ]
[ Rodgers_RimClck, 8 ]
[ ZildMstrsnd_DynClsdLH, 16 ]
[ ZildMstrsnd_DynSmiOpn, 16 ]
[ Rodgers_HrdLH, 8 ]
[ CLudwigKick_Dyn, 12 ]
[ ZildjinCrsh1_Dyn, 8 ]
[ SabHHXEvo20_Bell, 16 ]
[ CLudwigTom1_DynLH, 16 ]
[ CLudwigTom2_DynLH, 16 ]
[ CLudwigTom1_DynRH, 16 ]
[ CLudwigTom2_DynRH, 16 ]
[ Rodgers_DynLH, 16 ]
[ ZildjinCrsh2_Dyn, 8 ]
[ ZildMstrsnd_DynClsdRH, 16 ]
[ ZildMstrsnd_DynOpn, 16 ]
*/
p = Platform.userHomeDir +/+ "Projects/samples/CLudwig/";
PathName.new(path: p).filesDo({ | item |
    var fname = item.fileName.split($.)[0];
    var dynData = fname.findRegexp("[0-9]{2}").last;
    var splitAt = dynData[0];
    var name = fname.copyRange(0, splitAt - 1).replace("-", "_").replace(" ", "").asSymbol;
    var samples = ~kit.atFail(name, { List.new });
    var buf = Buffer.read(s, item.fullPath );
    ~kit.put(name.asSymbol, samples.add(buf));
});

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
    \bufnum, Pwrand(~kit.at(\CLudwigKick_Dyn), ~weights.at(\CLudwigKick_Dyn), 2),
    \dur, Pseq([2.5, 1.5], 2)
);

~snare = Pbind(
    \instrument, \player,
    \bufnum, Pwrand(~kit.at(\Rodgers_DynRH), ~weights.at(\Rodgers_DynRH), 4),
    \dur, Pseq([Rest(1), 1, Rest(1), 1], 4)
);

~hats = Pbind(
    \instrument, \player,
    \bufnum, Pwrand(~kit.at(\ZildMstrsnd_DynClsdRH), ~weights.at(\ZildMstrsnd_DynClsdRH), 8),
    \dur, 0.5
);
)

p = Ppar([~kick, ~snare, ~hats], 16).play;
p.stop;


(
/*
PLAY DRUMS
*/
~playDrums = { | patterns, bpm = 120, bars = 8, length = inf |
    var rhythmKit = patterns[\rhythm];
    var fillKit = patterns[if(patterns[\fill].isNil) { \rhythm } { \fill }];
    var rhythm = Ppar(rhythmKit.keys.collect({ | key |
        var dynamics = rhythmKit[key][\dynamics];
        var repeats = rhythmKit[key][\repeats];
        Pbind(
            \instrument, \player,
            \bufnum, Pwrand(
                ~kit[key].reverse.copyRange(dynamics[\hardest], dynamics[\softest]),
                dynamics[\weights],
                repeats
            ),
            \dur, Pseq(rhythmKit[key][\seq], repeats)
        );
    }), bars - 1);
    var fill = Ppar(fillKit.keys.collect({ | key |
        var dynamics = fillKit[key][\dynamics];
        var repeats = fillKit[key][\repeats];
        Pbind(
            \instrument, \player,
            \bufnum, Pwrand(
                ~kit[key].reverse.copyRange(dynamics[\hardest], dynamics[\softest]),
                dynamics[\weights],
                repeats
            ),
            \dur, Pseq(fillKit[key][\seq], repeats)
        );
    }), 1);
    TempoClock.default.tempo = bpm / 60;
    Pseq([rhythm, fill], length);
};
)

(
~dnb = (
    \rhythm: (
        \CLudwigKick_Dyn: (
            \dynamics: (
                \hardest: 0,
                \softest: 2,
                \weights: ~calcWeights.value(3)
            ),
            \seq: [2.5, 1.5],
            \repeats: 2
        ),
        \Rodgers_DynLH: (
            \dynamics: (
                \hardest: 0,
                \softest: 2,
                \weights: ~calcWeights.value(3)
            ),
            \seq: [Rest(1), 1, Rest(1), 1],
            \repeats: 4
        ),
        \ZildMstrsnd_DynClsdRH: (
            \dynamics: (
                \hardest: 4,
                \softest: 6,
                \weights: ~calcWeights.value(3)
            ),
            \seq: [0.5],
            \repeats: 8
        )
    )
);

~playDrums.value(patterns: ~dnb, bpm: 174).play;
)

(
~swing = (
    \rhythm: (
        \CLudwigKick_Dyn: (
            \dynamics: (
                \hardest: 0,
                \softest: 2,
                \weights: ~calcWeights.value(3)
            ),
            \seq: [1],
            \repeats: 4
        ),
        \Rodgers_DynLH: (
            \dynamics: (
                \hardest: 0,
                \softest: 2,
                \weights: ~calcWeights.value(3)
            ),
            \seq: [Rest(1), 1, Rest(1), 1],
            \repeats: 4
        ),
        \ZildMstrsnd_DynClsdRH: (
            \dynamics: (
                \hardest: 4,
                \softest: 6,
                \weights: ~calcWeights.value(3)
            ),
            \seq: [1, Rest(0.5), 0.5],
            \repeats: 6
        ),
        \ZildMstrsnd_DynSmiOpn: (
            \dynamics: (
                \hardest: 4,
                \softest: 6,
                \weights: ~calcWeights.value(3)
            ),
            \seq: [Rest(1), 0.5, Rest(0.5)],
            \repeats: 6
        ),
    )
);

~playDrums.value(patterns: ~swing, bpm: 120).play;
)

(
// CLEANUP
~kit.keys.do({ | item |
    ~kit.at(item).do({ | i |
        i.free;
    });
});

~kit.postln;

)
