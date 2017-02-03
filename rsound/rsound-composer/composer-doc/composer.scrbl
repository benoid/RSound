#lang scribble/manual

@title{RSound/Composer}

@author[(author+email "David Benoit" "david.benoit15@gmail.com")]

@(require (for-label racket
                     "../composer.rkt"))

@defmodule["composer.rkt"]{This module provides a music 
theory based abstraction layer for RSound.}

@section{Notes}

This section discusses how to create and play notes. The @racket[note] type is the basic unit of sound in @racket[rsound/composer].  

@defstruct[note ([letter symbol?][octave integer?][duration beat-value-procedure?])]{
Represents a note. For example:
@racketblock[
(note 'C 5 whole-note)]

Will create a @racket[note] with the pitch c5 and the duration of a whole-note.  In order to accurately represent western musical notation, the sets of arguments allowed to be passed to @racket[note] are very strict subsets of the possible elements of the types listed by the constructor.

The @racket[letter] argument must be a member of
@racketblock[
(list 'C 'C# 'C#/Db 'Db 'D  'D#  'D#/Eb 'Eb 
      'E 'F 'F# 'F#/Gb 'Gb 'G 'G# 'G#/Ab 'Ab 
      'A 'A# 'A#/Bb 'Bb 'B 'Rest)]

The @racket[octave] argument must be an @racket[integer] between -1 and 7, to be compatible with the midi standard.

The @racket[duration] argument must be a @racket[beat-value-procedure?] which takes an @racket[exact-positive-integer?] representing the tempo and returns a @racket[beat-value]. The @racket[rsound/composer] module provides many of these procedures built-in, such as @racket[whole-note], @racket[half-note], @racket[quarter-note], @racket[eighth-note], and more.  The @racket[beat-value] type will be discussed in more detail later.
}

@defproc[(play-note [n note?]
                    [#:instrument instr instrument? (main-synth-instrument 7)]
                    [#:tempo tempo exact-positive-integer? 120]) 
                    exact-positive-integer?]{
Will play a note and return the length of the note in frames. You can use keywords to specify the synthesizer @racket[instrument] and tempo (in beats per minute) to play the note with.}

@defproc[(note? [n any/c]) boolean?]
@defproc[(note-letter [n note?]) symbol?]
@defproc[(note-octave [n note?]) integer?]
@defproc[(note-duration [n note?]) beat-value-procedure?]

@defproc[(make-note-from-midi-num [midi-number exact-positive-integer?]
                                  [duration beat-value-procedure?]) note?]
@defproc[(note-midi-number [n non-rest-note?]) note?]

@defproc[(note-freq [n note?]) exact-nonnegative-integer?]

@defproc[(note-interval-up [n note?][interval symbol?]) note?]
@defproc[(note-interval-down [n note?][interval symbol?]) note?]

@section{Rests}
A @racket[rest?] is an instance of type @racket[note] which produces silence for the given @racket[beat-value].

@defproc[(make-rest [duration beat-value-procedure?]) rest?]
@defproc[(rest? [n any/c]) boolean?]
@defproc[(non-rest-note? [n any/c]) boolean?]
@defproc[(whole-rest) rest?]
@defproc[(half-rest) rest?]
@defproc[(quarter-rest) rest?]
@defproc[(eighth-rest) rest?]
@defproc[(sixteenth-rest) rest?]
@defproc[(thirtysecond-rest) rest?]

@defproc[(dotted-whole-rest) rest?]
@defproc[(dotted-half-rest) rest?]
@defproc[(dotted-quarter-rest) rest?]
@defproc[(dotted-eighth-rest) rest?]
@defproc[(dotted-sixteenth-rest) rest?]

@defproc[(double-dotted-whole-rest) rest?]
@defproc[(double-dotted-half-rest) rest?]
@defproc[(double-dotted-quarter-rest) rest?]
@defproc[(double-dotted-eighth-rest) rest?]

@section{Beat Values}

@defstruct[beat-value ([name symbol?]
                      [beat-value-proc beat-value-procedure?])]

@defproc[(beat-value-procedure? [beat-value-proc any/c]) boolean?]
@defproc[(bpm-to-frames [tempo exact-positive-integer?]) exact-non-negative-intager?]

@defproc[(whole-note [tempo exact-positive-integer?]) beat-value?]
@defproc[(half-note [tempo exact-positive-integer?]) beat-value?]
@defproc[(quarter-note [tempo exact-positive-integer?]) beat-value?]
@defproc[(eighth-note [tempo exact-positive-integer?]) beat-value?]
@defproc[(sixteenth-note [tempo exact-positive-integer?]) beat-value?]
@defproc[(thirtysecond-note [tempo exact-positive-integer?]) beat-value?]

@defproc[(dotted-whole-note [tempo exact-positive-integer?]) beat-value?]
@defproc[(dotted-half-note [tempo exact-positive-integer?]) beat-value?]
@defproc[(dotted-quarter-note [tempo exact-positive-integer?]) beat-value?]
@defproc[(dotted-eighth-note [tempo exact-positive-integer?]) beat-value?]
@defproc[(dotted-sixteenth-note [tempo exact-positive-integer?]) beat-value?]

@defproc[(double-dotted-whole-note [tempo exact-positive-integer?]) beat-value?]
@defproc[(double-dotted-half-note [tempo exact-positive-integer?]) beat-value?]
@defproc[(double-dotted-quarter-note [tempo exact-positive-integer?]) beat-value?]
@defproc[(double-dotted-eighth-note [tempo exact-positive-integer?]) beat-value?]
@defproc[(subdivision [base-length-proc beat-value-procedure?]
                      [subdiv exact-positive-integer?]) beat-value-procedure?]
@defproc[(beat-value->fraction [beat-value-proc beat-value-procedure?]) rational?]

@section{Synthesizer Instruments}

@defstruct[instrument ([name string?] [conversion-proc procedure?])]
@defproc[(vgame-synth-instrument [spec exact-positive-integer?]) instrument?]
@defproc[(main-synth-instrument [spec exact-positive-integer?]) instrument?]
@defproc[(path-synth-instrument [spec exact-positive-integer?]) instrument?]

@section{Measures}

@defstruct[struct-measure ([struct-measure-notes list?])]
@defproc[(measure [n note?] ...) struct-measure?]
@defproc[(measure? [m any/c]) boolean?]
@defproc[(measure-notes [m struct-measure?]) list?]
@defproc[(measure-is-valid? [m measure?] [ts time-signature?]) boolean?]
@defproc[(measure-frames [m measure?]) exact-nonnegative-integer?]


@section{Instrument Parts}

@defstruct[struct-instrument-part ([instrument any/c] 
                                  [measure-list (listof? measure?)])]
@defproc[(instrument-part [instrument any/c] [m measure?] ...) struct-instrument-part?]
@defproc[(instrument-part? [i any/c]) boolean?]
@defproc[(instr-part-instrument [i instrument-part?]) any/c]
@defproc[(instr-part-measure-list [i instrument-part?]) (listof? measure?)]

@defproc[(instr-part-is-valid? [i instrument-part?] 
                               [ts time-signature?])
                               boolean?]

@section{Score Sections}

@section{Scores}

@section{Other Utilities}
