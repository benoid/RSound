#lang racket

(require "define-argcheck.rkt"
         "beat-value.rkt"
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
(struct struct-score [section-list])
(define score? struct-score?)
(define score-section-list struct-score-section-list)
(define (score . sections)
  (struct-score sections))

; Section
(struct struct-section 
  [time-sig key-sig tempo instrument-part-list]
  #:guard
    (lambda (time-sig key-sig tempo instr-part-list name)
      (if (and (time-signature? time-sig)
               ;; No check for key signature type is intended
               (exact-positive-integer? tempo)
               (list? instr-part-list))
          (values time-sig key-sig tempo instr-part-list)
          (error "<#procedure:struct-section> invalid arguments"))))

;; Write test for guard
;; Make key-sig a keyword
(define (section time-sig 
                 #:assert-time-sig [assert-time-sig? #t] 
                 key-sig 
                 #:tempo [tempo 120]
                 . instrument-parts)
  (let ([new-section 
          (struct-section time-sig key-sig tempo instrument-parts)])
      (if (and assert-time-sig? 
               (not 
                 (andmap 
                   (lambda (ip)
                     (instr-part-is-valid? ip time-sig)) 
                   instrument-parts)))
        (let* ([invalid-measure-index-list
                (map
                  (lambda (ip)
                    (find-invalid-measure-indices ip time-sig))
                  instrument-parts)]
               [error-list
                 (filter
                   string?
                   (for/list ([instr-part instrument-parts]
                       [indices invalid-measure-index-list]
                       [i (in-range 0 (length instrument-parts))])
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


(define section-time-sig struct-section-time-sig)
(define section-key-sig struct-section-key-sig)
(define section-tempo struct-section-tempo)
(define section-instr-part-list struct-section-instrument-part-list)

(define (section-frames sect)
  (foldl 
    (lambda (len id)
      (max len id))
      0
      (map (lambda (instr-part)
             (instr-part-frames instr-part (section-tempo sect)))
             (section-instr-part-list sect))))

;; Instrument Part
(struct struct-instrument-part [instrument measure-list])
(define instrument-part? struct-instrument-part?)
(define instr-part-instrument struct-instrument-part-instrument)
(define instr-part-measure-list struct-instrument-part-measure-list)
(define (instrument-part instrument . measures)
  (struct-instrument-part instrument measures))

;; Needs test
(define (instr-part-is-valid? instr-part time-sig)
  (cond ((not (instrument-part? instr-part)) 
         (error 
           "expected argument 1 to be of type: <#struct-instrument-part>"))
        ((not (time-signature? time-sig))
         (error 
           "expected argument 2 to be of type: <#time-signature>"))
        (else 
          (andmap (lambda (m)
                    (measure-is-valid? m time-sig))
                  (instr-part-measure-list instr-part)))))
(define (instr-part-frames instr-part tempo)
  (foldl (lambda (meas total)
           (if (not (measure? meas))
             0
             (+ total (measure-frames meas tempo))))
         0
         (instr-part-measure-list instr-part)))

(define (find-invalid-measure-indices instr-part time-sig)
  (let ([measure-list (instr-part-measure-list instr-part)])
    (filter 
      number?
        (for/list ([meas measure-list]
                   [i (in-range 0 (length measure-list))])
          (if (measure-is-valid? meas time-sig)
          meas
          i)))))




(struct struct-measure [notes]
  #:guard (lambda (notes name)
            (if (list? notes)
              (values notes)
              (error "expected list"))))

(define measure? struct-measure?)
(define measure-notes struct-measure-notes)
(define (measure . notes)
  (struct-measure notes))

(define (measure-is-valid? meas time-sig)
  (cond ((not (measure? meas)) 
         (error "expected argument 1 to be of type: <#struct-measure>"))
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
