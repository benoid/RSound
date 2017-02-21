#lang racket

(require "beat-value.rkt"
         "harmony.rkt"
         "note.rkt")
(provide (all-defined-out))

;; Write test for guard
(struct time-signature [beats-per-measure
                        type-of-beat]
  #:guard (lambda (beats-per-measure
                    type-of-beat
                    name)
            (if (and (exact-positive-integer? beats-per-measure)
                     (exact-positive-integer? type-of-beat)
                     (or (= (modulo type-of-beat 2) 0)
                         (= type-of-beat 1)))
              (values beats-per-measure type-of-beat)
              (error "invalid arguments: expected arguments of type:
                   <exact-positive-intager> where
                   type-of-beat is 1 or is divisible by 2" ))))


(define (key-signature k) k)

; Score
(struct score-struct [section-list])
(define score? score-struct?)
(define score-section-list score-struct-section-list)
(define (score . sections)
  (score-struct sections))

; Section
(struct section-struct 
  [time-sig key-sig tempo instrument-line-list]
  #:guard
    (lambda (time-sig key-sig tempo instr-line-list name)
      (if (and (time-signature? time-sig)
               ;; No check for key signature type is intended
               (exact-positive-integer? tempo)
               (list? instr-line-list))
          (values time-sig key-sig tempo instr-line-list)
          (error "<#procedure:section-struct> invalid arguments"))))

;; Write test for guard
;; Make key-sig a keyword
(define (section time-sig 
                 #:assert-time-sig [assert-time-sig? #t] 
                 key-sig 
                 #:tempo [tempo 120]
                 . instrument-lines)
  (let ([new-section 
          (section-struct time-sig key-sig tempo instrument-lines)])
      (if (and assert-time-sig? 
               (not 
                 (andmap 
                   (lambda (ip)
                     (instr-line-is-valid? ip time-sig)) 
                   instrument-lines)))
        (let* ([invalid-measure-index-list
                (map
                  (lambda (ip)
                    (find-invalid-measure-indices ip time-sig))
                  instrument-lines)]
               [error-list
                 (filter
                   string?
                   (for/list ([instr-line instrument-lines]
                       [indices invalid-measure-index-list]
                       [i (in-range 0 (length instrument-lines))])
                     (if (null? indices) 
                       0
                       (string-append
                         "\tinstrument " 
                          (number->string i)
                          ": m. "
                          (apply 
                            string-append
                            (map
                              (lambda (x)
                                (string-append
                                  (number->string x) " "))
                              indices))
                          "\n"))))])
          (error
            (string-append "invalid measures: \n" 
                           (apply string-append error-list))))
    new-section)))


(define section-time-sig section-struct-time-sig)
(define section-key-sig section-struct-key-sig)
(define section-tempo section-struct-tempo)
(define section-instr-line-list section-struct-instrument-line-list)

(define (section-frames sect)
  (foldl 
    (lambda (len id)
      (max len id))
      0
      (map (lambda (instr-line)
             (instr-line-frames instr-line (section-tempo sect)))
             (section-instr-line-list sect))))

;; Instrument Part
(struct instrument-line-struct [instrument measure-list])
(define instrument-line? instrument-line-struct?)
(define instr-line-instrument instrument-line-struct-instrument)
(define instr-line-measure-list instrument-line-struct-measure-list)
(define (instrument-line instrument . measures)
  (instrument-line-struct instrument measures))

;; Needs test
(define (instr-line-is-valid? instr-line time-sig)
  (cond ((not (instrument-line? instr-line)) 
         (error 
           "expected argument 1 to be of type: <#instrument-line-struct>"))
        ((not (time-signature? time-sig))
         (error 
           "expected argument 2 to be of type: <#time-signature>"))
        (else 
          (andmap (lambda (m)
                    (measure-is-valid? m time-sig))
                  (instr-line-measure-list instr-line)))))
(define (instr-line-frames instr-line tempo)
  (foldl (lambda (meas total)
           (if (not (measure? meas))
             0
             (+ total (measure-frames meas tempo))))
         0
         (instr-line-measure-list instr-line)))

(define (find-invalid-measure-indices instr-line time-sig)
  (let ([measure-list (instr-line-measure-list instr-line)])
    (filter 
      number?
        (for/list ([meas measure-list]
                   [i (in-range 0 (length measure-list))])
          (if (measure-is-valid? meas time-sig)
          meas
          i)))))


(struct measure-struct [notes]
  #:guard (lambda (notes name)
            (if (list? notes)
              (values notes)
              (error "expected list"))))

(define measure? measure-struct?)
(define measure-notes measure-struct-notes)
(define (measure . notes)
  (measure-struct notes))

(define (measure-is-valid? meas time-sig)
  (cond ((not (measure? meas)) 
         (error "expected argument 1 to be of type: <#measure-struct>"))
        ((not (time-signature? time-sig))
         (error "expected argument 2 to be of type: <#time-signature>"))
        (else 
          (equal? 
            (foldl (lambda (n v)
                     (cond 
                       ((harmony? n)
                        (foldl 
                          (lambda (x y)
                            (max x y))
                          0
                          (map 
                            (lambda (x)
                              (beat-value->fraction ((note-duration x) 1)))
                            (harmony-notes n))))
                        ((not (note? n))
                          (error "expected list of type: <#note> | actual: " v ))
                        (else  
                          (+ (beat-value->fraction ((note-duration n) 1)) v))))
                   0
                   (measure-notes meas))
            (/ (time-signature-beats-per-measure time-sig) 
               (time-signature-type-of-beat time-sig))))))

(define (measure-frames meas tempo)
  (foldl
    (lambda (n total)
      (cond ((harmony? n)
             (+ total
                (foldl 
                  (lambda 
                    (x y)
                    (max x y))
                    0
                  (map
                    (lambda (x)
                      (beat-value-frames ((note-duration x) tempo))) 
                    (harmony-notes n)))))
            ((not (note? n))
             0)
             (else
               (+ total (beat-value-frames ((note-duration n) tempo))))))
    0
    (measure-notes meas)))


