#lang racket

(require rackunit
         rackunit/text-ui
         "../note.rkt"
         "../beat-value.rkt")

(define (list-slice lst start end)
  (for/list ([i (in-range start end)])
    (list-ref lst i)))

(define notes
  (append* 
    (for/list ([i (in-range 0 8)])
      (list
        (note 'C     i quarter-beat)
        (note 'C#/Db i quarter-beat)
        (note 'D     i quarter-beat)
        (note 'D#/Eb i quarter-beat)
        (note 'E     i quarter-beat)
        (note 'F     i quarter-beat)
        (note 'F#/Gb i quarter-beat)
        (note 'G     i quarter-beat)
        (note 'G#/Ab i quarter-beat)
        (note 'A     i quarter-beat)
        (note 'A#/Bb i quarter-beat)
        (note 'B     i quarter-beat)))))

(define note-tests
  (test-suite
    "note tests"
    (test-case
      "test note guard"
        (let ([valid-letters 
                (list 'C 'C# 'C#/Db
                      'Db 'D  'D# 
                      'D#/Eb 'Rest
                      'Eb 'E 'F
                      'F# 'F#/Gb 'Gb
                      'G 'G# 'G#/Ab 
                      'Ab 'A 'A#
                      'A#/Bb 'Bb 'B)])
          ;; This will throw an error if the 
          ;; guard is broken
          (for ([v valid-letters])
            (note v 1 quarter-beat))
          (check-exn exn:fail? (lambda () (note 'Jb 2 eighth-beat)))
          (check-exn exn:fail? (lambda () (note 'D 50 eighth-beat)))
          (check-exn exn:fail? (lambda ()(note 'A 2 "hi there")))
          ))

    (test-case 
      "make-note-from-midi"
      (let ([midi-nums (for/list ([i (in-range 12 108)]) i)])
        (check = (length notes) (length midi-nums))
        (for ([n notes]
              [m midi-nums])
          (check-equal? 
            (note-letter 
              (make-note-from-midi-num m quarter-beat))
             (note-letter n )
             "could not make note from midi number: letter")
          (check-equal?
            (note-octave 
              (make-note-from-midi-num m quarter-beat))
             (note-octave n )
             "could not make note from midi number: octave"))))

    (test-case
      "note-interval-up"
      (let ([start 12]
            [end 36])
        (for ([n (list-slice notes start end)])
          (check-equal?
            (note-midi-number
              (note-interval-up n 'Unison))
              (note-midi-number n)
              "(note-interval-up 'Unison) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Unison))
              (note-midi-number n)
              "(note-interval-down 'Unison) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'AugmentedUnison))
            (+ (note-midi-number n) 1)
            "(note-interval-up 'AugmentedUnison) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'AugmentedUnison))
            (- (note-midi-number n) 1)
            "(note-interval-down 'AugmentedUnison) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'Minor2nd))
            (+ (note-midi-number n) 1)
            "(note-interval-up 'Minor2nd) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Minor2nd))
            (- (note-midi-number n) 1)
            "(note-interval-down 'Minor2nd) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'Major2nd))
            (+ (note-midi-number n) 2)
            "(note-interval-up 'Major2nd) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Major2nd))
            (- (note-midi-number n) 2)
            "(note-interval-down 'Major2nd) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'Augmented2nd))
            (+ (note-midi-number n) 3)
            "(note-interval-up 'Augmented2nd) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Augmented2nd))
            (- (note-midi-number n) 3)
            "(note-interval-down 'Augmented2nd) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'Minor3rd))
            (+ (note-midi-number n) 3)
            "(note-interval-up 'Minor3rd) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Minor3rd))
            (- (note-midi-number n) 3)
            "(note-interval-down 'Minor3rd) failed")


          (check-equal?
            (note-midi-number
              (note-interval-up n 'Major3rd))
            (+ (note-midi-number n) 4)
            "(note-interval-up 'Major3rd) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Major3rd))
            (- (note-midi-number n) 4)
            "(note-interval-down 'Major3rd) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'Perfect4th))
            (+ (note-midi-number n) 5)
            "(note-interval-up 'Perfect4th) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Perfect4th))
            (- (note-midi-number n) 5)
            "(note-interval-down 'Perfect4th) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'Augmented4th))
            (+ (note-midi-number n) 6)
            "(note-interval-up 'Augmented4th) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Augmented4th))
            (- (note-midi-number n) 6)
            "(note-interval-down 'Augmented4th) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'Diminished5th))
            (+ (note-midi-number n) 6)
            "(note-interval-up 'Diminished5th) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Diminished5th))
            (- (note-midi-number n) 6)
            "(note-interval-down 'Diminished5th) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'Perfect5th))
            (+ (note-midi-number n) 7)
            "(note-interval-up 'Perfect5th) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Perfect5th))
            (- (note-midi-number n) 7)
            "(note-interval-down 'Perfect5th) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'Augmented5th))
            (+ (note-midi-number n) 8)
            "(note-interval-up 'Augmented5th) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Augmented5th))
            (- (note-midi-number n) 8)
            "(note-interval-down 'Augmented5th) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'Minor6th))
            (+ (note-midi-number n) 8)
            "(note-interval-up 'Minor6th) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Minor6th))
            (- (note-midi-number n) 8)
            "(note-interval-down 'Minor6th) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'Major6th))
            (+ (note-midi-number n) 9)
            "(note-interval-up 'Major6th) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Major6th))
            (- (note-midi-number n) 9)
            "(note-interval-down 'Major6th) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'Minor7th))
            (+ (note-midi-number n) 10)
            "(note-interval-up 'Minor7th) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Minor7th))
            (- (note-midi-number n) 10)
            "(note-interval-down 'Minor7th) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'Major7th))
            (+ (note-midi-number n) 11)
            "(note-interval-up 'Major7th) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'Major7th))
            (- (note-midi-number n) 11)
            "(note-interval-down 'Major7th) failed")

          (check-equal?
            (note-midi-number
              (note-interval-up n 'PerfectOctave))
            (+ (note-midi-number n) 12)
            "(note-interval-up 'PerfectOctave) failed")
          (check-equal?
            (note-midi-number
              (note-interval-down n 'PerfectOctave))
            (- (note-midi-number n) 12)
            "(note-interval-down 'PerfectOctave) failed"))))
    ))
(run-tests note-tests)
