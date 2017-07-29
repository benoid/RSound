#lang racket

(require 
  "../main.rkt"
  "composer-rsound-instrument.rkt"
  "note.rkt"
  "composer-util.rkt"
  "beat-value.rkt"
  "score.rkt")

(provide (all-defined-out))


(define default-pstream
  (make-pstream))

(define (sleep-while thnk time)
  (void
    (unless (not (thnk))
      (begin
        (sleep time)
        (sleep-while thnk time)))))


(define (note->rsound n conversion-proc #:tempo [tempo 120])
  (conversion-proc n tempo))


(define (note/instrument->rsound n instr #:tempo [tempo 120])
  ((instrument-conversion-proc instr) n tempo))


(define (measure->rsound-list meas conversion-proc #:tempo [tempo 120])
  (map (lambda (n)
         (conversion-proc n tempo))
       (measure-notes meas)))


(define 
  (measure/instrument->rsound-list meas instr #:tempo [tempo 120])
  (map (lambda (n)
         (note/instrument->rsound n instr #:tempo tempo))
       (measure-notes meas)))


(define (measure->rsound meas instr #:tempo [t 120])
  (rs-append* (measure/instrument->rsound-list meas instr #:tempo t)))


(define (instrument-line->rsound-list instr-line #:tempo [tempo 120])
  (append* 
    (map (lambda (m)
           (measure->rsound-list 
             m
             (instrument-conversion-proc
               (instr-line-instrument instr-line))
             #:tempo tempo))
         (instr-line-measure-list instr-line))))


(define (instrument-line->rsound ip #:tempo [t 120])
  (rs-append* (instrument-line->rsound-list #:tempo t ip)))


(define (section->rsound-2dlist sect)
  (map
    (lambda (instr-line)
      (instrument-line->rsound-list 
        instr-line
        #:tempo (section-tempo sect)))
    (section-instr-line-list sect)))


(define (section->rsound sect)
  (rs-overlay* (section->rsound-2dlist sect)))


;; Queues a note and returns the last frame number of the queued note
(define (pstream-queue-note pstr n instr frames #:tempo [tempo 120])
  (let ([note-rsound (note/instrument->rsound n instr #:tempo tempo)])
    (pstream-queue pstr note-rsound frames)
    (rs-frames note-rsound)))


(define (play-note 
          n 
          #:instrument [instr (main-synth-instrument 7)] 
          #:tempo [tempo 120])
  (pstream-queue-note default-pstream 
                      n 
                      instr 
                      (pstream-current-frame default-pstream)
                      #:tempo tempo))


(define (pstream-loop-measure 
          pstr 
          meas 
          instr 
          frames 
          #:tempo [tempo 120] 
          #:callback-buffer [callback-buffer 22050])
  (pstream-loop-rslist 
    pstr
    (measure/instrument->rsound-list meas instr #:tempo tempo)
    frames
    #:callback-buffer callback-buffer))


(define (pstream-queue-measure 
          pstr 
          meas 
          instr 
          frames 
          #:tempo [tempo 120] 
          #:latency-correction [lat 'on])
  (let ([rs-list 
          (measure/instrument->rsound-list meas instr #:tempo tempo)]
        [frames (if (or (>= frames (pstream-current-frame pstr)) (eq? lat 'off)) 
                  frames
                  (pstream-current-frame pstr))])
    (pstream-queue-rslist 
      pstr 
      rs-list
      frames)))


(define (pstream-queue-measure/dynamic 
          pstr 
          meas 
          instr 
          frames 
          #:tempo [tempo 120])
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


(define (play-measure 
          meas 
          #:instrument [instr (main-synth-instrument 7)]
          #:tempo [tempo 120])
  (pstream-queue-measure default-pstream 
                         meas 
                         instr 
                         (pstream-current-frame default-pstream)
                         #:tempo tempo))


(define (pstream-queue-instrument-line 
          pstr 
          instr-line 
          frames 
          #:tempo [tempo 120]
          #:latency-correction [lat 'on])
  (let ([rs-list 
          (instrument-line->rsound-list instr-line #:tempo tempo)]
        [frames (if (or (>= frames (pstream-current-frame pstr)) (eq? lat 'off))
                  frames
                  (pstream-current-frame pstr))])
    (pstream-queue-rslist 
      pstr 
      rs-list
      frames)))


(define (pstream-loop-instrument-line 
          pstr 
          instr 
          frames 
          #:tempo [tempo 120]
          #:callback-buffer [callback-buffer 22050])
  (pstream-loop-rslist 
    pstr
    (instrument-line->rsound-list instr #:tempo tempo)
    frames
    #:callback-buffer callback-buffer))


(define (pstream-queue-instrument-line/dynamic 
          pstr
          instr-line
          frames
          #:tempo [tempo 120])
  (- (foldl (lambda (meas frms)
              (let ([measure-frames
                      (pstream-queue-measure/dynamic
                        pstr
                        meas
                        (instr-line-instrument instr-line)
                        frms
                        #:tempo tempo)])
                (+ frms measure-frames)))
            frames
            (instr-line-measure-list instr-line)) frames))


(define (play-instrument-line instr-line #:tempo [tempo 120])
  (pstream-queue-instrument-line default-pstream 
                                 instr-line 
                                 (pstream-current-frame default-pstream)
                                 #:tempo tempo))


(define (pstream-loop-section 
          pstr 
          sect 
          frames
          #:callback-buffer [callback-buffer 22050]
          #:latency-correction [lat 'on])
  (let* ([2d-rslist (section->rsound-2dlist sect)]
         [thread-ids
           (map (lambda (rs-list)
                  (thread
                    (lambda ()
                      (pstream-loop-rslist 
                        pstr
                        rs-list
                        (if (>= frames (pstream-current-frame pstr)) 
                          frames
                          (pstream-current-frame pstr))) 
                      (kill-thread (current-thread)))))
                2d-rslist)])
         (void))
    ;(sleep-while (lambda () (andmap thread-running? thread-ids)) 0.005)
    )


(define (pstream-queue-section 
          pstr 
          sect 
          frames
          #:latency-correction [lat 'on])
  (let* ([2d-rslist (section->rsound-2dlist sect)]
         [thread-ids
           (map (lambda (rs-list)
                  (thread
                    (lambda ()
                      (pstream-queue-rslist 
                        pstr
                        rs-list
                        (if (or (>= frames (pstream-current-frame pstr)) 
                                (= lat 'off))
                          frames
                          (pstream-current-frame pstr))) 
                      (kill-thread (current-thread)))))
                2d-rslist)])
   ; (sleep-while (lambda () (andmap thread-running? thread-ids)) 0.005)
   (void)
    ))


(define (pstream-queue-section/dynamic 
          pstr 
          sect 
          frames
          #:thread-sleep-interval [tsi .005])
  (let 
    ([thread-ids 
       (map 
         (lambda (instr-line)
           (thread 
             (lambda ()
               (pstream-queue-instrument-line/dynamic
                 pstr
                 instr-line
                 frames
                 #:tempo (section-tempo sect))
               (kill-thread (current-thread))
               )))
         (section-instr-line-list sect))])
   ;(sleep-while
    ;  (lambda ()
    ;    (andmap thread-running? thread-ids))
    ;  tsi)
    (section-frames sect)))


(define (play-section sect)
  (pstream-queue-section default-pstream 
                         sect 
                         (pstream-current-frame default-pstream)))


(define (score->rsound-2dlist scr)
  (map (lambda (sect)
         (section->rsound-2dlist sect))
       (score-section-list scr)))


(define (pstream-queue-score/dynamic pstr scr frames)
  (- (foldl (lambda (sect frms)
              (let ([section-frames
                      (pstream-queue-section
                        pstr
                        sect
                        frms)])
                (+ frms section-frames)))
            frames
            (score-section-list scr)) frames))


(define (pstream-queue-score
          pstr 
          scr 
          frames 
          #:tempo [tempo 120]
          #:latency-correction [lat 'on])
  (let* ([2d-rslist (score->rsound-2dlist scr)]
         [thread-ids
           (map (lambda (rs-list)
                  (thread
                    (lambda ()
                      (pstream-queue-rslist 
                        pstr
                        rs-list
                        (if (or (>= frames (pstream-current-frame pstr)) 
                                (eq? lat 'off))
                          frames
                          (pstream-current-frame pstr)))
                      (kill-thread (current-thread)))))
                2d-rslist)])
    ;(sleep-while (lambda () (andmap thread-running? thread-ids)) 0.005)
    (void)
    ))


(define (pstream-loop-score 
          pstr 
          scr 
          frames 
          #:tempo [tempo 120]
          #:callback-buffer [callback-buffer 22050])
  (let* ([2d-rslist (score->rsound-2dlist scr)]
         [thread-ids
           (map (lambda (rs-list)
                  (thread
                    (lambda ()
                      (pstream-loop-rslist 
                        pstr
                        rs-list
                        frames
                        #:callback-buffer callback-buffer) 
                      (kill-thread (current-thread)))))
                2d-rslist)])
    ;(sleep-while (lambda () (andmap thread-running? thread-ids)) 0.005)
    (void)
    ))

(define (play-score scr)
  (pstream-queue-score default-pstream 
                       scr 
                       (pstream-current-frame default-pstream)))


(define (score->rsound scr)
  (rs-append* (map section->rsound (score-section-list scr))))

#|
(define/contract (export-wav composer-item)
                 (-> (lambda (x)
                       (or (note? x)
                           (measure? x)
                           (instrument-line? x)
                           (section? x)
                           (score? x)))
                     (void))
                 (let
                   |#
