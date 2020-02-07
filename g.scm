(define (send message object . args)
  (let ((method (method-lookup object message)))
    (cond ((procedure? method) (apply method args))
          ((null? method)
           (error #f "Message not understood: " message))
          (else
           (error #f "Inappropriate result of method lookup: "
                  method)))))

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
        (else
         (error #f "Inappropriate object in method-lookup: "
                object))))

(define (object)
  (let [(super '())
        (self 'nil)]
    (define (set-self! object-part)
      (set! self object-part))
    (define (self message)
      (cond [(eqv? message 'set-self!) set-self!]
            [else '()]))
    self))

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
