;; ==========================================================
;; Class accessors
;; Bigloo (3.7b)
;; Inria -- Sophia Antipolis     Mon Nov 14 16:42:36 CET 2011 
;; (bigloo.new -classgen Tvector/tvector.scm -o Tvector/tvectortype.sch)
;; ==========================================================

;; The directives
(directives

;; tvec
(cond-expand ((and bigloo-class-sans (not bigloo-class-generate))
  (export
    (inline make-tvec::tvec id1121::symbol name1122::obj size1123::obj class1124::obj coerce-to1125::obj parents1126::obj init?1127::bool magic?1128::bool $1129::obj alias1130::obj pointed-to-by1131::obj tvector1132::obj location1133::obj import-location1134::obj occurrence1135::int item-type1136::type)
    (inline tvec?::bool ::obj)
    (tvec-nil::tvec)
    (inline tvec-item-type::type ::tvec)
    (inline tvec-occurrence::int ::tvec)
    (inline tvec-occurrence-set! ::tvec ::int)
    (inline tvec-import-location::obj ::tvec)
    (inline tvec-import-location-set! ::tvec ::obj)
    (inline tvec-location::obj ::tvec)
    (inline tvec-location-set! ::tvec ::obj)
    (inline tvec-tvector::obj ::tvec)
    (inline tvec-tvector-set! ::tvec ::obj)
    (inline tvec-pointed-to-by::obj ::tvec)
    (inline tvec-pointed-to-by-set! ::tvec ::obj)
    (inline tvec-alias::obj ::tvec)
    (inline tvec-alias-set! ::tvec ::obj)
    (inline tvec-$::obj ::tvec)
    (inline tvec-$-set! ::tvec ::obj)
    (inline tvec-magic?::bool ::tvec)
    (inline tvec-magic?-set! ::tvec ::bool)
    (inline tvec-init?::bool ::tvec)
    (inline tvec-init?-set! ::tvec ::bool)
    (inline tvec-parents::obj ::tvec)
    (inline tvec-parents-set! ::tvec ::obj)
    (inline tvec-coerce-to::obj ::tvec)
    (inline tvec-coerce-to-set! ::tvec ::obj)
    (inline tvec-class::obj ::tvec)
    (inline tvec-class-set! ::tvec ::obj)
    (inline tvec-size::obj ::tvec)
    (inline tvec-size-set! ::tvec ::obj)
    (inline tvec-name::obj ::tvec)
    (inline tvec-name-set! ::tvec ::obj)
    (inline tvec-id::symbol ::tvec)))))

;; The definitions
(cond-expand (bigloo-class-sans
;; tvec
(define-inline (make-tvec::tvec id1121::symbol name1122::obj size1123::obj class1124::obj coerce-to1125::obj parents1126::obj init?1127::bool magic?1128::bool $1129::obj alias1130::obj pointed-to-by1131::obj tvector1132::obj location1133::obj import-location1134::obj occurrence1135::int item-type1136::type) (instantiate::tvec (id id1121) (name name1122) (size size1123) (class class1124) (coerce-to coerce-to1125) (parents parents1126) (init? init?1127) (magic? magic?1128) ($ $1129) (alias alias1130) (pointed-to-by pointed-to-by1131) (tvector tvector1132) (location location1133) (import-location import-location1134) (occurrence occurrence1135) (item-type item-type1136)))
(define-inline (tvec?::bool obj::obj) ((@ isa? __object) obj (@ tvec tvector_tvector)))
(define (tvec-nil::tvec) (class-nil (@ tvec tvector_tvector)))
(define-inline (tvec-item-type::type o::tvec) (with-access::tvec o (item-type) item-type))
(define-inline (tvec-item-type-set! o::tvec v::type) (with-access::tvec o (item-type) (set! item-type v)))
(define-inline (tvec-occurrence::int o::tvec) (with-access::tvec o (occurrence) occurrence))
(define-inline (tvec-occurrence-set! o::tvec v::int) (with-access::tvec o (occurrence) (set! occurrence v)))
(define-inline (tvec-import-location::obj o::tvec) (with-access::tvec o (import-location) import-location))
(define-inline (tvec-import-location-set! o::tvec v::obj) (with-access::tvec o (import-location) (set! import-location v)))
(define-inline (tvec-location::obj o::tvec) (with-access::tvec o (location) location))
(define-inline (tvec-location-set! o::tvec v::obj) (with-access::tvec o (location) (set! location v)))
(define-inline (tvec-tvector::obj o::tvec) (with-access::tvec o (tvector) tvector))
(define-inline (tvec-tvector-set! o::tvec v::obj) (with-access::tvec o (tvector) (set! tvector v)))
(define-inline (tvec-pointed-to-by::obj o::tvec) (with-access::tvec o (pointed-to-by) pointed-to-by))
(define-inline (tvec-pointed-to-by-set! o::tvec v::obj) (with-access::tvec o (pointed-to-by) (set! pointed-to-by v)))
(define-inline (tvec-alias::obj o::tvec) (with-access::tvec o (alias) alias))
(define-inline (tvec-alias-set! o::tvec v::obj) (with-access::tvec o (alias) (set! alias v)))
(define-inline (tvec-$::obj o::tvec) (with-access::tvec o ($) $))
(define-inline (tvec-$-set! o::tvec v::obj) (with-access::tvec o ($) (set! $ v)))
(define-inline (tvec-magic?::bool o::tvec) (with-access::tvec o (magic?) magic?))
(define-inline (tvec-magic?-set! o::tvec v::bool) (with-access::tvec o (magic?) (set! magic? v)))
(define-inline (tvec-init?::bool o::tvec) (with-access::tvec o (init?) init?))
(define-inline (tvec-init?-set! o::tvec v::bool) (with-access::tvec o (init?) (set! init? v)))
(define-inline (tvec-parents::obj o::tvec) (with-access::tvec o (parents) parents))
(define-inline (tvec-parents-set! o::tvec v::obj) (with-access::tvec o (parents) (set! parents v)))
(define-inline (tvec-coerce-to::obj o::tvec) (with-access::tvec o (coerce-to) coerce-to))
(define-inline (tvec-coerce-to-set! o::tvec v::obj) (with-access::tvec o (coerce-to) (set! coerce-to v)))
(define-inline (tvec-class::obj o::tvec) (with-access::tvec o (class) class))
(define-inline (tvec-class-set! o::tvec v::obj) (with-access::tvec o (class) (set! class v)))
(define-inline (tvec-size::obj o::tvec) (with-access::tvec o (size) size))
(define-inline (tvec-size-set! o::tvec v::obj) (with-access::tvec o (size) (set! size v)))
(define-inline (tvec-name::obj o::tvec) (with-access::tvec o (name) name))
(define-inline (tvec-name-set! o::tvec v::obj) (with-access::tvec o (name) (set! name v)))
(define-inline (tvec-id::symbol o::tvec) (with-access::tvec o (id) id))
(define-inline (tvec-id-set! o::tvec v::symbol) (with-access::tvec o (id) (set! id v)))
))