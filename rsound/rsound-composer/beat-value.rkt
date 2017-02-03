#lang racket
(require "define-argcheck.rkt")

(provide (except-out (all-defined-out)
                     dotted
                     double-dotted))

(struct beat-value [name frames])

(define (beat-value-procedure? beat-value-proc)
  (if (and (procedure? beat-value-proc)
           (= (procedure-arity beat-value-proc) 1))
    (let ([nl (beat-value-proc 1)])
      (if (beat-value? nl) #t #f))
    #f))

(define/argcheck (bpm-to-frames [tempo exact-positive-integer? "exact-positive-integer?"])
  (if (= tempo 0) 
    0
  (round (* (/ 60 tempo) 44100))))

(define/argcheck (null-beat [tempo exact-positive-integer? "exact-positive-integer?"])
  (beat-value 
    'NullBeat 
    0))

(define/argcheck (whole-beat [tempo exact-positive-integer? "exact-positive-integer?"])
  (beat-value 
    'WholeBeat 
    (* (bpm-to-frames tempo) 4)))

(define/argcheck (half-beat [tempo exact-positive-integer? "exact-positive-integer?"])
  (beat-value 
    'HalfBeat 
    (* (bpm-to-frames tempo) 2)))

(define/argcheck (quarter-beat [tempo exact-positive-integer? "exact-positive-integer?"])
  (beat-value 
    'QuarterBeat 
    (bpm-to-frames tempo)))

(define/argcheck (eighth-beat [tempo exact-positive-integer? "exact-positive-integer?"])
  (beat-value 
    'EighthBeat 
    (round (* (bpm-to-frames tempo) 0.5))))

(define/argcheck (sixteenth-beat [tempo exact-positive-integer? "exact-positive-integer?"])
  (beat-value 
    'SixteenthBeat 
    (round (* (bpm-to-frames tempo) 0.25))))

(define/argcheck (thirtysecond-beat [tempo exact-positive-integer? "exact-positive-integer?"])
  (beat-value 
    'ThirtysecondBeat 
    (round (* (bpm-to-frames tempo) 0.125))))

(define/argcheck (dotted [nl beat-value? "beat-value"])
  (beat-value
    (string->symbol 
      (string-join 
        (list "Dotted" (symbol->string (beat-value-name nl)))""))
    (round (* (beat-value-frames nl) 1.5))))

(define/argcheck (double-dotted [nl beat-value? "beat-value"])
  (beat-value
    (string->symbol 
      (string-join 
        (list "DoubleDotted" (symbol->string (beat-value-name nl)))""))
    (round (* (beat-value-frames nl) 1.75))))

;; Needs test
(define (subdivision base-length-proc subdivision)
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


(define (dotted-whole-beat tempo)
  (dotted (whole-beat tempo)))
(define (dotted-half-beat tempo)
  (dotted (half-beat tempo)))
(define (dotted-quarter-beat tempo)
  (dotted (quarter-beat tempo)))
(define (dotted-eighth-beat tempo)
  (dotted (eighth-beat tempo)))
(define (dotted-sixteenth-beat tempo)
  (dotted (sixteenth-beat tempo)))
(define (dotted-thirtysecond-beat tempo)
  (dotted (thirtysecond-beat tempo)))

(define (double-dotted-whole-beat tempo)
  (double-dotted (whole-beat tempo)))
(define (double-dotted-half-beat tempo)
  (double-dotted (half-beat tempo)))
(define (double-dotted-quarter-beat tempo)
  (double-dotted (quarter-beat tempo)))
(define (double-dotted-eighth-beat tempo)
  (double-dotted (eighth-beat tempo)))
(define (double-dotted-sixteenth-beat tempo)
  (double-dotted (sixteenth-beat tempo)))
(define (double-dotted-thirtysecond-beat tempo)
  (double-dotted (thirtysecond-beat tempo)))

;; Update test to include subdivision
(define/argcheck (beat-value->fraction
                   [nl beat-value? "beat-value"])
  (cond 
        ((eq? (beat-value-name nl) 'NullBeat) 0)
        ((eq? (beat-value-name nl) 'WholeBeat) 1)
        ((eq? (beat-value-name nl) 'HalfBeat) 1/2)
        ((eq? (beat-value-name nl) 'QuarterBeat) 1/4)
        ((eq? (beat-value-name nl) 'EighthBeat) 1/8)
        ((eq? (beat-value-name nl) 'SixteenthBeat) 1/16)
        ((eq? (beat-value-name nl) 'ThirtysecondBeat) 1/32)

        ((eq? (beat-value-name nl) 'DottedWholeBeat) 3/2)
        ((eq? (beat-value-name nl) 'DottedHalfBeat) 3/4)
        ((eq? (beat-value-name nl) 'DottedQuarterBeat) 3/8)
        ((eq? (beat-value-name nl) 'DottedEighthBeat) 3/16)
        ((eq? (beat-value-name nl) 'DottedSixteenthBeat) 3/32)

        ((eq? (beat-value-name nl) 'DoubleDottedWholeBeat) 7/4)
        ((eq? (beat-value-name nl) 'DoubleDottedHalfBeat) 7/8)
        ((eq? (beat-value-name nl) 'DoubleDottedQuarterBeat) 7/16)
        ((eq? (beat-value-name nl) 'DoubleDottedEighthBeat) 7/32)
        ((string=? 
           (substring (symbol->string (beat-value-name nl)) 0 11)
           "Subdivision")
         (let* ([beat-value-name-str 
                  (symbol->string (beat-value-name nl))]
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

        (else (error "invalid note length: " (beat-value-name nl)))))

        
