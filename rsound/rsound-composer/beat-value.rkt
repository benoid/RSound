#lang racket

(provide (except-out (all-defined-out)
                     dotted
                     double-dotted))

(struct beat-value [name frames]
  #:guard (lambda (n f me)
            (if (and (symbol? n) (integer? f) (positive? f))
              (values n f)
              (error "<#struct:beat-value> invalid arguments: " n f))))


(define/contract 
  (beat-value-procedure? beat-value-proc)
  (-> any/c boolean?)               
  (if (and (procedure? beat-value-proc)
           (= (procedure-arity beat-value-proc) 1))
    (let ([bv (beat-value-proc 1)])
      (if (beat-value? bv) #t #f))
    #f))

(define/contract 
  (bpm-to-frames tempo)
  (-> exact-positive-integer? exact-nonnegative-integer?)
  (if (= tempo 0) 0 (round (* (/ 60 tempo) 44100))))

(define/contract 
  (null-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (beat-value 'NullBeat 0))

(define/contract 
  (whole-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (beat-value 
    'WholeBeat 
    (* (bpm-to-frames tempo) 4)))

(define/contract 
  (half-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (beat-value 
    'HalfBeat 
    (* (bpm-to-frames tempo) 2)))

(define/contract 
  (quarter-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (beat-value 
    'QuarterBeat 
    (bpm-to-frames tempo)))

(define/contract 
  (eighth-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (beat-value 
    'EighthBeat 
    (round (* (bpm-to-frames tempo) 0.5))))

(define/contract 
  (sixteenth-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (beat-value 
    'SixteenthBeat 
    (round (* (bpm-to-frames tempo) 0.25))))

(define/contract 
  (thirtysecond-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (beat-value 
    'ThirtysecondBeat 
    (round (* (bpm-to-frames tempo) 0.125))))

(define/contract 
  (dotted bv)
  (-> beat-value? beat-value?)
  (beat-value
    (string->symbol 
      (string-join 
        (list "Dotted" (symbol->string (beat-value-name bv)))""))
    (round (* (beat-value-frames bv) 1.5))))

(define/contract 
  (double-dotted bv)
  (-> beat-value? beat-value?)
  (beat-value
    (string->symbol 
      (string-join 
        (list "DoubleDotted" (symbol->string (beat-value-name bv)))""))
    (round (* (beat-value-frames bv) 1.75))))

;; Needs test
(define/contract 
  (subdivision base-length-proc subdivision)
  (-> beat-value-procedure? exact-positive-integer? beat-value-procedure?)
  (lambda (tempo)
    (let ([base-length (base-length-proc tempo)])
      (beat-value
        (string->symbol
          (string-join
            (list
              "Subdivision" 
              (number->string subdivision)
              (symbol->string (beat-value-name base-length)))))
        (round (/ (beat-value-frames base-length) subdivision ))))))


(define/contract 
  (dotted-whole-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (dotted (whole-beat tempo)))

(define/contract 
  (dotted-half-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (dotted (half-beat tempo)))

(define/contract 
  (dotted-quarter-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (dotted (quarter-beat tempo)))

(define/contract 
  (dotted-eighth-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (dotted (eighth-beat tempo)))

(define/contract 
  (dotted-sixteenth-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (dotted (sixteenth-beat tempo)))

(define/contract 
  (dotted-thirtysecond-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (dotted (thirtysecond-beat tempo)))

(define/contract
  (double-dotted-whole-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (double-dotted (whole-beat tempo)))

(define/contract
  (double-dotted-half-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (double-dotted (half-beat tempo)))

(define/contract
  (double-dotted-quarter-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (double-dotted (quarter-beat tempo)))

(define/contract
  (double-dotted-eighth-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (double-dotted (eighth-beat tempo)))

(define/contract
  (double-dotted-sixteenth-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (double-dotted (sixteenth-beat tempo)))

(define/contract
  (double-dotted-thirtysecond-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (double-dotted (thirtysecond-beat tempo)))

;; Update test to include subdivision
(define/contract
  (beat-value->fraction bv)
  (-> beat-value? rational?)
  (cond 
    ((eq? (beat-value-name bv) 'NullBeat) 0)
    ((eq? (beat-value-name bv) 'WholeBeat) 1)
    ((eq? (beat-value-name bv) 'HalfBeat) 1/2)
    ((eq? (beat-value-name bv) 'QuarterBeat) 1/4)
    ((eq? (beat-value-name bv) 'EighthBeat) 1/8)
    ((eq? (beat-value-name bv) 'SixteenthBeat) 1/16)
    ((eq? (beat-value-name bv) 'ThirtysecondBeat) 1/32)

    ((eq? (beat-value-name bv) 'DottedWholeBeat) 3/2)
    ((eq? (beat-value-name bv) 'DottedHalfBeat) 3/4)
    ((eq? (beat-value-name bv) 'DottedQuarterBeat) 3/8)
    ((eq? (beat-value-name bv) 'DottedEighthBeat) 3/16)
    ((eq? (beat-value-name bv) 'DottedSixteenthBeat) 3/32)

    ((eq? (beat-value-name bv) 'DoubleDottedWholeBeat) 7/4)
    ((eq? (beat-value-name bv) 'DoubleDottedHalfBeat) 7/8)
    ((eq? (beat-value-name bv) 'DoubleDottedQuarterBeat) 7/16)
    ((eq? (beat-value-name bv) 'DoubleDottedEighthBeat) 7/32)
    ((string=? 
       (substring (symbol->string (beat-value-name bv)) 0 11)
       "Subdivision")
     (let* ([beat-value-name-str 
              (symbol->string (beat-value-name bv))]
            [subdivision 
              (string->number 
                (list-ref 
                  (string-split beat-value-name-str " ") 1))]
            [base-length-symbol
              (string->symbol
                (string-trim 
                  (string-trim 
                    beat-value-name-str 
                    "Subdivision " #:right? #f)
                  (string-append (number->string subdivision) " ") 
                  #:right? #f))])
       (/ (beat-value->fraction 
            (beat-value base-length-symbol 1)) subdivision)))
    (else (error "invalid note length: " (beat-value-name bv)))))


#;(module+ composer-test-suite

  (require rackunit
           rackunit/text-ui
           "../beat-value.rkt")

  (provide beat-value-tests)

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
                ((subdivision nl i) 1)))))))))



