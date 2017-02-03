#lang racket

(require "../main.rkt"
         "../single-cycle.rkt"
         "note.rkt"
         "beat-value.rkt"
         "harmony.rkt"
         "define-argcheck.rkt")

(provide (all-defined-out))


;; Needs test
(struct instrument [name conversion-proc]
  #:guard (lambda (name proc t)
            (if (and (string? name)
                     (procedure? proc))
                (values name proc)
                (error "expected args of type: <#string> <#procedure>"))))


;; Needs test
(define/argcheck (conversion-proc-safety-wrapper 
                   [conversion-proc procedure? "procedure"])
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

(define (create-instrument name conversion-proc)
  (instrument name (conversion-proc-safety-wrapper conversion-proc)))


;; Needs test
(define (vgame-synth-instrument spec)
  (create-instrument 
    (string-append "vgame synth: " (number->string spec))
    (lambda (n tempo)
      (synth-note "vgame" 
                  spec 
                  (note-midi-number n) 
                  (beat-value-frames ((note-duration n) tempo))))))

;; Needs test
(define (main-synth-instrument spec)
  (create-instrument 
    (string-append "main synth: " (number->string spec))
    (lambda (n tempo)
      (synth-note "main" 
                  spec 
                  (note-midi-number n) 
                  (beat-value-frames ((note-duration n) tempo))))))

;; Needs test
(define (path-synth-instrument spec)
  (create-instrument 
    (string-append "path synth: " (number->string spec))
    (lambda (n tempo)
      (synth-note "path" 
                  spec 
                  (note-midi-number n) 
                  (beat-value-frames ((note-duration n) tempo))))))

