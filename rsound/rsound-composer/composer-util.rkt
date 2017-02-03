#lang racket
(provide (all-defined-out))

;; Take a procedure and call it x times
(define (do-x-times x proc )
  (cond ((< x 2) (proc))
        (else
         (do-x-times proc (- x 1)) 
         (proc))))

;; Take a note letter name and convert it
;; to its relative midi representation 0-11
(define (note-letter-to-base-number letter)
  (cond ((eq? letter 'C) 0)
        ((eq? letter 'C#) 1)
        ((eq? letter 'C#/Db) 1)
        ((eq? letter 'Db) 1)
        ((eq? letter 'D) 2)
        ((eq? letter 'D#) 3)
        ((eq? letter 'D#/Eb) 3)
        ((eq? letter 'Eb) 3)
        ((eq? letter 'E) 4)
        ((eq? letter 'F) 5)
        ((eq? letter 'F#) 6)
        ((eq? letter 'F#/Gb) 6)
        ((eq? letter 'Gb) 6)
        ((eq? letter 'G) 7)
        ((eq? letter 'G#) 8)
        ((eq? letter 'G#/Ab) 8)
        ((eq? letter 'Ab) 8)
        ((eq? letter 'A) 9)
        ((eq? letter 'A#) 10)
        ((eq? letter 'A#/Bb) 10)
        ((eq? letter 'Bb) 10)
        ((eq? letter 'B) 11)
        (else (error "#<note-letter-to-base-number>: invalid letter"))))

;; Take a relative midi-representation 0-11
;; and convert it to its letter name
(define (midi-number-letter number)
  (define num (remainder number 12))
  (cond ((eq? num 0) 'C)
        ((eq? num 1)'C#/Db)
        ((eq? num 2) 'D)
        ((eq? num 3)'D#/Eb)
        ((eq? num 4) 'E)
        ((eq? num 5) 'F)
        ((eq? num 6)'F#/Gb)
        ((eq? num 7) 'G)
        ((eq? num 8)'G#/Ab)
        ((eq? num 9) 'A)
        ((eq? num 10)'A#/Bb)
        ((eq? num 11) 'B)
        (else (error "#<midi-number-letter>: invalid number"))))

;; Get the octave of a midi number
(define (midi-number-octave num)
  (- (quotient num 12) 1))

;; Take a note and octave and convert it to
;; its exact midi number
(define (letter-and-octave-to-midi letter octave)
  (+ (* (+ octave 1) 12) (note-letter-to-base-number letter)))

;; This function is borrowed from rsound/util.rkt.
;; It is defined here for portability, to remove
;; rsound/util.rkt as a necessary
;; dependency for this file.  The racket-composer library
;; should remain modularized so it's features can be
;; used by programs which may not require audio playback
;; (eg. musical typesetting programs)
;; The function has been renamed to prevent conflicts 
;; with rsound
;; 
;; midi-note-num-to freq : number -> number
;; produces the freq that corresponds to a midi note number
(define (midi-note-num-to-freq note-num)
  (unless (real? note-num)
    (raise-type-error 'midi-note-num-to-freq "real" 0 note-num))
  (* 440 (expt 2 (/ (- note-num 69) 12))))

;; This function is borrowed from rsound/util.rkt.
;; It is defined here for portability, to remove
;; rsound/util.rkt as a necessary
;; dependency for this file.  The racket-composer library
;; should remain modularized so it's features can be
;; used by programs which may not require audio playback
;; (eg. musical typesetting programs)
;; The function has been renamed to prevent conflicts 
;; with rsound
;;
;; freq-to-midi-note-num : number -> number
;; produces the midi note number that corresponds to a freq
(define (freq-to-midi-note-num freq)
  (unless (real? freq)
    (raise-type-error 'freq-to-midi-note-num "real" 0 freq))
  (+ 69 (* 12 (/ (log (/ freq 440)) (log 2)))))

;; Get a note letter and octave and convert
;; it to a freq in Hz
;; Note: this function works correctly, but unit
;;       tests have not been created for it yet
(define (letter-and-octave-to-freq letter octave)
  (midi-note-num-to-freq (letter-and-octave-to-midi letter octave)))

;; Take a beat in frames and subdivide it into equal parts.
;; Return a list of the new subdivisions
;; Note: this function works correctly, but unit
;;       tests have not been created for it yet
(define (subdivide beat subdivision)
  (build-list subdivision (lambda (x) (round (/ beat subdivision)))))
