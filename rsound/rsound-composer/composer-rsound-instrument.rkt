#lang racket

(require "../main.rkt"
         "../single-cycle.rkt"
         "note.rkt"
         "beat-value.rkt"
         "harmony.rkt")

(provide (except-out (all-defined-out)
                     conversion-proc-safety-wrapper))


;; Needs test
(struct instrument [name conversion-proc]
  #:guard (lambda (name proc t)
            (if (and (string? name)
                     (procedure? proc))
                (values name (conversion-proc-safety-wrapper proc))
                (error "expected args of type: <#string> <#procedure>"))))


;; Needs test
(define/contract (conversion-proc-safety-wrapper conversion-proc)
  (-> procedure? procedure?)
  (lambda (n tempo)
    (cond ((rest? n) (silence (beat-value-frames 
                                ((note-duration n) tempo))))
          ((harmony? n) 
           (rs-overlay*
             (map (lambda (x)
                    (conversion-proc x tempo))
                  (harmony-notes n))))
         (else 
           (conversion-proc n tempo)))))

;; Needs test
(define (vgame-synth-instrument spec)
  (instrument 
    (string-append "vgame synth: " (number->string spec))
    (lambda (n tempo)
      (synth-note "vgame" 
                  spec 
                  (note-midi-number n) 
                  (beat-value-frames ((note-duration n) tempo))))))

;; Needs test
(define (main-synth-instrument spec)
  (instrument 
    (string-append "main synth: " (number->string spec))
    (lambda (n tempo)
      (synth-note "main" 
                  spec 
                  (note-midi-number n) 
                  (beat-value-frames ((note-duration n) tempo))))))

;; Needs test
(define (path-synth-instrument spec)
  (instrument 
    (string-append "path synth: " (number->string spec))
    (lambda (n tempo)
      (synth-note "path" 
                  spec 
                  (note-midi-number n) 
                  (beat-value-frames ((note-duration n) tempo))))))

