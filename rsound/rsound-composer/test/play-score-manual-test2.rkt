#lang racket

(require "../composer.rkt")

(define sect
    (section
      (time-signature 4 4) 
      #:assert-time-sig #t
      (key-signature "") 
      #:tempo 480
      (instrument-line
        [vgame-synth-instrument 4]
        (measure
          (eighth-note 'G  3)
          (eighth-note 'D  4)
          (eighth-note 'Bb 3)
          (eighth-note 'D  4)
          (eighth-note 'G  3)
          (eighth-note 'D  4)
          (eighth-note 'Bb 3)
          (eighth-note 'D  4))
        (measure
          (eighth-note 'G  3)
          (eighth-note 'D  4)
          (eighth-note 'Bb 3)
          (eighth-note 'D  4)
          (eighth-note 'G  3)
          (eighth-note 'D  4)
          (eighth-note 'Bb 3)
          (eighth-note 'D  4))
        (measure
          (eighth-note 'G  3)
          (eighth-note 'Eb 4)
          (eighth-note 'C  4)
          (eighth-note 'Eb 4)
          (eighth-note 'G  3)
          (eighth-note 'Eb 4)
          (eighth-note 'C  4)
          (eighth-note 'Eb 4))
        (measure
          (eighth-note 'G  3)
          (eighth-note 'D  4)
          (eighth-note 'Bb 3)
          (eighth-note 'D  4)
          (eighth-note 'G  3)
          (eighth-note 'D  4)
          (eighth-note 'Bb 3)
          (eighth-note 'D  4))
        (measure
          (eighth-note 'G  3)
          (eighth-note 'D  4)
          (eighth-note 'Bb 3)
          (eighth-note 'D  4)
          (eighth-note 'G  3)
          (eighth-note 'D  4)
          (eighth-note 'Bb 3)
          (eighth-note 'D  4))
        (measure
          (eighth-note 'G  3)
          (eighth-note 'D  4)
          (eighth-note 'Bb 3)
          (eighth-note 'D  4)
          (eighth-note 'G  3)
          (eighth-note 'D  4)
          (eighth-note 'Bb 3)
          (eighth-note 'D  4))
        (measure
          (eighth-note 'G  3)
          (eighth-note 'Eb 4)
          (eighth-note 'C  4)
          (eighth-note 'Eb 4)
          (eighth-note 'G  3)
          (eighth-note 'Eb 4)
          (eighth-note 'C  4)
          (eighth-note 'Eb 4))
        (measure
          (eighth-note 'G  3)
          (eighth-note 'D  4)
          (eighth-note 'Bb 3)
          (eighth-note 'D  4)
          (eighth-note 'G  3)
          (eighth-note 'D  4)
          (eighth-note 'Bb 3)
          (eighth-note 'D  4)))
      (instrument-line
        [vgame-synth-instrument 4]
        (measure
          (eighth-note 'D  5)
          (eighth-rest)
          (eighth-note 'D  5)
          (eighth-rest)
          (eighth-note 'D  5)
          (eighth-note 'Bb 4)
          (eighth-note 'G  4)
          (eighth-note 'Bb 4))
        (measure
          (eighth-rest)
          (dotted-quarter-note 'D  5)
          (quarter-note 'D  5)
          (eighth-note 'C  5)
          (eighth-note 'Bb 4))
        (measure
          (eighth-note 'C  5)
          (eighth-rest)
          (eighth-note 'C  5)
          (eighth-note 'D  5)
          (eighth-note 'C  5)
          (eighth-note 'Bb  4)
          (eighth-note 'A  4)
          (eighth-note 'C  5))
        (measure
          (eighth-rest)
          (quarter-note 'Bb 4)
          (eighth-note 'A  4)
          (eighth-note 'G  4)
          (eighth-note 'D 4)
          (eighth-note 'G 4)
          (eighth-note 'Bb 4))
        (measure
          (eighth-note 'D  5)
          (eighth-rest)
          (eighth-note 'D  5)
          (eighth-rest)
          (eighth-note 'D  5)
          (eighth-note 'Bb 4)
          (eighth-note 'G  4)
          (eighth-note 'Bb 4))
        (measure
          (eighth-rest)
          (dotted-quarter-note 'D  5)
          (quarter-note 'D  5)
          (eighth-note 'C  5)
          (eighth-note 'Bb 4))
        (measure
          (eighth-note 'C  5)
          (eighth-rest)
          (eighth-note 'C  5)
          (eighth-note 'D  5)
          (eighth-note 'C  5)
          (eighth-note 'Bb  4)
          (eighth-note 'A  4)
          (eighth-note 'F#  4))
        (measure
          (half-note 'G 4)
          (eighth-rest)
          (eighth-note 'D 4)
          (eighth-note 'G 4)
          (eighth-note 'Bb 4)))))


(define scr
  (score sect sect sect))
  
(pstream-loop-score default-pstream scr 0)

