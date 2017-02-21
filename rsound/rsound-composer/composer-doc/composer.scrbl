#lang scribble/manual

@title{RSound/Composer}

@author[(author+email "David Benoit" "david.benoit15@gmail.com")]

@(require (for-label racket
                     rsound
                     "../composer.rkt"))

@defmodule["composer.rkt"]{This module provides a music 
theory based abstraction layer for RSound.}

@section{Notes}

This section discusses how to create and play notes. The @racket[note] 
type is the basic unit of sound in @racket[rsound/composer].  

@defstruct[note ([letter symbol?][octave integer?]
                 [duration beat-value-procedure?])]{
Represents a note. 
For example:
@racketblock[
(note 'C 5 whole-note)]

Will create a @racket[note] with the pitch c5 and the duration of a 
whole-note.  In order to accurately represent western musical notation, 
the sets of arguments allowed to be passed to @racket[note] are very strict 
subsets of the possible elements of the types listed by the constructor.

The @racket[letter] argument must be one of the following symbols:
@racketblock[
'C 'D 'E 'F 'G 'A 'B 'Rest]
Or any symbol which is comprised of one of the above symbols 
(except @racket['Rest]) combined with an arbitrary number of occurrences of 
@racket[#\#] or @racket[#\b] (sharp and flat).  @racket[octave] must be an 
@racket[integer] between -1 and 7, for midi compatibility.

The @racket[duration] argument must be a @racket[beat-value-procedure?].  
The duration is stored as a procedure to delay the computation of the note 
length in frames until the user supplies a tempo to the scheduler.  The 
@racket[rsound/composer] module provides many of these beat-value-procedures 
built-in, such as @racket[whole-beat], @racket[half-beat], @racket[quarter-beat], 
@racket[eighth-beat], and more.  The @racket[beat-value] type will be discussed 
in detail later.
}

Here are some examples of how to create @racket[notes]:
@racketblock[
(note 'A 3 whole-beat)
(note 'Eb 7 half-beat)
(note 'G# 4 quarter-beat)
(note 'C## 6 eighth-beat)
(note 'Bbb 5 sixteenth-beat)]

The built in @racket[note] constructor makes rsound-composer scores diffuclt for 
the eye to read.  As such, there are @racket[note] and @racket[rest] constructors 
for each different built-in @racket[beat-value].  The above example could be rewritten 
equivalently:

@racketblock[
(whole-note 'A 3)
(half-note 'Eb 7)
(eighth-note 'G# 4)
(sixteenth-note 'C## 6)
(thirtysecond-note 'Bbb 5)]


@defproc[(whole-note [letter symbol?] [octave exact-integer?]) note?]
Creates a whole note.

@defproc[(half-note [letter symbol?] [octave exact-integer?]) note?]
Creates a half note.

@defproc[(quarter-note [letter symbol?] [octave exact-integer?]) note?]
Creates a quarter note.

@defproc[(eighth-note [letter symbol?] [octave exact-integer?]) note?]
Creates an eighth note.

@defproc[(sixteenth-note [letter symbol?] [octave exact-integer?]) note?]
Creates a sixteenth note.

@defproc[(thirtysecond-note [letter symbol?] [octave exact-integer?]) note?]
Creates a thirtysecond note.

@subsection{Dotted Notes}

In music notation, the dot is a unary operator which modifies a note's 
duration by 1.5
@defproc[(dotted-whole-note [letter symbol?] [octave exact-integer?]) note?]
Creates a dotted whole note. 

@defproc[(dotted-half-note [letter symbol?] [octave exact-integer?]) note?]
Creates a dotted half note.

@defproc[(dotted-quarter-note [letter symbol?] [octave exact-integer?]) note?]
Creates a dotted quarter note.

@defproc[(dotted-eighth-note [letter symbol?] [octave exact-integer?]) note?]
Creates a dotted  eighth note.

@defproc[(dotted-sixteenth-note [letter symbol?] [octave exact-integer?]) note?]
Creates a dotted sixteenth note.

@defproc[(double-dotted-whole-note [letter symbol?] [octave exact-integer?]) note?]
Creates a double dotted whole note.

@defproc[(double-dotted-half-note [letter symbol?] [octave exact-integer?]) note?]
Creates a double dotted half note.

@defproc[(double-dotted-quarter-note [letter symbol?] [octave exact-integer?]) note?]
Creates a double dotted quarter note.

@defproc[(double-dotted-eighth-note [letter symbol?] [octave exact-integer?]) note?]
Creates a double dotted eighth note.

@subsection{Working with Notes}

@defproc[(play-note [note note?]
                    [#:instrument instr instrument? (main-synth-instrument 7)]
                    [#:tempo tempo exact-positive-integer? 120]) 
                    exact-positive-integer?]{
Will play a note and return the length of the note in frames. You can use keywords 
to specify the synthesizer @racket[instrument] and tempo (in beats per minute) to 
play the note with.}

@defproc[(note? [item any/c]) boolean?]{
Returns @racket[#t] if @racket[item] is a @racket[note]. Returns 
@racket[#f] otherwise.}

@defproc[(note-letter [note note?]) symbol?]{
Returns the letter symbol of a @racket[note].}

@defproc[(note-octave [note note?]) integer?]{
Returns the octave of a @racket[note].}

@defproc[(note-duration [note note?]) beat-value-procedure?]{
Returns the @racket[beat-value-procedure?] of a @racket[note].} 

@defproc[(make-note-from-midi-num [midi-number exact-positive-integer?]
                                  [duration beat-value-procedure?]) note?]{
An alternate constructor which creates a note from a midi-number and a 
beat-value-procedure.  The @racket[note-letter] of notes created this way 
will be limited to the following symbols:

@racketblock[
    'C 'C#/Db 'D 'D#/Eb 'E 'F 'F#/Gb 'G 'G#/Ab 'A 'A#/Bb 'B]
}

@defproc[(note-midi-number [note non-rest-note?]) note?]{
Returns the midi-number of a note.}

@defproc[(note-freq [note note?]) exact-nonnegative-integer?]{
Returns the frequency in Hz of a note.}

@defproc[(note-interval-up [note note?][interval symbol?]) note?]{
Returns a new note which is the musical @racket[interval] up from the original 
note. @racket[interval] must be one of the following symbols:

@racketblock[
  'Unison 'AugmentedUnison 'Minor2nd 'Major2nd 
  'Augmented2nd 'Minor3rd 'Major3rd 'Perfect4th
  'Augmented4th 'Diminished5th 'Perfect5th
  'Augmented5th 'Minor6th 'Major6th 'Minor7th
  'Major7th 'PerfectOctave]

For example:

@racketblock[
(display (note->list (note-interval-up (quarter-note 'D 3))))

-> '(G 5 eighth-beat)]
}

@defproc[(note-interval-down [note note?][interval symbol?]) note?]{
Returns a new note which is the musical @racket[interval] down from the original 
note.  Uses same interval symbols as above.}

@section{Rests}
A @racket[rest?] is an instance of type @racket[note] which produces silence for 
the duration of the given @racket[beat-value].

@defproc[(make-rest [duration beat-value-procedure?]) rest?]{
Constructs a @racket[note] which produces silence for the given duration.}

@defproc[(rest? [item any/c]) boolean?]{
Returns @racket[#t] if the item is a @racket[rest?]. Returns @racket[#f] 
otherwise.}

@defproc[(non-rest-note? [item any/c]) boolean?]{
Returns @racket[#t] if the item is a @racket[note], but not a @racket[rest?].  
Returns @racket[#f] otherwise. }

The following constructors are implemented as procedures instead of 
values to make source code smoother to to read when mixing notes and rests.  

@defproc[(whole-rest) rest?]{
Produces a rest with the duration of a @racket[whole-beat].}

@defproc[(half-rest) rest?]{
Produces a rest with the duration of a @racket[half-beat].}

@defproc[(quarter-rest) rest?]{
Produces a rest with the duration of a @racket[quarter-beat].}

@defproc[(eighth-rest) rest?]{
Produces a rest with the duration of a @racket[eighth-beat].}

@defproc[(sixteenth-rest) rest?]{
Produces a rest with the duration of a @racket[sixteenth-beat].}

@defproc[(thirtysecond-rest) rest?]{
Produces a rest with the duration of a @racket[thirtysecond-beat].}

@defproc[(dotted-whole-rest) rest?]{
Produces a rest with the duration of a @racket[dotted-whole-beat].}

@defproc[(dotted-half-rest) rest?]{
Produces a rest with the duration of a @racket[dotted-half-beat].}

@defproc[(dotted-quarter-rest) rest?]{
Produces a rest with the duration of a @racket[dotted-quarter-beat].}

@defproc[(dotted-eighth-rest) rest?]{
Produces a rest with the duration of a @racket[dotted-eighth-beat].}

@defproc[(dotted-sixteenth-rest) rest?]{
Produces a rest with the duration of a @racket[dotted-sixteenth-beat].}

@defproc[(double-dotted-whole-rest) rest?]{
Produces a rest with the duration of a @racket[double-dotted-whole-beat].}

@defproc[(double-dotted-half-rest) rest?]{
Produces a rest with the duration of a @racket[double-dotted-half-beat].}

@defproc[(double-dotted-quarter-rest) rest?]{
Produces a rest with the duration of a @racket[double-dotted-quarter-beat].}

@defproc[(double-dotted-eighth-rest) rest?]{
Produces a rest with the duration of a @racket[double-dotted-eighth-beat].}

@section{Beat Values}

@defstruct[beat-value ([name symbol?]
                      [frames exact-positive-integer?])]{
Beat values are named frame lengths which are produced by a 
@racket[beat-value-procedure?] and used by rsound-composer to schedule notes. 
It is usually unnecessary for users to be working directly with instances of 
@racket[beat-value], but it is useful to know about their structure for implementing 
new @racket[beat-value-procedures].}

@racket[beat-value-procedures] are @racket[procedure?]s which take an 
@racket[exact-positive-integer] representing a tempo, and return a 
@racket[beat-value].  The rsound-composer scheduler takes a @racket[note]'s 
@racket[beat-value-procedure], and calls it with the tempo argument to figure 
out the frame-length of the note.  Frame-length calculation is delayed until 
scheduling time so the user can easily specify a tempo for larger sections of 
notes at runtime or in a repl.  

@defproc[(beat-value-procedure? [beat-value-proc any/c]) boolean?]{
Returns @racket[#t] if the @racket[beat-value-proc] is a @racket[procedure?] 
which both takes an @racket[exact-positive-integer?] and returns a 
@racket[beat-value].  @racket[beat-value-procedure?] returns @racket[#f] otherwise.}

@defproc[(bpm-to-frames [tempo exact-positive-integer?]) exact-non-negative-intager?]}
Takes a tempo in beats-per-minute and returns the number of frames in one quarter-beat.}

@defproc[(null-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a beat-value with a frame length of 0 frames.  
@racket[null-beat]s are not used in playback, but are useful as place-holders
in musical computations to signify that the beat-value is undetermined or irrelevant.}

@defproc[(whole-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a whole-beat.  A whole-beat is named as such because it 
is the beat-value corresponding to a whole note.  To clarify, it does not refer to 
a single beat in a time signature. All beat-values and beat-value-procedures are 
named according to thisscheme.}

@defproc[(half-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a half-beat.}

@defproc[(quarter-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a quarter-beat.}

@defproc[(eighth-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a eighth-beat.}

@defproc[(sixteenth-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a sixteenth-beat.}

@defproc[(thirtysecond-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a thirtysecond-beat.}

@defproc[(dotted-whole-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a dotted-whole-beat.}

@defproc[(dotted-half-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a dotted-half-beat.}

@defproc[(dotted-quarter-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a dotted-quarter-beat.}

@defproc[(dotted-eighth-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a dotted-eighth-beat.}

@defproc[(dotted-sixteenth-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a dotted-sixteenth-beat.}

@defproc[(double-dotted-whole-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a double-dotted-whole-beat.}

@defproc[(double-dotted-half-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a double-dotted-half-beat.}

@defproc[(double-dotted-quarter-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a double-dotted-quarter-beat.}

@defproc[(double-dotted-eighth-beat [tempo exact-positive-integer?]) beat-value?]{
Takes a tempo and produces a double-dotted-eighth-beat.}

@defproc[(subdivision [base-length-proc beat-value-procedure?]
                      [subdivisor exact-positive-integer?]) beat-value-procedure?]{
Takes a @racket[beat-value-procedure?] and an @racket[exact-positive-integer?] to 
subdivide by, and a returns a new @racket[beat-value-procedure], which is the 
subdivision of the original procedure by @racket[subdivisor].}

To create three eighth-note triplets:
@racketblock[
(note 'C 5 (subdivide eighth-beat 3))
(note 'E 5 (subdivide eighth-beat 3))
(note 'G 5 (subdivide eighth-beat 3))
]


@section{Synthesizer Instruments}

The library provides a way to create synthesizer instruments for playing 
@racket[rsound/composer] elements.

@defstruct[instrument ([name string?] [conversion-proc procedure?])]{
An @racket[instrument] is a structure which contains a name and a note-to-rsound conversion 
@racket[procedure].}

  The rsound/composer scheduler uses @racket[instruments] to turn 
@racket[notes] into @racket[rsounds] before scheduling them on a given @racket[pstream].  
Many playback functions allow users to specify an instrument using the 
@racket[#:instrument] keyword.

@racketblock[
(play-note (half-note 'E 4) #:instrument (vgame-synth-instrument 5))
]

The rsound/composer library provides wrappers around rsound/single-cycle 
synthesizers.

@defproc[(vgame-synth-instrument [spec exact-positive-integer?]) instrument?]{
Produces an @racket[instrument] with the single-cycle vgame spec @racket[spec].}

@defproc[(main-synth-instrument [spec exact-positive-integer?]) instrument?]{
Produces an @racket[instrument] with the single-cycle main spec @racket[spec].}

@defproc[(path-synth-instrument [spec exact-positive-integer?]) instrument?]{
Produces an @racket[instrument] with the single-cycle path spec @racket[spec].}

@section{Organizing Elements into Musical Excerpts}
RSound/Composer provides musical containers to organize elements into larger works.

@subsection{Measures}

Measures are containers for notes and harmonies intended to be played sequentially.

@defstruct[measure-struct ([measure-notes list?])]{
A @racket[measure-struct] is a data type which contains a list of notes.}

@racketblock[
  (measure-struct
    (list
      (quarter-note 'C 5)
      (quarter-note 'E 5)
      (quarter-note 'G 5)
      (quarter-note 'C 6)))]

Since having @racket[list]s strewn throughout a score can distract from its musical
expressiveness, a cleaner constructor is provided:

@defproc[(measure [note note?] ...) measure-struct?]{
Takes an arbitrary number of notes and creates a @racket[struct-measure]. 
Think of @racket[measure] as an alias to @racket[measure-struct].  This document
tends to refer to @racket[measure-structs] as simply @racket[measures].  They both 
denote the same data-type.}

@racketblock[
  (measure
    (quarter-note 'C 5)
    (quarter-note 'E 5)
    (quarter-note 'G 5)
    (quarter-note 'C 6))]

@defproc[(play-measure [measure measure?]
                    [#:instrument instr instrument? (main-synth-instrument 7)]
                    [#:tempo tempo exact-positive-integer? 120]) 
                    exact-positive-integer?]{
Plays a measure.  If no @racket[#:tempo] keword is given, the default tempo is
120 beats per minute.}

@racketblock[
(define m
  (measure
    (quarter-note 'C 5)
    (quarter-note 'E 5)
    (quarter-note 'G 5)
    (quarter-note 'C 6)))
(play-measure m #:tempo 80) 
]

You can also specify an instrument to use with the @racket[#:instrument] keyword.

@racketblock[
(define m
  (measure
    (quarter-note 'C 5)
    (quarter-note 'E 5)
    (quarter-note 'G 5)
    (quarter-note 'C 6)))
(play-measure m #:instrument (main-synth-instrument 12))
]


@defproc[(measure? [item any/c]) boolean?]{
Returns @racket[#t] if @racket[item] is a measure. Returns @racket[false] otherwise.}

@defproc[(measure-notes [measure measure?]) list?]{
Returns a measure's list of notes.}

@defproc[(measure-is-valid? [measure measure?] 
                            [time-signature time-signature?])
                            boolean?]{
Returns true if the combination of notes in @racket[measure] are valid in relation 
to the @racket[time-signature].}

@defproc[(measure-frames [measure measure?] 
                         [tempo exact-positive-integer?]) 
                        exact-nonnegative-integer?]{
Takes a measure and a tempo and returns the duration of the measure in frames.  This 
is useful when manually queuing measures on pstreams.}

@subsection{Harmony and Chords}

Harmonies are containers for notes intended to be played simuultaneously.

@defstruct[harmony-struct ([harmony-notes list?])]{
A @racket[harmony-struct] is a data type which contains a list of notes.  
}

@racketblock[
  (harmony-struct
    (list
      (quarter-note 'Ab 4)
      (quarter-note 'C 5)
      (quarter-note 'Eb 5)
      (quarter-note 'G 5)))]

However, the alternate constructor should be preferred for readability:

@racketblock[
  (harmony
      (quarter-note 'Ab 4)
      (quarter-note 'C 5)
      (quarter-note 'Eb 5)
      (quarter-note 'G 5))]

The rsound/composer sequencer overlays notes in a @racket[harmony] into 
a single @racket[rsound]. This allows harmonies to be intermixed with notes 
in any playback context.

@racketblock[
(define m
  (measure
    (quarter-note 'G 4)
    (harmony 
      (quarter-note 'B 4)
      (quarter-note 'D 5))
    (harmony 
      (quarter-note 'B 4)
      (quarter-note 'D 5))
    (quarter-note 'D 4)
    (harmony 
      (quarter-note 'B 4)
      (quarter-note 'D 5))
    (harmony 
      (quarter-note 'B 4)
      (quarter-note 'D 5))
    (quarter-note 'G 4)
    (harmony 
      (quarter-note 'B 4)
      (quarter-note 'D 5))
    (harmony 
      (quarter-note 'B 4)
      (quarter-note 'D 5))
    (whole-note 'G 3)))

(play-measure m #:tempo 160)]

They can even be passed directly to @racket[play-note]:

@racketblock[
(play-note 
  (harmony
    (quarter-note 'D 3)
    (quarter-note 'F 3)
    (quarter-note 'A 3)
    (quarter-note 'D 4)))
]

The library provides constructors for some basic closed root position chords.  

@defproc[(basic-chord [root note?] 
                      [quality symbol?] 
                      [beat-value beat-value?])
                      harmony?]{
Creates a chord with the given root, quality and beat-value.  Valid symbols for
@racket[quality] include:}

@racketblock[
    'Maj 'Min 'Dim 'Aug 'Maj7 
    'Min7 'Dom7 'HalfDim 'Dim7
]

For Example:

@racketblock[
(define C (note 'C 5 null-beat))
(basic-chord C 'Maj quarter-beat)
]

Would create a @racket[harmony] containing notes @racket[(quarter-note 'C 5)], 
@racket[(quarter-note 'E 5)] and @racket[(quarter-note 'G 5)].

Chords can also be created by specifying a key and roman numeral symbols
representing functional harmony in the key.  Support is currently limited to 
common classical period harmonic functions.

@defproc[(functional-harmony [key note?] 
                             [roman-numeral symbol?] 
                             [beat-value beat-value?])
                             harmony?]{
Creates a functional @racket[roman-numeral] harmony in the key of @racket[key].}
Valid @racket[roman-numeral]s include:

@racketblock[
  'I 'i 'I7 'i7 'V/IV 'V7/IV
  'ii 'ii-dim 'ii-dim7 'bII
  'V7/V 'iii 'bIII 'V7/V 'iii
  'V7/VI 'IV 'iv 'V 'V7 'vi
  'bVI 'vii-dim 'bVII]

For example:
@racketblock[
(define C (note 'C 5 null-beat))
(functional-harmony C 'V7 quarter-note)]

Would create a @racket[harmony] containing notes @racket[(quarter-note 'G 5)],
@racket[(quarter-note 'B 5)], @racket[(quarter-note 'D 6)], and
@racket[(quarter-note 'F 6)].


@section{Instrument Line}

Instrument Lines are collections of measures which are queued and played sequentially.
They are analagous to instrument lines on a grand staff in music notation.

@defstruct[instrument-line-struct ([instrument any/c] 
                                  [measure-list (listof? measure?)])]{
An @racket[instrument-line-struct] stores a list of measures, as well as 
the @racket[instrument] to play them.}

@racketblock[
(define line
  (instrument-line-struct
    (main-synth-instrument 34)
    (list
      (measure
        (quarter-note 'C  4)
        (quarter-note 'D  4)
        (quarter-note 'Eb 4)
        (quarter-note 'F  4))
      (measure
        (quarter-note 'G 4)
        (quarter-note 'F 4)
        (quarter-note 'D 4)
        (quarter-note 'B 3))
      (measure
        (whole-note 'C 4)))))
]


Just like @racket[struct-measure], a variardic constructor is provided to make 
source files easier to read for musician programmers.

@defproc[(instrument-line [instrument any/c] 
                          [measure measure?] ...) 
                          instrument-line-struct?]{
Takes an @racket[instrument] and an arbitrary number of @racket[measure]s,
and creates an instrument-line-struct.}

@racketblock[
(define line
  (instrument-line-struct
    (main-synth-instrument 34)
    (measure
      (quarter-note 'C  4)
      (quarter-note 'D  4)
      (quarter-note 'Eb 4)
      (quarter-note 'F  4))
    (measure
      (quarter-note 'G 4)
      (quarter-note 'F 4)
      (quarter-note 'D 4)
      (quarter-note 'B 3))
    (measure
      (whole-note 'C 4))))
]

@defproc[(play-instrument-line [instrument-line instrument-line?]
                    [#:tempo tempo exact-positive-integer? 120]) 
                    exact-positive-integer?]{
Plays a instrument-line.  If no @racket[#:tempo] keword is given, the default tempo is
120 beats per minute.}

@racketblock[
(define line
  (instrument-line-struct
    (main-synth-instrument 34)
    (measure
      (quarter-note 'C  4)
      (quarter-note 'D  4)
      (quarter-note 'Eb 4)
      (quarter-note 'F  4))
    (measure
      (quarter-note 'G 4)
      (quarter-note 'F 4)
      (quarter-note 'D 4)
      (quarter-note 'B 3))
    (measure
      (whole-note 'C 4))))
(play-instrument-line line #:tempo 80)
]

@defproc[(instrument-line? [item any/c]) boolean?]{
Returns @racket[#t] if @racket[item] is an @racket[instrument-line].  
Returns @racket[#f] otherwise.}

@defproc[(instr-line-instrument [instrument-line instrument-line?]) any/c]{
Returns @racket[instrument-line]'s @racket[instrument].}

@defproc[(instr-line-measure-list [instrument-line instrument-line?]) (listof? measure?)]{
Returns a list of @racket[instrument-line]'s @racket[measure]s.}

@defproc[(instr-line-is-valid? [instrument-line instrument-line?] 
                               [time-signature time-signature?])
                               boolean?]{
Checks all of @racket[instrument-line]'s @racket[measures] and returns 
@racket[#t] if they are all valid given the @racket[time-signature].
}

@section{Score Sections}

Score Sections allow the ability to synchronize the playback of
multiple Instrument Lines.

@defstruct[time-signature ([beats-per-measure exact-positive-integer?] 
                           [beat-denominator exact-positive-integer?])]{

}

@defstruct[section-struct ([time-sig time-signature?]
                           [key-sig note?]
                           [tempo exact-positive-integer?]
                           [instrument-line-list (listof? instrument-line?)])]{

}


@section{Scores}

@section{RSound Interop}

@section{Other Utilities}
