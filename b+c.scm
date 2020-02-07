(define (new-instance class . parameters)
  (apply class parameters))

(define (send message object . args)
  (let ((method (object message)))
    (cond ((procedure? method) (apply method args))
          (else (error #f "Error in method lookup " method)))))

(define (point x y)
  (let ((x x)
        (y y))

    (define (getx) x)

    (define (gety) y)

    (define (add p)
      (point
       (+ x (send 'getx p))
       (+ y (send 'gety p))))

    (define (type-of) 'point)

    (define (self message)
      (cond ((eqv? message 'getx) getx)
            ((eqv? message 'gety) gety)
            ((eqv? message 'add)  add)
            ((eqv? message 'type-of) type-of)
            (else (error #f "Undefined message" message))))

    self))

(define p (new-instance point 2 3))
(format #t "p x: ~a~%" (send 'getx p))

(define q (new-instance point 4 5))
(define p+q (send 'add p q))

(format #t "p+q x: ~a~%" (send 'getx p+q))
(format #t "p+q y: ~a~%" (send 'gety p+q))
