#lang racket

(require "note.rkt")
(provide (all-defined-out))

(struct struct-harmony [notes])

(define (harmony . notes)
  (struct-harmony notes))
(define harmony-notes struct-harmony-notes)
(define harmony? struct-harmony?)

;;;;;;;;;;;;;;; Basic Chord ;;;;;;;;;;;;

;; Make a harmony object with the notes of a specified chord
(define (basic-chord root quality beat-value)
  (define new-root (note (note-letter root) (note-octave root) beat-value))
  (define (major-triad)
    (harmony
      new-root
      (note-interval-up new-root 'Major3rd)
      (note-interval-up new-root 'Perfect5th)))
  (define (minor-triad)
    (harmony
      new-root
      (note-interval-up new-root 'Minor3rd)
      (note-interval-up new-root 'Perfect5th)))
  (define (diminished-triad)
    (harmony
      new-root
      (note-interval-up new-root 'Minor3rd)
      (note-interval-up new-root 'Diminished5th)))
  (define (augmented-triad)
    (harmony
      new-root
      (note-interval-up new-root 'Major3rd)
      (note-interval-up new-root 'Augmented5th)))
  (define (major-seventh)
    (harmony
      new-root
      (note-interval-up new-root 'Major3rd)
      (note-interval-up new-root 'Perfect5th)
      (note-interval-up new-root 'Major7th)))
  (define (minor-seventh)
    (harmony
      new-root
      (note-interval-up new-root 'Minor3rd)
      (note-interval-up new-root 'Perfect5th)
      (note-interval-up new-root 'Minor7th)))
  (define (dominant-seventh)
    (harmony
      new-root
      (note-interval-up new-root 'Major3rd)
      (note-interval-up new-root 'Perfect5th)
      (note-interval-up new-root 'Minor7th)))
  (define (half-diminished)
    (harmony
      new-root
      (note-interval-up new-root 'Minor3rd)
      (note-interval-up new-root 'Diminished5th)
      (note-interval-up new-root 'Minor7th)))
  (define (diminished-seventh)
    (harmony
      new-root
      (note-interval-up new-root 'Minor3rd)
      (note-interval-up new-root 'Diminished5th)
      ;; No support for diminished seventh
      ;; interval yet, so use major 6th
      (note-interval-up new-root 'Major6th)))
  (define (dispatch token)
    (cond ((eq? token 'Maj) (major-triad))
          ((eq? token 'Min) (minor-triad))
          ((eq? token 'Dim) (diminished-triad))
          ((eq? token 'Aug) (augmented-triad))
          ((eq? token 'Maj7) (major-seventh))
          ((eq? token 'Min7) (minor-seventh))
          ((eq? token 'Dom7) (dominant-seventh))
          ((eq? token 'HalfDim) (half-diminished))
          ((eq? token 'Dim7) (diminished-seventh))
          (else
           ((harmony new-root)))))
  (dispatch quality))

;;;;;;;;;;;;;;;; Functional Harmony ;;;;;;;;;;;;;;

;; Take a key (note object), roman numeral (symbol),
;; and beat-value in frames and produce a harmony object
(define (functional-harmony key roman-numeral beat-value)
  (define (I)
    (basic-chord key 'Maj beat-value))
  (define (i)
    (basic-chord key 'Min beat-value))
  (define (I7)
    (basic-chord key 'Maj7 beat-value))
  (define (i7)
    (basic-chord key 'Min7 beat-value))
  (define V/IV I)
  (define (V7/IV)
    (basic-chord key 'Dom7 beat-value))  
  (define (ii)
    (basic-chord
     (note-interval-up key 'Major2nd)
     'Min
     beat-value))
  (define (ii-dim)
    (basic-chord
     (note-interval-up key 'Major2nd)
     'Dim
     beat-value))
  (define (V/V)
    (basic-chord
     (note-interval-up key 'Major2nd)
     'Maj
     beat-value))
  (define (ii7)
    (basic-chord
     (note-interval-up key 'Major2nd)
     'Min7
     beat-value))
  (define (ii-dim7)
    (basic-chord
     (note-interval-up key 'Major2nd)
     'HalfDim
     beat-value))
  (define (bII)
    (basic-chord
     (note-interval-up key 'Minor2nd)
     'Maj
     beat-value))
  (define (V7/V)
    (basic-chord
     (note-interval-up key 'Major2nd)
     'Dom7
     beat-value))
  (define (iii)
    (basic-chord
     (note-interval-up key 'Major3rd)
     'Min
     beat-value))
  (define (bIII)
    (basic-chord
     (note-interval-up key 'Minor3rd)
     'Maj
     beat-value))
  (define (V7/VI)
    (basic-chord
     (note-interval-up key 'Major3rd)
     'Dom7
     beat-value))
  (define (IV)
    (basic-chord
     (note-interval-up key 'Perfect4th)
     'Maj
     beat-value))
  (define (iv)
    (basic-chord
     (note-interval-up key 'Perfect4th)
     'Min
     beat-value))
  (define (V)
    (basic-chord
     (note-interval-up key 'Perfect5th)
     'Maj
     beat-value))
  (define (V7)
    (basic-chord
     (note-interval-up key 'Perfect5th)
     'Dom7
     beat-value))
  (define (vi)
    (basic-chord
     (note-interval-up key 'Major6th)
     'Min
     beat-value))
  (define (bVI)
    (basic-chord
     (note-interval-up key 'Minor6th)
     'Maj
     beat-value))
  (define (vii-dim)
    (basic-chord
     (note-interval-up key 'Major7th)
     'Dim
     beat-value))
  (define (bVII)
    (basic-chord
     (note-interval-up key 'Minor7th)
     'Maj
     beat-value))
  (define (dispatch token)
    (cond ((eq? token 'I) (I))
          ((eq? token 'i) (i))
          ((eq? token 'I7) (I7))
          ((eq? token 'i7) (i7))
          ((eq? token 'V/IV) (V/IV))
          ((eq? token 'V7/IV) (V7/IV))
          ((eq? token 'ii) (ii))
          ((eq? token 'ii-dim) (ii-dim))
          ((eq? token 'ii7) (ii7))
          ((eq? token 'ii-dim7) (ii-dim7))
          ((eq? token 'bII) (bII))
          ((eq? token 'V7/V) (V7/V))
          ((eq? token 'iii) (iii))
          ((eq? token 'bIII) (bIII))
          ((eq? token 'bIII) (bIII))
          ((eq? token 'V7/VI) (V7/VI))
          ((eq? token 'IV) (IV))
          ((eq? token 'iv) (iv))
          ((eq? token 'V) (V))
          ((eq? token 'V7) (V7))
          ((eq? token 'vi) (vi))
          ((eq? token 'bVI) (bVI))
          ((eq? token 'vii-dim) (vii-dim))
          ((eq? token 'bVII) (bVII))
          (else
           (error "invalid chord symbol: " token))))
  (dispatch roman-numeral))

;; Alias measure as harmonic-progression 
(define (harmonic-progression p) p)


;;;;;;;;;; Common Minor Progressions ;;;;;;;;;

(define (i-V7-bVI-V key chord-beat-value)
  (harmonic-progression
   (list
    (functional-harmony key 'i chord-beat-value)
    (functional-harmony key 'V7 chord-beat-value)
    (functional-harmony key 'bVI chord-beat-value)
    (functional-harmony key 'V chord-beat-value))))

(define (i-iv-V7 key chord-beat-value)
  (harmonic-progression
   (list
    (functional-harmony key 'i chord-beat-value)
    (functional-harmony key 'iv chord-beat-value)
    (functional-harmony key 'V7 chord-beat-value))))

(define (i-bVI-iidim-V7-i-iv-V7 key chord-beat-value)
  (harmonic-progression
   (list
    (functional-harmony key 'i chord-beat-value)
    (functional-harmony key 'bVI chord-beat-value)
    (functional-harmony key 'ii-dim chord-beat-value)
    (functional-harmony key 'V chord-beat-value)
    (functional-harmony key 'i chord-beat-value)
    (functional-harmony key 'iv chord-beat-value)
    (functional-harmony key 'V7 chord-beat-value))))

(define (i-bVI-iidim-V7 key chord-beat-value)
  (harmonic-progression
   (list
    (functional-harmony key 'i chord-beat-value)
    (functional-harmony key 'bVI chord-beat-value)
    (functional-harmony key 'ii-dim chord-beat-value)
    (functional-harmony key 'V chord-beat-value))))

(define (i-iv-V7-i-bVI-iidim-V7 key chord-beat-value)
  (harmonic-progression
   (list
    (functional-harmony key 'i chord-beat-value)
    (functional-harmony key 'iv chord-beat-value)
    (functional-harmony key 'V7 chord-beat-value)
    (functional-harmony key 'i chord-beat-value)
    (functional-harmony key 'bVI chord-beat-value)
    (functional-harmony key 'ii-dim chord-beat-value)
    (functional-harmony key 'V chord-beat-value))))

(define (i-iv-V7-i-bVI-bII-V7 key chord-beat-value)
  (harmonic-progression
   (list
    (functional-harmony key 'i chord-beat-value)
    (functional-harmony key 'iv chord-beat-value)
    (functional-harmony key 'V7 chord-beat-value)
    (functional-harmony key 'i chord-beat-value)
    (functional-harmony key 'bVI chord-beat-value)
    (functional-harmony key 'bII chord-beat-value)
    (functional-harmony key 'V chord-beat-value))))


(define (i-iv-bVII-III-bVI-iidim-V key chord-beat-value)
  (harmonic-progression
   (list
    (functional-harmony key 'i chord-beat-value)
    (functional-harmony key 'iv chord-beat-value)
    (functional-harmony key 'bVII chord-beat-value)
    (functional-harmony key 'bIII chord-beat-value)
    (functional-harmony key 'bVI chord-beat-value)
    (functional-harmony key 'ii-dim chord-beat-value)
    (functional-harmony key 'V chord-beat-value))))


;; Put the progressions in a list for easy access
(define tonal-proglist
  (list i-iv-V7
        i-V7-bVI-V
        i-bVI-iidim-V7
        i-iv-V7-i-bVI-bII-V7
        i-iv-V7-i-bVI-iidim-V7
        i-bVI-iidim-V7-i-iv-V7
        i-iv-bVII-III-bVI-iidim-V
        ))
        


