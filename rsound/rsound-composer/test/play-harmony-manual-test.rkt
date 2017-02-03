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
          (harmony
            (whole-note 'C 5)
            (whole-note 'E 5)
            (whole-note 'G 5)
            (whole-note 'C 5)
            )))))

(define scr
  (score
    sect))

(play-score scr)
(display "ctl-D to quit")
(read)

