#lang racket

(require "../composer.rkt")

(define sect
    (section
      (time-signature 4 4) 
      #:assert-time-sig #t
      (key-signature "") 
      #:tempo 180
      (instrument-part
        [vgame-synth-instrument 4]
        (measure
          (note 'G  3 null-beat)
          (note 'G  3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'Bb 3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'G  3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'Bb 3 eighth-beat)
          (note 'D  4 eighth-beat))
        (measure
          (note 'G  3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'Bb 3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'G  3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'Bb 3 eighth-beat)
          (note 'D  4 eighth-beat))
        (measure
          (note 'G  3 eighth-beat)
          (note 'Eb 4 eighth-beat)
          (note 'C  4 eighth-beat)
          (note 'Eb 4 eighth-beat)
          (note 'G  3 eighth-beat)
          (note 'Eb 4 eighth-beat)
          (note 'C  4 eighth-beat)
          (note 'Eb 4 eighth-beat))
        (measure
          (note 'G  3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'Bb 3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'G  3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'Bb 3 eighth-beat)
          (note 'D  4 eighth-beat))
        (measure
          (note 'G  3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'Bb 3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'G  3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'Bb 3 eighth-beat)
          (note 'D  4 eighth-beat))
        (measure
          (note 'G  3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'Bb 3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'G  3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'Bb 3 eighth-beat)
          (note 'D  4 eighth-beat))
        (measure
          (note 'G  3 eighth-beat)
          (note 'Eb 4 eighth-beat)
          (note 'C  4 eighth-beat)
          (note 'Eb 4 eighth-beat)
          (note 'G  3 eighth-beat)
          (note 'Eb 4 eighth-beat)
          (note 'C  4 eighth-beat)
          (note 'Eb 4 eighth-beat))
        (measure
          (note 'G  3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'Bb 3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'G  3 eighth-beat)
          (note 'D  4 eighth-beat)
          (note 'Bb 3 eighth-beat)
          (note 'D  4 eighth-beat)))
      (instrument-part
        [vgame-synth-instrument 4]
        (measure
          (note 'D  5 eighth-beat)
          (eighth-rest)
          (note 'D  5 eighth-beat)
          (eighth-rest)
          (note 'D  5 eighth-beat)
          (note 'Bb 4 eighth-beat)
          (note 'G  4 eighth-beat)
          (note 'Bb 4 eighth-beat))
        (measure
          (eighth-rest)
          (note 'D  5 dotted-quarter-beat)
          (note 'D  5 quarter-beat)
          (note 'C  5 eighth-beat)
          (note 'Bb 4 eighth-beat))
        (measure
          (note 'C  5 eighth-beat)
          (eighth-rest)
          (note 'C  5 eighth-beat)
          (note 'D  5 eighth-beat)
          (note 'C  5 eighth-beat)
          (note 'Bb  4 eighth-beat)
          (note 'A  4 eighth-beat)
          (note 'C  5 eighth-beat))
        (measure
          (eighth-rest)
          (note 'Bb 4 quarter-beat)
          (note 'A  4 eighth-beat)
          (note 'G  4 eighth-beat)
          (note 'D 4 eighth-beat)
          (note 'G 4 eighth-beat)
          (note 'Bb 4 eighth-beat))
        (measure
          (note 'D  5 eighth-beat)
          (eighth-rest)
          (note 'D  5 eighth-beat)
          (eighth-rest)
          (note 'D  5 eighth-beat)
          (note 'Bb 4 eighth-beat)
          (note 'G  4 eighth-beat)
          (note 'Bb 4 eighth-beat))
        (measure
          (eighth-rest)
          (note 'D  5 dotted-quarter-beat)
          (note 'D  5 quarter-beat)
          (note 'C  5 eighth-beat)
          (note 'Bb 4 eighth-beat))
        (measure
          (note 'C  5 eighth-beat)
          (eighth-rest)
          (note 'C  5 eighth-beat)
          (note 'D  5 eighth-beat)
          (note 'C  5 eighth-beat)
          (note 'Bb  4 eighth-beat)
          (note 'A  4 eighth-beat)
          (note 'F#  4 eighth-beat))
        (measure
          (note 'G 4 half-beat)
          (eighth-rest)
          (note 'D 4 eighth-beat)
          (note 'G 4 eighth-beat)
          (note 'Bb 4 eighth-beat)))))

(define scr
  (score
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect
    sect))

(play-score scr)
(display "ctl-D to quit")
(read)

