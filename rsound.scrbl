#lang scribble/doc

@(require scribble/manual
          planet/scribble)

@title{@bold{RSound}: An Adequate Sound Engine for Racket}

@author[(author+email "John Clements" "clements@racket-lang.org")]

@(require (for-label racket
                     (this-package-in main)
                     (this-package-in frequency-response)))

@defmodule[(planet clements/rsound)]{This collection provides a means to represent, read,
write, play, and manipulate sounds. It uses the 'portaudio' library, which appears
to run on Linux, Mac, and Windows.

The package contains binary versions of the Mac & Windows portaudio libraries. This is
because Windows and Mac users are less likely to be able to install their own 
versions of the library; naturally, this is a less-than-perfect solution. In particular,
it appears that Windows users often get an error message about a missing DLL that can
be solved by installing a separate bundle... from Microsoft?

Sound playing happens on a separate racket thread and custodian. This means 
that re-running the program or interrupting with a "Kill" will not halt the 
sound. (Use @racket[(stop-playing)] for that.)

It represents all sounds internally as stereo 16-bit PCM, with all the attendant
advantages (speed, mostly) and disadvantages (clipping).

Does it work on your machine? Try this example (and accept my 
apologies if I forget to update the version number):
@racketblock[
 (require (planet "main.rkt" ("clements" "rsound.plt" 1 10)))
  
 (rsound-play ding)
 ]
}

A note about volume: be careful not to damage your hearing, please. To take a simple example,
the @racket[sine-wave] function generates a sine wave with amplitude 1.0.  That translates into
the @emph{loudest possible sine wave} that can be represented. So please set your volume low, 
and be careful with the headphones. Maybe there should be a parameter that controls the clipping 
volume. Hmm.

@section{Sound Control}

These procedures start and stop playing sounds and loops.

@defproc[(rsound-play (rsound rsound?)) void?]{
 Plays an rsound. Interrupts an already-playing sound, if there is one.}

@defproc[(rsound-loop (rsound rsound?)) void?]{
 Plays an rsound repeatedly.  Continues looping until interrupted by 
 another sound command.}

@defproc[(change-loop (rsound rsound?)) void?]{
 When the current sound or loop finishes, starts looping this one instead.}

@defproc[(stop-playing) void]{
 Stop the currently playing sound.}

@section{Sound I/O}

These procedures read and write rsounds from/to disk.

The RSound library reads and writes WAV files only; this means fewer FFI dependencies
(the reading & writing is done in racket), and works on all platforms. 

@defproc[(rsound-read (path path-string?)) rsound?]{
 Reads a WAV file from the given path, returns it as an rsound.
 
 It currently
has lots of restrictions (it insists on 16-bit PCM encoding, for instance), but deals 
with a number of common bizarre conventions that certain WAV files have (PAD chunks,
extra blank bytes at the end of the fmt chunk, etc.), and tries to fail
relatively gracefully on files it can't handle.

Reading in a large sound can result in a very large value (~10 Megabytes per minute);
for larger sounds, consider reading in only a part of the file, using @racket[rsound-read/clip].}

@defproc[(rsound-read/clip (path path-string?) (start nonnegative-integer?) (finish nonnegative-integer?)) rsound?]{
 Reads a portion of a WAV file from a given path, starting at frame @racket[start]  and ending at frame @racket[finish].
                                                                    
 It currently
has lots of restrictions (it insists on 16-bit PCM encoding, for instance), but deals 
with a number of common bizarre conventions that certain WAV files have (PAD chunks,
extra blank bytes at the end of the fmt chunk, etc.), and tries to fail
relatively gracefully on files it can't handle.}

@defproc[(read-rsound-frames (path path-string?)) nonnegative-integer?]{
 Returns the number of frames in the sound indicated by the path. It parses
 the header only, and is therefore much faster than reading in the whole sound.
 
 The file must be encoded as a WAV file readable with @racket[rsound-read].}

@defproc[(read-rsound-sample-rate (path path-string?)) number?]{
 Returns the sample-rate of the sound indicated by the path. It parses
 the header only, and is therefore much faster than reading in the whole sound.
 
  The file must be encoded as a WAV file readable with @racket[rsound-read].}


@defproc[(rsound-write (rsound rsound?) (path path-string?)) void?]{
 Writes an rsound to a WAV file, using stereo 16-bit PCM encoding. It
 overwrites an existing file at the given path, if one exists.}

@section{Rsound Manipulation}

These procedures allow the creation, analysis, and manipulation of rsounds.

@defstruct[rsound ([data s16vector?] [frames nonnegative-integer?] [sample-rate nonnegative-number?])]{
 Represents a sound.}

@defproc[(rsound-equal? [sound1 rsound?] [sound2 rsound?]) boolean?]{
 Returns @racket[#true] when the two sounds are (extensionally) equal.
         
 This procedure is necessary because s16vectors don't natively support @racket[equal?].}

@defproc[(make-silence [frames nonnegative-integer?] [sample-rate nonnegative-number?]) rsound?]{
 Returns an rsound of length @racket[frames] containing silence.  This procedure is relatively fast.}

@defproc[(rsound-ith/left (rsound rsound?) (frame nonnegative-integer?)) nonnegative-integer?]{
 Returns the @racket[n]th sample from the left channel of the rsound, represented as a number in the range @racket[-1.0]
 to @racket[1.0].}

@defproc[(rsound-ith/right (rsound rsound?) (frame nonnegative-integer?)) nonnegative-integer?]{
 Returns the @racket[n]th sample from the right channel of the rsound, represented as a number in the range @racket[-1.0]
 to @racket[1.0].}

@defproc[(rsound-clip (rsound rsound?) (start nonnegative-integer?) (finish nonnegative-integer?)) rsound?]{
 Returns a new rsound containing the frames in @racket[rsound] from the @racket[start]th to the @racket[finish]th - 1.
 This procedure copies the required portion of the sound.}

@defproc[(rsound-append* (rsounds (listof rsound?))) rsound?]{
 Returns a new rsound containing the given @racket[rsounds], appended sequentially. This procedure is relatively
 fast. All of the given rsounds must have the same sample-rate.}

@defproc[(rsound-overlay* (assembly-list (listof (list/c rsound? nonnegative-integer?)))) rsound?]{
 Returns a new rsound containing all of the given rsounds. Each sound begins at the frame number 
 indicated by its associated offset. The rsound will be exactly the length required to contain all of
 the given sounds.
 
 So, suppose we have two rsounds: one called 'a', of length 20000, and one called 'b', of length 10000.
 Evaluating
 
 @racketblock[
  (rsound-overlay* (list (list a 5000)
                         (list b 0)
                         (list b 11000)))]
 
 ... would produce a sound of 21000 frames, where each instance of 'b' overlaps with the central
 instance of 'a'.
 
 }

@defproc[(rsound-scale (scalar nonnegative-number?) (rsound rsound?)) rsound?]{
 Scale the given sound by multiplying all of its samples by the given scalar.}

@section{Signals}

A signal is a function mapping a frame number to a real number in the range @racket[-1.0] to @racket[1.0]. There
are several built-in functions that produce signals.

@defproc[(sine-wave [frequency nonnegative-number?] [sample-rate nonnegative-number?]) signal?]{
 Produces a signal representing a sine wave of the given
 frequency, of amplitude 1.0.}

@defproc[(sawtooth-wave [frequency nonnegative-number?] [sample-rate nonnegative-number?]) signal?]{
 Produces a signal representing a naive sawtooth wave of the given
 frequency, of amplitude 1.0. Note that since this is a simple -1.0 up to 1.0 sawtooth wave, it's got horrible 
 aliasing all over the spectrum.}

@defproc[(square-wave [frequency nonnegative-number?] [sample-rate nonnegative-number?]) signal?]{
 Produces a signal representing a naive square wave of the given
 frequency, of amplitude 1.0. Note that since this is a simple 1/-1 square wave, it's got horrible 
 aliasing all over the spectrum.}

@defproc[(dc-signal [amplitude real?]) signal?]{
 Produces a constant signal at @racket[amplitude]. Inaudible unless used to multiply by
 another signal.}

In order to listen to them, you'll need to transform them into rsounds:

@defproc[(signal->rsound (frames nonnegative-integer?) (sample-rate nonnegative-integer?) 
                           (signal signal?)) rsound?]{
 Builds a sound of length @racket[frames] and sample-rate @racket[sample-rate] by calling 
 @racket[signal] with integers from 0 up to @racket[frames]-1. The result should be an inexact 
 number in the range @racket[-1.0] to @racket[1.0]. Values outside this range are clipped.
 Both channels are identical. 
 
 Here's an example of using it:
 
 @racketblock[
(define samplerate 44100)
(define sr/inv (/ 1 samplerate))

(define (sig1 t)
  (* 0.1 (sin (* t 560 twopi sr/inv))))

(define r (signal->rsound (* samplerate 4) samplerate sig1))

(rsound-play r)]
 
 Alternatively, we could use @racket[sine-wave] to achieve the same result:
 
 @racketblock[
(define samplerate 44100)

(define r (signal->rsound (* samplerate 4) samplerate (rsound-scale 0.1 (sine-wave 560 samplerate))))

(rsound-play r)]}
                                                  
                                                  

@defproc[(signals->rsound/stereo (frames nonnegative-integer?) (sample-rate nonnegative-integer?) 
                             (left-fun signal?) (right-fun signal?)) rsound?]{
 Builds a stereo sound of length @racket[frames] and sample-rate @racket[sample-rate] by calling 
 @racket[left-fun] and @racket[right-fun] 
 with integers from 0 up to @racket[frames]-1. The result should be an inexact 
 number in the range @racket[-1.0] to @racket[1.0]. Values outside this range are clipped.}


@defproc[(fader [fade-samples number?]) signal?]{
 Produces a signal that decays exponentially. After @racket[fade-samples], its value is @racket[0.001].
 Inaudible unless used to multiply by another signal.}


@defproc[(signal [proc procedure?] [args (listof any/c)] ...) signal?]{
 Produces a signal whose values are computed by calling @racket[proc] with the current frame and the additional
 values @racket[args].
 
 So, for instance, if we defined the function @racket[flatline] as
 
 @racketblock[
 (define (flatline t l) 
   l)
 ]
 
 ... then @racket[(signal flatline 0.4)] would produce the same result as @racket[(dc-signal 0.4)].}


There are also a number of functions that combine existing signals, called "signal combinators":

@defproc[(signal-+s [signals (listof signal?)]) signal?]{
 Produces the signal that is the sum of the input signals.}

@defproc[(signal-*s [signals (listof signal?)]) signal?]{
 Produces the signal that is the product of the input signals.}

We can turn an rsound back into a signal, using rsound->signal:

@defproc[(rsound->signal/left [rsound rsound?]) signal?]{
 Produces the signal that corresponds to the rsound's left channel, followed by endless silence. Ah, endless silence.}


@defproc[(rsound->signal/right [rsound rsound?]) signal?]{
 Produces the signal that corresponds to the rsound's right channel, followed by endless silence. (The silence joke
 wouldn't be funny if I made it again.)}

@defproc[(thresh/signal [threshold real-number?] [signal signal?]) signal?]{
 Applies a threshold (see @racket[thresh], below) to a signal.}

@defproc[(clip&volume [volume real-number?] [signal signal?]) signal?]{
 Clips the @racket[signal] to a threshold of 1, then multiplies by the given @racket[volume].}

Where should these go?

@defproc[(thresh [threshold real-number?] [input real-number?]) real-number?]{
 Produces the number in the range @racket[(- threshold)] to @racket[threshold] that is 
 closest to @racket[input]. Put differently, it ``clips'' the input at the threshold.}

Finally, here's a predicate.  This could be a full-on contract, but I'm afraid of the 
overhead.

@defproc[(signal? [maybe-signal any/c]) boolean?]{
 Is the given value a signal? More precisely, is the given value a procedure whose
 arity includes 1?}

@section{Visualizing Rsounds}

@defmodule[(planet clements/rsound/draw)]

@defproc[(rsound-draw [rsound rsound?]
                      [#:title title string?]
                      [#:width width nonnegative-integer? 800]
                      [#:height height nonnegative-integer? 200])
         void?]{
 Displays a new window containing a visual representation of the sound as a waveform.}
               
@defproc[(rsound-fft-draw [rsound rsound?]
                          [#:zoom-freq zoom-freq nonnegative-real?]
                          [#:title title string?]
                          [#:width width nonnegative-integer? 800]
                          [#:height height nonnegative-integer? 200]) void?]{
 Draws an fft of the sound by breaking it into windows of 2048 samples and performing an
 FFT on each. Each fft is represented as a column of gray rectangles, where darker grays
 indicate more of the given frequency band.}
                                                                      
@defproc[(vector-pair-draw/magnitude [left (vectorof complex?)] [right (vectorof complex?)]
                                     [#:title title string?]
                                     [#:width width nonnegative-integer? 800]
                                     [#:height height nonnegative-integer? 200]) 
         void?]{
 Displays a new window containing a visual representation of the two vectors' magnitudes
 as a waveform. The lines connecting the dots are really somewhat inappropriate in the 
 frequency domain, but they aid visibility....}
               
@defproc[(vector-draw/real/imag [vec (vectorof complex?)]
                                [#:title title string?]
                                [#:width width nonnegative-integer? 800]
                                [#:height height nonnegative-integer? 200]) 
         void?]{
 Displays a new window containing a visual representation of the vector's real and imaginary
 parts as a waveform.}
               


@section{RSound Utilities}

@defproc[(make-harm3tone [frequency nonnegative-number?] [volume? nonnegative-number?] [frames nonnegative-integer?]
                         [sample-rate nonnegative-number?]) rsound?]{
 Produces an rsound containing a semi-percussive tone of the given frequency, frames, and volume.  The tone contains the first
 three harmonics of the specified frequency.  This function is memoized, so that subsequent calls with the same parameters 
 will return existing values, rather than recomputing them each time.}

@defproc[(rsound-fft/left [rsound rsound?]) (vectorof complex?)]{
 Produces the complex-valued vector that represents the fourier transform of the rsound's left channel.
 Since the FFT takes time N*log(N) in the size of the input, running this on rsounds with more than a
 few thousand frames is probably going to be slow, unless the number of frames is a power of 2.}

@defproc[(rsound-fft/right [rsound rsound?]) (vectorof complex?)]{
 Produces the complex-valued vector that represents the fourier transform of the rsound's right channel.
 Since the FFT takes time N*log(N) in the size of the input, running this on rsounds with more than a
 few thousand frames is probably going to be slow, unless the number of frames is a power of 2}

@defproc[(midi-note-num->pitch [note-num nonnegative-integer?]) number?]{
 Returns the frequency (in Hz) that corresponds to a given midi note number. Here's the top-secret formula: 
 440*2^((n-69)/12).}

@defproc[(fir-filter [delay-lines (listof (list/c nonnegative-exact-integer? real-number?))]) procedure?]{
 Given a list of delay times (in frames) and amplitudes for each, produces a function that maps signals
 to new signals where each frame is the sum of the current signal frame and the multiplied versions of 
 the delayed @emph{input} signals (that's what makes it FIR).
 
 So, for instance,
 
 @racketblock[(fir-filter (list (list 13 0.4) (list 4 0.1)))]
 
 ...would produce a filter that added the current frame to 4/10 of the input frame 13 frames ago and 1/10 of
 the input frame 4 frames ago.}

@defproc[(iir-filter [delay-lines (listof (list/c nonnegative-exact-integer? real-number?))]) procedure?]{
 Given a list of delay times (in frames) and amplitudes for each, produces a function that maps signals
 to new signals where each frame is the sum of the current signal frame and the multiplied versions of 
 the delayed @emph{output} signals (that's what makes it IIR).
 
 So, for instance,
 
 @racketblock[(iir-filter (list (list 13 0.4) (list 4 0.1)))]
 
 ...would produce a filter that added the current frame to 4/10 of the output frame 13 frames ago and 1/10 of
 the output frame 4 frames ago.}

@section{Frequency Response}

@defmodule[(planet clements/rsound/frequency-response)]{
 This module provides functions to allow the analysis of frequency response on filters specified
 either as transfer functions or as lists of poles and zeros. It assumes a sample rate of 44.1 Khz.

@defproc[(response-plot [poly procedure?] [dbrel real?] [min-freq real?] [max-freq real]) void?]{
 Plot the frequency response of a filter, given its transfer function (a function mapping reals to reals). 
 The @racket[dbrel] number
 indicates how many decibels up the "zero" line should be shifted. The graph starts at @racket[min-freq]
 Hz and goes up to @racket[max-freq] Hz.  Note that aliasing effects may affect the apparent height or
 depth of narrow spikes.
 
 Here's an example of calling this function on a 100-pole comb filter, showing the response from 10KHz
 to 11KHz:
 
 @racketblock[
 (response-plot (lambda (z)
                  (/ 1 (- 1 (* 0.95 (expt z -100)))))
                30 10000 11000)]}

@defproc[(poles&zeros->fun [poles (listof real?)] [zeros (listof real?)]) procedure?]{
 given a list of poles and zeros in the complex plane, generate the corresponding transfer
 function.
 
 Here's an example of calling this function as part of a call to response-plot, for a filter
 with three poles and two zeros, from 0 Hz up to the nyquist frequency, 22.05 KHz:
 
 @racketblock[
 (response-plot (poles&zeros->fun '(0.5 0.5+0.5i 0.5-0.5i) '(0+i 0-i))
                40 
                0
                22050)]
 }}


not-yet-documented: @racket[(provide twopi 
         make-tone
         make-squaretone
         ding
         make-ding
         split-in-4
         times
         vectors->rsound
         echo1
         fft-complex-forward
         fft-complex-inverse
         )]

@section{Reporting Bugs}

For Heaven's sake, report lots of bugs!