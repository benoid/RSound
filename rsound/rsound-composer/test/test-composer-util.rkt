#lang racket

(require rackunit
         rackunit/text-ui
         "../composer-util.rkt")

(define composer-util-tests
  (test-suite
  "Tests for composer-util.rkt"
    (test-case
      "note-letter-to-base-number works as expected"
      (let ([letters (list 'C 'C# 'C#/Db 'Db 'D 'D# 'D#/Eb 
                           'Eb 'E 'F 'F# 'F#/Gb 'Gb 'G 
                           'G# 'G#/Ab 'Ab 'A 'A# 
                           'A#/Bb 'Bb 'B)]
            [nums (list 0 1 1 1 2 3 3 3 4 5 6 6 6 7 
                        8 8 8 9 10 10 10 11)])
        (check = (length letters) (length nums))
        (for ([l letters]
              [n nums])
          (check-equal? (note-letter-to-base-number l) n 
                        "could not convert letter symbol to base midi number"))))
    (test-case
      "midi-number-letter works as expected"
      (let ([letters (list 'C 'C#/Db 'D 'D#/Eb 
                           'E 'F 'F#/Gb 'G 
                           'G#/Ab 'A  
                           'A#/Bb 'B)]
            [nums (list 0 1 2 3 4 5 6 7 8 9 10 11)])
        (check = (length letters) (length nums))
        (for ([l letters]
              [n nums])
          (check-equal? (midi-number-letter n) l 
                        "could not convert midi number to note letter"))))
    (test-case
      "midi-number-octave works as expected"
      (let ([oct (list 0 1 2 3 4 5 6)]
            [mid (list 12 24 36 48 60 72 84)])
        (check = (length mid) (length oct))
        (for ([o oct]
              [m mid])
          (check-equal? (midi-number-octave m) o  
                        "could not convert midi number to octave number"))))

    (test-case
      "letter-and-octave-to-midi works as expected"
      (let ([letters (list 'A 'B 'C 'D 'E 'F 'G)]
            [oct (list  0  1  2  3  3  4  4)]
            [mid (list 21  35  36 50 52 65 67)])
        (check = (length mid) (length oct))
        (check = (length mid) (length letters))
        (for ([o oct]
              [m mid]
              [l letters])
          (check-equal? (letter-and-octave-to-midi l o) m  
                        "could not convert letter and octave to midi number"))))

    (test-case
      "midi-note-num-to-freq"
      (let ([freqs (list 55/2
                         29.13523509488062 
                         30.86770632850775 
                         32.70319566257483 
                         34.64782887210901 
                         36.70809598967594 
                         38.890872965260115 
                         41.20344461410875 
                         43.653528929125486 
                         46.2493028389543 
                         48.999429497718666 
                         51.91308719749314 
                         55 
                         58.27047018976124 
                         61.7354126570155 
                         65.40639132514966 
                         69.29565774421802 
                         73.41619197935188 
                         77.78174593052023 
                         82.4068892282175 
                         87.30705785825097 
                         92.4986056779086 
                         97.99885899543733 
                         103.82617439498628 
                         110 
                         116.54094037952248 
                         123.47082531403103 
                         130.8127826502993 
                         138.59131548843604 
                         146.8323839587038 
                         155.56349186104046 
                         164.81377845643496 
                         174.61411571650194 
                         184.9972113558172 
                         195.99771799087463 
                         207.65234878997256 
                         220 
                         233.08188075904496 
                         246.94165062806206 
                         261.6255653005986 
                         277.1826309768721 
                         293.6647679174076 
                         311.1269837220809 
                         329.6275569128699 
                         349.2282314330039 
                         369.9944227116344 
                         391.99543598174927 
                         415.3046975799451 
                         440 
                         466.1637615180899 
                         493.8833012561241 
                         523.2511306011972 
                         554.3652619537442 
                         587.3295358348151 
                         622.2539674441618 
                         659.2551138257398 
                         698.4564628660078 
                         739.9888454232688 
                         783.9908719634985 
                         830.6093951598903 
                         880 932.3275230361799 
                         987.7666025122483 
                         1046.5022612023945 
                         1108.7305239074883 
                         1174.6590716696303 
                         1244.5079348883237 
                         1318.5102276514797 
                         1396.9129257320155 
                         1479.9776908465376 
                         1567.981743926997 
                         1661.2187903197805 
                         1760 
                         1864.6550460723597 
                         1975.533205024496 
                         2093.004522404789 
                         2217.4610478149766 
                         2349.31814333926 
                         2489.0158697766474 
                         2637.02045530296 
                         2793.825851464031 
                         2959.955381693075 
                         3135.9634878539946 
                         3322.437580639561 
                         3520 
                         3729.3100921447194 
                         3951.066410048992)]
            [mid (for/list ([i (in-range 21 108)]) i)])
        (check = (length mid) (length freqs))
        (for ([m mid]
              [f freqs])
          (check-equal? (midi-note-num-to-freq m) f
                        "could not convert midi number to freq")
          (check-equal? (inexact->exact (freq-to-midi-note-num f)) m
                        "could not convert frequency to midi number"))))
    ))
(run-tests composer-util-tests)
