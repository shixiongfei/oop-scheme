(define (new-instance class . parameters)
  (apply class parameters))

(define (new-part class . parameters)
  (apply class parameters))

(define (method-lookup object selector)
  (cond [(procedure? object) (object selector)]
        [else (error #f "Inappropriate object in method-lookup: " object)]))

(define (send message object . args)
  (let [(method (method-lookup object message))]
    (cond [(procedure? method) (apply method args)]
          [(null? method) (error #f "Message not understood: " message)]
          [else (error #f "Inappropriate result of method lookup: " method)])))

(define (object)
  (let [(super '())
        (self 'nil)]
    (define (dispatch message)
      '())
    (set! self dispatch)
    self))

(define (point x y)
  (let [(super (new-part object))
        (self 'nil)
        (x x)
        (y y)]
    (define (getx) x)
    (define (gety) y)
    (define (add p)
      (point
       (+ x (send 'getx p))
       (+ y (send 'gety p))))
    (define (type-of) 'point)
    (define (dispatch message)
      (cond [(eqv? message 'getx) getx]
            [(eqv? message 'gety) gety]
            [(eqv? message 'add)  add]
            [(eqv? message 'type-of) type-of]
            [else (method-lookup super message)]))
    (set! self dispatch)
    self))

(define (color-point x y color)
  (let [(super (new-part point x y))
        (self 'nil)]
    (let [(color color)]
      (define (get-color) color)
      (define (type-of) 'color-point)
      (define (dispatch message)
        (cond [(eqv? message 'get-color) get-color]
              [(eqv? message 'type-of) type-of]
              [else (method-lookup super message)]))
      (set! self dispatch))
    self))

(define p (new-instance point 2 3))
(define q (new-instance point 4 5))
(define p+q (send 'add p q))

(format #t "~a~%" (send 'getx p))
(format #t "~a~%" (send 'getx p+q))
(format #t "~a~%" (send 'gety p+q))

(define cp (new-instance color-point 5 6 'red))

(format #t "~a~%" (send 'get-color cp))
(format #t "~a~%" (send 'getx cp))
(format #t "~a~%" (send 'gety cp))

(define cp-1 (send 'add cp (new-instance color-point 1 2 'green)))

(format #t "~a~%" (send 'getx cp-1))
(format #t "~a~%" (send 'gety cp-1))
(format #t "~a~%" (send 'type-of cp-1))
(format #t "~a~%" (send 'get-color cp-1))
