#lang racket

(require "../main.rkt"
         "composer-rsound-instrument.rkt"
         "note.rkt"
         "composer-util.rkt"
         "beat-value.rkt"
         "score.rkt")

(provide (except-out (all-defined-out)
                     sleep-while))

(define default-pstream
  (make-pstream))

(define (sleep-while thnk time)
  (if (thnk)
    (begin
      (sleep time)
      (sleep-while thnk time))
    #t))

;; Needs test
(define (note->rsound n conversion-proc #:tempo [tempo 120])
  (conversion-proc n tempo))

;; Needs test
(define (note/instrument->rsound n instr #:tempo [tempo 120])
  ((instrument-conversion-proc instr) n tempo))

;; Needs test
(define (measure->rsound-list meas conversion-proc #:tempo [tempo 120])
  (map (lambda (n)
         (conversion-proc n tempo))
       (measure-notes meas)))

;; Needs test
(define 
  (measure/instrument->rsound-list meas instr #:tempo [tempo 120])
  (map (lambda (n)
         (note/instrument->rsound n instr #:tempo tempo))
       (measure-notes meas)))

;; Needs test
(define (instrument-part->rsound-list instr-part #:tempo [tempo 120])
  (append* 
    (map (lambda (m)
           (measure->rsound-list 
             m
             (instrument-conversion-proc
               (instr-part-instrument instr-part))
             #:tempo tempo))
         (instr-part-measure-list instr-part))))

;; Needs test
(define (section->rsound-2dlist sect)
  (map
    (lambda (instr-part)
      (instrument-part->rsound-list 
        instr-part
        #:tempo (section-tempo sect)))
    (section-instr-part-list sect)))

;; Queues a note and returns the last frame number of the queued note
;; Needs test
(define (pstream-queue-note pstr n instr frames #:tempo [tempo 120])
  (let ([note-rsound (note/instrument->rsound n instr #:tempo tempo)])
    (pstream-queue pstr note-rsound frames)
    (rs-frames note-rsound)))

;; Needs test
(define (play-note n #:instrument [instr (main-synth-instrument 7)]
                     #:tempo [tempo 120])
  (pstream-queue-note default-pstream 
                      n 
                      instr 
                      (pstream-current-frame default-pstream)
                      #:tempo tempo))


;; Needs test
(define (pstream-queue-measure pstr meas instr frames #:tempo [tempo 120])
  (- (foldl (lambda (n frms)
             (let ([note-frames 
                     (pstream-queue-note
                       pstr
                       n
                       instr
                       frms
                        #:tempo tempo)])
             (+ frms note-frames)))
             frames
             (measure-notes meas))
     frames))

;; Needs test
(define (play-measure meas #:instrument [instr (main-synth-instrument 7)]
                           #:tempo [tempo 120])
  (pstream-queue-measure default-pstream 
                         meas 
                         instr 
                         (pstream-current-frame default-pstream)
                         #:tempo tempo))

;; Needs test
(define (pstream-queue-instrument-part pstr
                                       instr-part
                                       frames
                                       #:tempo [tempo 120])
  (- (foldl (lambda (meas frms)
             (let ([measure-frames
                     (pstream-queue-measure
                       pstr
                       meas
                       (instr-part-instrument instr-part)
                       frms
                       #:tempo tempo)])
               (+ frms measure-frames)))
             frames
             (instr-part-measure-list instr-part)) frames))

;; Needs test
(define (play-instrument-part instr-part #:tempo [tempo 120])
  (pstream-queue-instrument-part default-pstream 
                                 instr-part 
                                 (pstream-current-frame default-pstream)
                                 #:tempo tempo))

;; Needs test
(define (pstream-queue-section pstr 
                               sect 
                               frames
                               #:thread-sleep-interval [tsi .005])
  (let 
    ([thread-ids 
       (map 
         (lambda (instr-part)
              (thread 
                (lambda ()
                        (pstream-queue-instrument-part 
                          pstr
                          instr-part
                          frames
                          #:tempo (section-tempo sect))
                        (kill-thread (current-thread))
                      )))
            (section-instr-part-list sect))])
       (sleep-while
         (lambda ()
           (andmap thread-running? thread-ids))
         tsi)
       (section-frames sect)))

;; Needs test
(define (play-section sect)
  (pstream-queue-section default-pstream 
                         sect 
                         (pstream-current-frame default-pstream)))

;; Needs test
(define (pstream-queue-score pstr scr frames)
  (- (foldl (lambda (sect frms)
              (let ([section-frames
                      (pstream-queue-section
                        pstr
                        sect
                        frms)])
                (+ frms section-frames)))
            frames
            (score-section-list scr)) frames))

;; Needs test
(define (play-score scr)
  (pstream-queue-score default-pstream 
                       scr 
                       (pstream-current-frame default-pstream)))
