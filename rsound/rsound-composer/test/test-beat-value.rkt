#lang racket

(require rackunit
         rackunit/text-ui
         "../beat-value.rkt")

(define tempo-list (for/list ([i (in-range 4 21)]) (* i 10)))

(define beat-value-tests
  (test-suite
    "beat-value-tests"
    (test-case
      "bpm-to-frames converts bpm to frames"
      (let ([freq-list (list 66150 
                             52920 
                             44100 
                             37800 
                             33075 
                             29400 
                             26460 
                             24055 
                             22050 
                             20354 
                             18900 
                             17640 
                             16538 
                             15565 
                             14700 
                             13926 
                             13230)])
        (check = (length tempo-list) (length freq-list))
        (for ([t tempo-list]
              [f freq-list])
             (check-equal? (bpm-to-frames t) f "could not convert bpm to frames")
             (check-equal? (beat-value-frames (whole-beat t)) 
                           (* (bpm-to-frames t) 4)
                           "create whole note failed: frames") 
             (check-equal? (beat-value-frames (half-beat t)) 
                           (* (bpm-to-frames t) 2)
                           "create half-beat failed: frames") 
             (check-equal? (beat-value-frames (quarter-beat t)) 
                           (bpm-to-frames t)
                           "create quarter note failed: frames") 
             (check-equal? (beat-value-frames (eighth-beat t)) 
                           (round (* (bpm-to-frames t) 0.5))
                           "create eighth note failed: frames")
             (check-equal? (beat-value-frames (sixteenth-beat t)) 
                           (round (* (bpm-to-frames t) 0.25))
                           "create sixteenth note failed: frames")
             (check-equal? (beat-value-frames (thirtysecond-beat t)) 
                           (round (* (bpm-to-frames t) 0.125))
                           "create thirtysecond note failed: frames")
             (check-equal? (beat-value-frames 
                             (dotted-quarter-beat t)) 
                           (round (* (bpm-to-frames t) 1.5))
                           "create dotted quarter note failed: frames")
             (check-equal? (beat-value-frames 
                             (double-dotted-quarter-beat t)) 
                           (round (* (bpm-to-frames t) 1.75))
                           "create double dotted quarter note failed: frames")
             (check-equal? (beat-value-name
                             (whole-beat t)) 
                             'WholeBeat
                           "create whole note failed: name")
             (check-equal? (beat-value-name
                             (quarter-beat t)) 
                             'QuarterBeat
                           "create: quarter note failed: name")
             (check-equal? (beat-value-name
                             (eighth-beat t)) 
                             'EighthBeat
                           "create: eighth note failed: name")
             (check-equal? (beat-value-name
                             (sixteenth-beat t)) 
                             'SixteenthBeat
                           "create: sixteenth note failed: name")
             (check-equal? (beat-value-name
                             (thirtysecond-beat t)) 
                             'ThirtysecondBeat
                           "create: thirtysecond note failed: name")
             (check-equal? (beat-value-name
                             (dotted-quarter-beat t)) 
                             'DottedQuarterBeat
                           "create dotted quarter note failed: name")
             (check-equal? (beat-value-name
                             (double-dotted-quarter-beat t)) 
                             'DoubleDottedQuarterBeat
                           "create double dotted quarter note failed: name")
             )))
    (test-case
      "test beat-value->fraction"
      (check-equal? (beat-value->fraction (whole-beat 1)) 1)
      (check-equal? (beat-value->fraction (half-beat 1)) 1/2)
      (check-equal? (beat-value->fraction (quarter-beat 1)) 1/4)
      (check-equal? (beat-value->fraction (eighth-beat 1)) 1/8)
      (check-equal? (beat-value->fraction (sixteenth-beat 1)) 1/16)
      (check-equal? (beat-value->fraction (thirtysecond-beat 1)) 1/32)

      (check-equal? (beat-value->fraction (dotted-whole-beat 1)) 3/2)
      (check-equal? (beat-value->fraction (dotted-half-beat 1)) 3/4)
      (check-equal? (beat-value->fraction (dotted-quarter-beat 1)) 3/8)
      (check-equal? (beat-value->fraction (dotted-eighth-beat 1)) 3/16)
      (check-equal? (beat-value->fraction (dotted-sixteenth-beat 1)) 3/32)

      (check-equal? (beat-value->fraction (double-dotted-whole-beat 1)) 7/4)
      (check-equal? (beat-value->fraction (double-dotted-half-beat 1)) 7/8)
      (check-equal? (beat-value->fraction (double-dotted-quarter-beat 1)) 7/16)
      (check-equal? (beat-value->fraction (double-dotted-eighth-beat 1)) 7/32)
      )
    (test-case
      "test subdivision"
      (let ([beat-value-list
              (list 
                    whole-beat
                    half-beat
                    quarter-beat
                    eighth-beat
                    sixteenth-beat

                    dotted-whole-beat
                    dotted-half-beat
                    dotted-quarter-beat
                    dotted-eighth-beat
                    dotted-sixteenth-beat

                    double-dotted-whole-beat
                    double-dotted-half-beat
                    double-dotted-quarter-beat
                    double-dotted-eighth-beat)])
        (for* ([nl beat-value-list]
               [i (in-range 3 13)])
          (check-equal?
            (/ (beat-value->fraction (nl 1)) i)
            (beat-value->fraction
              ((subdivision nl i) 1)))))

      )
    ))

(run-tests beat-value-tests)
       
