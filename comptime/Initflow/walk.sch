;; ==========================================================
;; Class accessors
;; Bigloo (3.7b)
;; Inria -- Sophia Antipolis     Mon Nov 14 16:42:36 CET 2011 
;; (bigloo.new -classgen Initflow/walk.scm)
;; ==========================================================

;; The directives
(directives

;; sfun/iflow
(cond-expand ((and bigloo-class-sans (not bigloo-class-generate))
  (static
    (inline make-sfun/iflow::sfun/iflow arity1171::long side-effect1172::obj predicate-of1173::obj stack-allocator1174::obj top?1175::bool the-closure1176::obj effect1177::obj property1178::obj args1179::obj args-name1180::obj body1181::obj class1182::obj dsssl-keywords1183::obj loc1184::obj optionals1185::obj keys1186::obj the-closure-global1187::obj strength1188::symbol)
    (inline sfun/iflow?::bool ::obj)
    (sfun/iflow-nil::sfun/iflow)
    (inline sfun/iflow-strength::symbol ::sfun/iflow)
    (inline sfun/iflow-strength-set! ::sfun/iflow ::symbol)
    (inline sfun/iflow-the-closure-global::obj ::sfun/iflow)
    (inline sfun/iflow-the-closure-global-set! ::sfun/iflow ::obj)
    (inline sfun/iflow-keys::obj ::sfun/iflow)
    (inline sfun/iflow-optionals::obj ::sfun/iflow)
    (inline sfun/iflow-loc::obj ::sfun/iflow)
    (inline sfun/iflow-loc-set! ::sfun/iflow ::obj)
    (inline sfun/iflow-dsssl-keywords::obj ::sfun/iflow)
    (inline sfun/iflow-dsssl-keywords-set! ::sfun/iflow ::obj)
    (inline sfun/iflow-class::obj ::sfun/iflow)
    (inline sfun/iflow-class-set! ::sfun/iflow ::obj)
    (inline sfun/iflow-body::obj ::sfun/iflow)
    (inline sfun/iflow-body-set! ::sfun/iflow ::obj)
    (inline sfun/iflow-args-name::obj ::sfun/iflow)
    (inline sfun/iflow-args::obj ::sfun/iflow)
    (inline sfun/iflow-args-set! ::sfun/iflow ::obj)
    (inline sfun/iflow-property::obj ::sfun/iflow)
    (inline sfun/iflow-property-set! ::sfun/iflow ::obj)
    (inline sfun/iflow-effect::obj ::sfun/iflow)
    (inline sfun/iflow-effect-set! ::sfun/iflow ::obj)
    (inline sfun/iflow-the-closure::obj ::sfun/iflow)
    (inline sfun/iflow-the-closure-set! ::sfun/iflow ::obj)
    (inline sfun/iflow-top?::bool ::sfun/iflow)
    (inline sfun/iflow-top?-set! ::sfun/iflow ::bool)
    (inline sfun/iflow-stack-allocator::obj ::sfun/iflow)
    (inline sfun/iflow-stack-allocator-set! ::sfun/iflow ::obj)
    (inline sfun/iflow-predicate-of::obj ::sfun/iflow)
    (inline sfun/iflow-predicate-of-set! ::sfun/iflow ::obj)
    (inline sfun/iflow-side-effect::obj ::sfun/iflow)
    (inline sfun/iflow-side-effect-set! ::sfun/iflow ::obj)
    (inline sfun/iflow-arity::long ::sfun/iflow)))))

;; The definitions
(cond-expand (bigloo-class-sans
;; sfun/iflow
(define-inline (make-sfun/iflow::sfun/iflow arity1171::long side-effect1172::obj predicate-of1173::obj stack-allocator1174::obj top?1175::bool the-closure1176::obj effect1177::obj property1178::obj args1179::obj args-name1180::obj body1181::obj class1182::obj dsssl-keywords1183::obj loc1184::obj optionals1185::obj keys1186::obj the-closure-global1187::obj strength1188::symbol) (instantiate::sfun/iflow (arity arity1171) (side-effect side-effect1172) (predicate-of predicate-of1173) (stack-allocator stack-allocator1174) (top? top?1175) (the-closure the-closure1176) (effect effect1177) (property property1178) (args args1179) (args-name args-name1180) (body body1181) (class class1182) (dsssl-keywords dsssl-keywords1183) (loc loc1184) (optionals optionals1185) (keys keys1186) (the-closure-global the-closure-global1187) (strength strength1188)))
(define-inline (sfun/iflow?::bool obj::obj) ((@ isa? __object) obj (@ sfun/iflow initflow_walk)))
(define (sfun/iflow-nil::sfun/iflow) (class-nil (@ sfun/iflow initflow_walk)))
(define-inline (sfun/iflow-strength::symbol o::sfun/iflow) (with-access::sfun/iflow o (strength) strength))
(define-inline (sfun/iflow-strength-set! o::sfun/iflow v::symbol) (with-access::sfun/iflow o (strength) (set! strength v)))
(define-inline (sfun/iflow-the-closure-global::obj o::sfun/iflow) (with-access::sfun/iflow o (the-closure-global) the-closure-global))
(define-inline (sfun/iflow-the-closure-global-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (the-closure-global) (set! the-closure-global v)))
(define-inline (sfun/iflow-keys::obj o::sfun/iflow) (with-access::sfun/iflow o (keys) keys))
(define-inline (sfun/iflow-keys-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (keys) (set! keys v)))
(define-inline (sfun/iflow-optionals::obj o::sfun/iflow) (with-access::sfun/iflow o (optionals) optionals))
(define-inline (sfun/iflow-optionals-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (optionals) (set! optionals v)))
(define-inline (sfun/iflow-loc::obj o::sfun/iflow) (with-access::sfun/iflow o (loc) loc))
(define-inline (sfun/iflow-loc-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (loc) (set! loc v)))
(define-inline (sfun/iflow-dsssl-keywords::obj o::sfun/iflow) (with-access::sfun/iflow o (dsssl-keywords) dsssl-keywords))
(define-inline (sfun/iflow-dsssl-keywords-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (dsssl-keywords) (set! dsssl-keywords v)))
(define-inline (sfun/iflow-class::obj o::sfun/iflow) (with-access::sfun/iflow o (class) class))
(define-inline (sfun/iflow-class-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (class) (set! class v)))
(define-inline (sfun/iflow-body::obj o::sfun/iflow) (with-access::sfun/iflow o (body) body))
(define-inline (sfun/iflow-body-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (body) (set! body v)))
(define-inline (sfun/iflow-args-name::obj o::sfun/iflow) (with-access::sfun/iflow o (args-name) args-name))
(define-inline (sfun/iflow-args-name-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (args-name) (set! args-name v)))
(define-inline (sfun/iflow-args::obj o::sfun/iflow) (with-access::sfun/iflow o (args) args))
(define-inline (sfun/iflow-args-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (args) (set! args v)))
(define-inline (sfun/iflow-property::obj o::sfun/iflow) (with-access::sfun/iflow o (property) property))
(define-inline (sfun/iflow-property-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (property) (set! property v)))
(define-inline (sfun/iflow-effect::obj o::sfun/iflow) (with-access::sfun/iflow o (effect) effect))
(define-inline (sfun/iflow-effect-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (effect) (set! effect v)))
(define-inline (sfun/iflow-the-closure::obj o::sfun/iflow) (with-access::sfun/iflow o (the-closure) the-closure))
(define-inline (sfun/iflow-the-closure-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (the-closure) (set! the-closure v)))
(define-inline (sfun/iflow-top?::bool o::sfun/iflow) (with-access::sfun/iflow o (top?) top?))
(define-inline (sfun/iflow-top?-set! o::sfun/iflow v::bool) (with-access::sfun/iflow o (top?) (set! top? v)))
(define-inline (sfun/iflow-stack-allocator::obj o::sfun/iflow) (with-access::sfun/iflow o (stack-allocator) stack-allocator))
(define-inline (sfun/iflow-stack-allocator-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (stack-allocator) (set! stack-allocator v)))
(define-inline (sfun/iflow-predicate-of::obj o::sfun/iflow) (with-access::sfun/iflow o (predicate-of) predicate-of))
(define-inline (sfun/iflow-predicate-of-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (predicate-of) (set! predicate-of v)))
(define-inline (sfun/iflow-side-effect::obj o::sfun/iflow) (with-access::sfun/iflow o (side-effect) side-effect))
(define-inline (sfun/iflow-side-effect-set! o::sfun/iflow v::obj) (with-access::sfun/iflow o (side-effect) (set! side-effect v)))
(define-inline (sfun/iflow-arity::long o::sfun/iflow) (with-access::sfun/iflow o (arity) arity))
(define-inline (sfun/iflow-arity-set! o::sfun/iflow v::long) (with-access::sfun/iflow o (arity) (set! arity v)))
))