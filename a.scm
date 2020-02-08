(define (point x y)
  (letrec ((getx (lambda () x))
           (gety (lambda () y))
           (add  (lambda (p)
                   (point
                    (+ x (send 'getx p))
                    (+ y (send 'gety p)))))
           (type-of (lambda () 'point)))
    (lambda (message)
      (cond ((eq? message 'getx) getx)
            ((eq? message 'gety) gety)
            ((eq? message 'add)  add)
            ((eq? message 'type-of) type-of)
            (else (error "point" "Message not understood" message))))))

(define (send message obj . par)
  (let ((method (obj message)))
    (apply method par)))

(define p (point 1 2))
(format "x: ~a" (send 'getx p))
(format "y: ~a" (send 'gety p))

