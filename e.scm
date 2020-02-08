(define (new-instance class . parameters)
  (apply class parameters))

(define (new-part class . parameters)
  (apply class parameters))

(define (method-lookup object selector)
  (cond ((procedure? object) (object selector))
        (else
         (error "method-lookup"
            "Inappropriate object in method-lookup: "
            object))))

(define (send message object . args)
  (let ((method (method-lookup object message)))
    (cond ((procedure? method) (apply method args))
          ((null? method)
           (error "send" "Message not understood: " message))
          (else
           (error "send"
              "Inappropriate result of method lookup: "
              method)))))

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
            (else (error "point" "Undefined message" message))))

    self))

(define (color-point x y color)
  (let ((super (new-part point x y))
        (self 'nil))
    (let ((color color))

      (define (get-color)
        color)

      (define (type-of) 'color-point)

      (define (dispatch message)
        (cond ((eqv? message 'get-color) get-color)
              ((eqv? message 'type-of) type-of)
              (else (method-lookup super message))))

      (set! self dispatch))

    self))

(define cp (new-instance color-point 5 6 'red))

(format "cp color: ~a" (send 'get-color cp))
(format "cp x: ~a" (send 'getx cp))
(format "cp y: ~a" (send 'gety cp))

(define cp-1 (send 'add cp (new-instance color-point 1 2 'green)))

(format "cp-1 x: ~a" (send 'getx cp-1))
(format "cp-1 y: ~a" (send 'gety cp-1))
(format "cp-1 type of: ~a" (send 'type-of cp-1))
(format "cp-1 color: ~a" (send 'get-color cp-1))

