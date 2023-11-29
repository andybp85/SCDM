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

/* MAKE SURE: use cleanup code below before re-evaluating this or you can run out of Buffers
*/
~kit = Dictionary.new(n: 19);
/* DRUMS, Dyn Levels
[ CLudwigKick_Dyn, 12 ]
[ CLudwigTom1_DynLH, 16 ]
[ CLudwigTom1_DynRH, 16 ]
[ CLudwigTom2_DynLH, 16 ]
[ CLudwigTom2_DynRH, 16 ]
[ Rodgers_DynLH, 16 ]
[ Rodgers_DynRH, 16 ]
[ Rodgers_HrdLH, 8 ]
[ Rodgers_HrdRH, 8 ]
[ Rodgers_RimClck, 8 ]
[ SabHHXEvo20_Bell, 16 ]
[ SabHHXEvo20_Dyn, 16 ]
[ ZildMstrsnd_DynClsdLH, 16 ]
[ ZildMstrsnd_DynClsdRH, 16 ]
[ ZildMstrsnd_DynOpn, 16 ]
[ ZildMstrsnd_DynPed, 10 ]
[ ZildMstrsnd_DynSmiOpn, 16 ]
[ ZildjinCrsh1_Dyn, 8 ]
[ ZildjinCrsh2_Dyn, 8 ]
*/

// drum kit available here: https://www.analoguedrums.com/products/bigmono/
// change this to point to your kit
p = Platform.userHomeDir +/+ "Projects/supercollider/CLudwig/";
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
// based on https://youtu.be/5Adj-khTHl8?si=txfjTJ4ZdZkbc6Ha
~t = TempoClock.new(120/60).permanent_(true);
~postBeat = {~t.beats; 1;};
~t.schedAbs(~t.nextBar, {~postBeat.value});
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

(
/*
PLAY DRUMS

patterns: also see below
\rythm: regular drum beat
\dynamics: pick the drum hits the samples, 0 being hardest
\hardest, \softest: see List.copyRange
\weights: used by Pwrand to pick samples to play, see docs. helper ~calcWeights above
\seq: canb either be an array to be passed to Pseq, or a completely different sequence (WIIP)
\repeats: used by Pwrand (and Pseq if \seq is an array)
\fill: genrally turnaround. can be nil. same spec as above. will be played once at the end of
however many bars are spec'd (i.e. if bars = 8 it'll play 7x\rhythm and 1x\fill)
*/
~playDrums = { | patterns, bpm = 120, bars = 8, length = inf |
    var rhythmKit = patterns[\rhythm];
    var fillKit = patterns[if (patterns[\fill].isNil) { \rhythm } { \fill }];
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
            // TODO: get other sequences to work
			\dur, if (fillKit[key][\seq].isArray) { Pseq(fillKit[key][\seq], repeats) } { fillKit[key][\seq] }.postln;
        );
    }), 1);
    ~t.tempo = bpm / 60;
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

~swing = (
    \rhythm: (
        \CLudwigKick_Dyn: (
            \dynamics: (
                \hardest: 0,
                \softest: 1,
                \weights: ~calcWeights.value(2)
            ),
            \seq: [1, Rest(1)],
            \repeats: 4
        ),
        \Rodgers_DynLH: (
            \dynamics: (
                \hardest: 1,
                \softest: 2,
                \weights: ~calcWeights.value(2)
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
			\seq: [Rest(1), 0.65, 0.35],
            \repeats: 6
        ),
        \ZildMstrsnd_DynSmiOpn: (
            \dynamics: (
                \hardest: 3,
                \softest: 4,
                \weights: ~calcWeights.value(2)
            ),
            \seq: [1, Rest(1)],
            \repeats: 4
        ),
    ),
	\fill: (
		\CLudwigKick_Dyn: (
            \dynamics: (
                \hardest: 0,
                \softest: 1,
                \weights: ~calcWeights.value(1)
            ),
            \seq: [1],
            \repeats: 4
        ),
        \Rodgers_HrdLH: (
            \dynamics: (
                \hardest: 0,
                \softest: 6,
                \weights: 7.collect({1/7})
            ),
            \seq: [Rest(1), 0.3, Rest(1), 0.5],
            \repeats: 4
        ),
		\Rodgers_HrdRH: (
            \dynamics: (
                \hardest: 0,
                \softest: 6,
                \weights: 7.collect({1/7})
            ),
            \seq: [Rest(2), 0.5, 0.3, Rest(1)],
            \repeats: 4
        ),
        \ZildjinCrsh1_Dyn: (
            \dynamics: (
                \hardest: 0,
                \softest: 0,
                \weights: [1]
            ),
            \seq: [Rest(3), 1],
            \repeats: 2
        )
	)
);

~rock = (
    \rhythm: (
        \CLudwigKick_Dyn: (
            \dynamics: (
                \hardest: 0,
                \softest: 1,
                \weights: ~calcWeights.value(2)
            ),
            \seq: [1, Rest(1)],
            \repeats: 4
        ),
        \Rodgers_DynLH: (
            \dynamics: (
                \hardest: 1,
                \softest: 2,
                \weights: ~calcWeights.value(2)
            ),
            \seq: [Rest(1), 1, Rest(1), 1],
            \repeats: 4
        ),
        \ZildMstrsnd_DynOpn: (
            \dynamics: (
                \hardest: 6,
                \softest: 8,
                \weights: ~calcWeights.value(3)
            ),
            \seq: [0.5],
            \repeats: 8
        )
    ),
    \fill: (
        \CLudwigKick_Dyn: (
            \dynamics: (
                \hardest: 0,
                \softest: 1,
                \weights: ~calcWeights.value(1)
            ),
            \seq: [1],
            \repeats: 4
        ),
        \Rodgers_HrdLH: (
            \dynamics: (
                \hardest: 0,
                \softest: 6,
                \weights: 7.collect({1/7})
            ),
            \seq: [Rest(0.5), 0.25, Rest(0.25), 0.25, 0.25],
            \repeats: 8
        ),
        \Rodgers_HrdRH: (
            \dynamics: (
                \hardest: 0,
                \softest: 6,
                \weights: 7.collect({1/7})
            ),
            \seq: [0.25, 0.25, Rest(0.25), 0.25, Rest(0.5)],
            \repeats: 8
        ),
        \ZildjinCrsh1_Dyn: (
            \dynamics: (
                \hardest: 0,
                \softest: 0,
                \weights: [1]
            ),
            \seq: [Rest(3), 1],
            \repeats: 2
        )
    )
);

)

(
Pdef(\drums).clear;
Pdef(\drums).quant_([8]);
p = Pdef(\drums);
)

p.play(~t);
p.stop;

Pdef(\drums, ~playDrums.value(patterns: ~dnb, bpm: 174));
Pdef(\drums, ~playDrums.value(patterns: ~swing, bpm: 180, bars: 8));
Pdef(\drums, ~playDrums.value(patterns: ~rock, bpm: 120, bars: 8));



