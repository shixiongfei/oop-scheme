(define (send message object . args)
  (let ((method (method-lookup object message)))
    (cond ((procedure? method) (apply method args))
          ((null? method) (error "send" "Message not understood: " message))
          (else (error "send" "Inappropriate result of method lookup: " method)))))

(define (virtual-operations object)
  (send 'set-self! object object))

(define (new-instance class . parameters)
  (let ((instance (apply class parameters)))
   (virtual-operations instance)
   instance))

(define (new-part class . parameters)
  (apply class parameters))

(define (method-lookup object selector)
  (cond ((procedure? object) (object selector))
        (else (error "method-lookup" "Inappropriate object in method-lookup: " object))))

(define (object)
  (let ((super '())
        (self 'nil))
    (define (set-self! object-part)
      (set! self object-part))
    (define (self message)
      (cond ((eqv? message 'set-self!) set-self!)
            (else '())))
    self))

(define (point x y)
  (let ((super (new-part object))
        (self 'nil)
        (x x)
        (y y))
    (define (getx) x)
    (define (gety) y)
    (define (add p)
      (point
       (+ x (send 'getx p))
       (+ y (send 'gety p))))
    (define (type-of) 'point)
    (define (set-self! object-part)
      (set! self object-part)
      (send 'set-self! super object-part))
    (define (self message)
      (cond ((eqv? message 'getx) getx)
            ((eqv? message 'gety) gety)
            ((eqv? message 'add)  add)
            ((eqv? message 'type-of) type-of)
            ((eqv? message 'set-self!) set-self!)
            (else (method-lookup super message))))
    self))

(define (color-point x y color)
  (let ((super (new-part point x y))
        (self 'nil))
    (let ((color color))
      (define (get-color) color)
      (define (type-of) 'color-point)
      (define (set-self! object-part)
        (set! self object-part)
        (send 'set-self! super object-part))
      (define (self message)
        (cond ((eqv? message 'get-color) get-color)
              ((eqv? message 'type-of) type-of)
              ((eqv? message 'set-self!) set-self!)
              (else (method-lookup super message))))
      self)))

(define (x)
  (let ((super (new-part object))
        (self 'nil))
    (let ((x-state 1))
      (define (get-state) x-state)
      (define (res)
        (send 'get-state self))
      (define (set-self! object-part)
        (set! self object-part)
        (send 'set-self! super object-part))
      (define (self message)
        (cond ((eqv? message 'get-state) get-state)
              ((eqv? message 'res) res)
              ((eqv? message 'set-self!) set-self!)
              (else (method-lookup super message))))
      self)))

(define (y)
  (let ((super (new-part x))
        (self 'nil))
    (let ((y-state 2))
      (define (get-state) y-state)
      (define (set-self! object-part)
        (set! self object-part)
        (send 'set-self! super object-part))
      (define (self message)
        (cond ((eqv? message 'get-state) get-state)
              ((eqv? message 'set-self!) set-self!)
              (else (method-lookup super message))))
      self)))

(define a (new-instance x))
(define b (new-instance y))

(format #t "a: ~a~%" (send 'res a))
(format #t "b: ~a~%" (send 'res b))

(define p (new-instance point 2 3))
(define q (new-instance point 4 5))
(define p+q (send 'add p q))

(format #t "p x: ~a y: ~a~%" (send 'getx p) (send 'gety p))
(format #t "p+q x: ~a y: ~a~%" (send 'getx p+q) (send 'gety p+q))

(define cp (new-instance color-point 5 6 'red))

(format #t "cp color: ~a x: ~a y: ~a~%"
        (send 'get-color cp)
        (send 'getx cp)
        (send 'gety cp))

(define cp-1 (send 'add cp (new-instance color-point 1 2 'green)))

(format #t "cp-1 type: ~a x: ~a y: ~a~%"
        (send 'type-of cp-1)
        (send 'getx cp-1)
        (send 'gety cp-1))
(format #t "cp-1 color: ~a~%" (send 'get-color cp-1))  ;; Error: "Message not understood: " get-color
