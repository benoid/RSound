#lang racket

(provide (except-out (all-defined-out)
                     dotted
                     double-dotted))

(struct beat-value [name frames]
  #:guard (lambda (n f me)
            (if (and (symbol? n) (integer? f) (positive? f))
              (values n f)
              (error "<#struct:beat-value> invalid arguments: " n f))))


(define/contract (beat-value-procedure? beat-value-proc)
  (-> any/c boolean?)               
  (if (and (procedure? beat-value-proc)
           (= (procedure-arity beat-value-proc) 1))
    (let ([bv (beat-value-proc 1)])
      (if (beat-value? bv) #t #f))
    #f))

(define/contract (bpm-to-frames tempo)
  (-> exact-positive-integer? exact-nonnegative-integer?)
  (if (= tempo 0) 0 (round (* (/ 60 tempo) 44100))))

(define/contract (null-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (beat-value 'NullBeat 0))

(define/contract (whole-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (beat-value 
    'WholeBeat 
    (* (bpm-to-frames tempo) 4)))

(define/contract (half-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (beat-value 
    'HalfBeat 
    (* (bpm-to-frames tempo) 2)))

(define/contract (quarter-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (beat-value 
    'QuarterBeat 
    (bpm-to-frames tempo)))

(define/contract (eighth-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (beat-value 
    'EighthBeat 
    (round (* (bpm-to-frames tempo) 0.5))))

(define/contract (sixteenth-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (beat-value 
    'SixteenthBeat 
    (round (* (bpm-to-frames tempo) 0.25))))

(define/contract (thirtysecond-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (beat-value 
    'ThirtysecondBeat 
    (round (* (bpm-to-frames tempo) 0.125))))

(define/contract (dotted bv)
  (-> beat-value? beat-value?)
  (beat-value
    (string->symbol 
      (string-join 
        (list "Dotted" (symbol->string (beat-value-name bv)))""))
    (round (* (beat-value-frames bv) 1.5))))

(define/contract (double-dotted bv)
  (-> beat-value? beat-value?)
  (beat-value
    (string->symbol 
      (string-join 
        (list "DoubleDotted" (symbol->string (beat-value-name bv)))""))
    (round (* (beat-value-frames bv) 1.75))))

;; Needs test
(define/contract (subdivision base-length-proc subdivision)
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


(define/contract (dotted-whole-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (dotted (whole-beat tempo)))
(define/contract (dotted-half-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (dotted (half-beat tempo)))
(define/contract (dotted-quarter-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (dotted (quarter-beat tempo)))
(define/contract (dotted-eighth-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (dotted (eighth-beat tempo)))
(define/contract (dotted-sixteenth-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (dotted (sixteenth-beat tempo)))
(define/contract (dotted-thirtysecond-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (dotted (thirtysecond-beat tempo)))

(define/contract (double-dotted-whole-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (double-dotted (whole-beat tempo)))
(define/contract (double-dotted-half-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (double-dotted (half-beat tempo)))
(define/contract (double-dotted-quarter-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (double-dotted (quarter-beat tempo)))
(define/contract (double-dotted-eighth-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (double-dotted (eighth-beat tempo)))
(define/contract (double-dotted-sixteenth-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (double-dotted (sixteenth-beat tempo)))
(define/contract (double-dotted-thirtysecond-beat tempo)
  (-> exact-positive-integer? beat-value?)
  (double-dotted (thirtysecond-beat tempo)))

;; Update test to include subdivision
(define/contract (beat-value->fraction bv)
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

        
