;; ==========================================================
;; Class accessors
;; Bigloo (3.7b)
;; Inria -- Sophia Antipolis     Mon Nov 14 18:35:27 CET 2011 
;; (bigloo.new -classgen SawMill/regalloc.scm)
;; ==========================================================

;; The directives
(directives

;; block/ra
(cond-expand ((and bigloo-class-sans (not bigloo-class-generate))
  (static
    (inline make-block/ra::block/ra label1260::int preds1261::pair-nil succs1262::pair-nil first1263::pair trsif1264::pair-nil)
    (inline block/ra?::bool ::obj)
    (block/ra-nil::block/ra)
    (inline block/ra-trsif::pair-nil ::block/ra)
    (inline block/ra-trsif-set! ::block/ra ::pair-nil)
    (inline block/ra-first::pair ::block/ra)
    (inline block/ra-first-set! ::block/ra ::pair)
    (inline block/ra-succs::pair-nil ::block/ra)
    (inline block/ra-succs-set! ::block/ra ::pair-nil)
    (inline block/ra-preds::pair-nil ::block/ra)
    (inline block/ra-preds-set! ::block/ra ::pair-nil)
    (inline block/ra-label::int ::block/ra)
    (inline block/ra-label-set! ::block/ra ::int))))

;; rtl_ins/ra
(cond-expand ((and bigloo-class-sans (not bigloo-class-generate))
  (static
    (inline make-rtl_ins/ra::rtl_ins/ra loc1250::obj %spill1251::pair-nil dest1252::obj fun1253::rtl_fun args1254::pair-nil def1255::obj out1256::obj in1257::obj spill1258::obj)
    (inline rtl_ins/ra?::bool ::obj)
    (rtl_ins/ra-nil::rtl_ins/ra)
    (inline rtl_ins/ra-spill::obj ::rtl_ins/ra)
    (inline rtl_ins/ra-spill-set! ::rtl_ins/ra ::obj)
    (inline rtl_ins/ra-in::obj ::rtl_ins/ra)
    (inline rtl_ins/ra-in-set! ::rtl_ins/ra ::obj)
    (inline rtl_ins/ra-out::obj ::rtl_ins/ra)
    (inline rtl_ins/ra-out-set! ::rtl_ins/ra ::obj)
    (inline rtl_ins/ra-def::obj ::rtl_ins/ra)
    (inline rtl_ins/ra-def-set! ::rtl_ins/ra ::obj)
    (inline rtl_ins/ra-args::pair-nil ::rtl_ins/ra)
    (inline rtl_ins/ra-args-set! ::rtl_ins/ra ::pair-nil)
    (inline rtl_ins/ra-fun::rtl_fun ::rtl_ins/ra)
    (inline rtl_ins/ra-fun-set! ::rtl_ins/ra ::rtl_fun)
    (inline rtl_ins/ra-dest::obj ::rtl_ins/ra)
    (inline rtl_ins/ra-dest-set! ::rtl_ins/ra ::obj)
    (inline rtl_ins/ra-%spill::pair-nil ::rtl_ins/ra)
    (inline rtl_ins/ra-%spill-set! ::rtl_ins/ra ::pair-nil)
    (inline rtl_ins/ra-loc::obj ::rtl_ins/ra)
    (inline rtl_ins/ra-loc-set! ::rtl_ins/ra ::obj))))

;; rtl_reg/ra
(cond-expand ((and bigloo-class-sans (not bigloo-class-generate))
  (export
    (inline make-rtl_reg/ra::rtl_reg/ra type1237::type var1238::obj onexpr?1239::obj name1240::obj key1241::obj hardware1242::obj num1243::int color1244::obj coalesce1245::obj occurrences1246::int interfere1247::obj interfere21248::obj)
    (inline rtl_reg/ra?::bool ::obj)
    (rtl_reg/ra-nil::rtl_reg/ra)
    (inline rtl_reg/ra-interfere2::obj ::rtl_reg/ra)
    (inline rtl_reg/ra-interfere2-set! ::rtl_reg/ra ::obj)
    (inline rtl_reg/ra-interfere::obj ::rtl_reg/ra)
    (inline rtl_reg/ra-interfere-set! ::rtl_reg/ra ::obj)
    (inline rtl_reg/ra-occurrences::int ::rtl_reg/ra)
    (inline rtl_reg/ra-occurrences-set! ::rtl_reg/ra ::int)
    (inline rtl_reg/ra-coalesce::obj ::rtl_reg/ra)
    (inline rtl_reg/ra-coalesce-set! ::rtl_reg/ra ::obj)
    (inline rtl_reg/ra-color::obj ::rtl_reg/ra)
    (inline rtl_reg/ra-color-set! ::rtl_reg/ra ::obj)
    (inline rtl_reg/ra-num::int ::rtl_reg/ra)
    (inline rtl_reg/ra-hardware::obj ::rtl_reg/ra)
    (inline rtl_reg/ra-key::obj ::rtl_reg/ra)
    (inline rtl_reg/ra-name::obj ::rtl_reg/ra)
    (inline rtl_reg/ra-onexpr?::obj ::rtl_reg/ra)
    (inline rtl_reg/ra-onexpr?-set! ::rtl_reg/ra ::obj)
    (inline rtl_reg/ra-var::obj ::rtl_reg/ra)
    (inline rtl_reg/ra-var-set! ::rtl_reg/ra ::obj)
    (inline rtl_reg/ra-type::type ::rtl_reg/ra)
    (inline rtl_reg/ra-type-set! ::rtl_reg/ra ::type)))))

;; The definitions
(cond-expand (bigloo-class-sans
;; block/ra
(define-inline (make-block/ra::block/ra label1260::int preds1261::pair-nil succs1262::pair-nil first1263::pair trsif1264::pair-nil) (instantiate::block/ra (label label1260) (preds preds1261) (succs succs1262) (first first1263) (trsif trsif1264)))
(define-inline (block/ra?::bool obj::obj) ((@ isa? __object) obj (@ block/ra saw_register-allocation)))
(define (block/ra-nil::block/ra) (class-nil (@ block/ra saw_register-allocation)))
(define-inline (block/ra-trsif::pair-nil o::block/ra) (with-access::block/ra o (trsif) trsif))
(define-inline (block/ra-trsif-set! o::block/ra v::pair-nil) (with-access::block/ra o (trsif) (set! trsif v)))
(define-inline (block/ra-first::pair o::block/ra) (with-access::block/ra o (first) first))
(define-inline (block/ra-first-set! o::block/ra v::pair) (with-access::block/ra o (first) (set! first v)))
(define-inline (block/ra-succs::pair-nil o::block/ra) (with-access::block/ra o (succs) succs))
(define-inline (block/ra-succs-set! o::block/ra v::pair-nil) (with-access::block/ra o (succs) (set! succs v)))
(define-inline (block/ra-preds::pair-nil o::block/ra) (with-access::block/ra o (preds) preds))
(define-inline (block/ra-preds-set! o::block/ra v::pair-nil) (with-access::block/ra o (preds) (set! preds v)))
(define-inline (block/ra-label::int o::block/ra) (with-access::block/ra o (label) label))
(define-inline (block/ra-label-set! o::block/ra v::int) (with-access::block/ra o (label) (set! label v)))

;; rtl_ins/ra
(define-inline (make-rtl_ins/ra::rtl_ins/ra loc1250::obj %spill1251::pair-nil dest1252::obj fun1253::rtl_fun args1254::pair-nil def1255::obj out1256::obj in1257::obj spill1258::obj) (instantiate::rtl_ins/ra (loc loc1250) (%spill %spill1251) (dest dest1252) (fun fun1253) (args args1254) (def def1255) (out out1256) (in in1257) (spill spill1258)))
(define-inline (rtl_ins/ra?::bool obj::obj) ((@ isa? __object) obj (@ rtl_ins/ra saw_register-allocation)))
(define (rtl_ins/ra-nil::rtl_ins/ra) (class-nil (@ rtl_ins/ra saw_register-allocation)))
(define-inline (rtl_ins/ra-spill::obj o::rtl_ins/ra) (with-access::rtl_ins/ra o (spill) spill))
(define-inline (rtl_ins/ra-spill-set! o::rtl_ins/ra v::obj) (with-access::rtl_ins/ra o (spill) (set! spill v)))
(define-inline (rtl_ins/ra-in::obj o::rtl_ins/ra) (with-access::rtl_ins/ra o (in) in))
(define-inline (rtl_ins/ra-in-set! o::rtl_ins/ra v::obj) (with-access::rtl_ins/ra o (in) (set! in v)))
(define-inline (rtl_ins/ra-out::obj o::rtl_ins/ra) (with-access::rtl_ins/ra o (out) out))
(define-inline (rtl_ins/ra-out-set! o::rtl_ins/ra v::obj) (with-access::rtl_ins/ra o (out) (set! out v)))
(define-inline (rtl_ins/ra-def::obj o::rtl_ins/ra) (with-access::rtl_ins/ra o (def) def))
(define-inline (rtl_ins/ra-def-set! o::rtl_ins/ra v::obj) (with-access::rtl_ins/ra o (def) (set! def v)))
(define-inline (rtl_ins/ra-args::pair-nil o::rtl_ins/ra) (with-access::rtl_ins/ra o (args) args))
(define-inline (rtl_ins/ra-args-set! o::rtl_ins/ra v::pair-nil) (with-access::rtl_ins/ra o (args) (set! args v)))
(define-inline (rtl_ins/ra-fun::rtl_fun o::rtl_ins/ra) (with-access::rtl_ins/ra o (fun) fun))
(define-inline (rtl_ins/ra-fun-set! o::rtl_ins/ra v::rtl_fun) (with-access::rtl_ins/ra o (fun) (set! fun v)))
(define-inline (rtl_ins/ra-dest::obj o::rtl_ins/ra) (with-access::rtl_ins/ra o (dest) dest))
(define-inline (rtl_ins/ra-dest-set! o::rtl_ins/ra v::obj) (with-access::rtl_ins/ra o (dest) (set! dest v)))
(define-inline (rtl_ins/ra-%spill::pair-nil o::rtl_ins/ra) (with-access::rtl_ins/ra o (%spill) %spill))
(define-inline (rtl_ins/ra-%spill-set! o::rtl_ins/ra v::pair-nil) (with-access::rtl_ins/ra o (%spill) (set! %spill v)))
(define-inline (rtl_ins/ra-loc::obj o::rtl_ins/ra) (with-access::rtl_ins/ra o (loc) loc))
(define-inline (rtl_ins/ra-loc-set! o::rtl_ins/ra v::obj) (with-access::rtl_ins/ra o (loc) (set! loc v)))

;; rtl_reg/ra
(define-inline (make-rtl_reg/ra::rtl_reg/ra type1237::type var1238::obj onexpr?1239::obj name1240::obj key1241::obj hardware1242::obj num1243::int color1244::obj coalesce1245::obj occurrences1246::int interfere1247::obj interfere21248::obj) (instantiate::rtl_reg/ra (type type1237) (var var1238) (onexpr? onexpr?1239) (name name1240) (key key1241) (hardware hardware1242) (num num1243) (color color1244) (coalesce coalesce1245) (occurrences occurrences1246) (interfere interfere1247) (interfere2 interfere21248)))
(define-inline (rtl_reg/ra?::bool obj::obj) ((@ isa? __object) obj (@ rtl_reg/ra saw_register-allocation)))
(define (rtl_reg/ra-nil::rtl_reg/ra) (class-nil (@ rtl_reg/ra saw_register-allocation)))
(define-inline (rtl_reg/ra-interfere2::obj o::rtl_reg/ra) (with-access::rtl_reg/ra o (interfere2) interfere2))
(define-inline (rtl_reg/ra-interfere2-set! o::rtl_reg/ra v::obj) (with-access::rtl_reg/ra o (interfere2) (set! interfere2 v)))
(define-inline (rtl_reg/ra-interfere::obj o::rtl_reg/ra) (with-access::rtl_reg/ra o (interfere) interfere))
(define-inline (rtl_reg/ra-interfere-set! o::rtl_reg/ra v::obj) (with-access::rtl_reg/ra o (interfere) (set! interfere v)))
(define-inline (rtl_reg/ra-occurrences::int o::rtl_reg/ra) (with-access::rtl_reg/ra o (occurrences) occurrences))
(define-inline (rtl_reg/ra-occurrences-set! o::rtl_reg/ra v::int) (with-access::rtl_reg/ra o (occurrences) (set! occurrences v)))
(define-inline (rtl_reg/ra-coalesce::obj o::rtl_reg/ra) (with-access::rtl_reg/ra o (coalesce) coalesce))
(define-inline (rtl_reg/ra-coalesce-set! o::rtl_reg/ra v::obj) (with-access::rtl_reg/ra o (coalesce) (set! coalesce v)))
(define-inline (rtl_reg/ra-color::obj o::rtl_reg/ra) (with-access::rtl_reg/ra o (color) color))
(define-inline (rtl_reg/ra-color-set! o::rtl_reg/ra v::obj) (with-access::rtl_reg/ra o (color) (set! color v)))
(define-inline (rtl_reg/ra-num::int o::rtl_reg/ra) (with-access::rtl_reg/ra o (num) num))
(define-inline (rtl_reg/ra-num-set! o::rtl_reg/ra v::int) (with-access::rtl_reg/ra o (num) (set! num v)))
(define-inline (rtl_reg/ra-hardware::obj o::rtl_reg/ra) (with-access::rtl_reg/ra o (hardware) hardware))
(define-inline (rtl_reg/ra-hardware-set! o::rtl_reg/ra v::obj) (with-access::rtl_reg/ra o (hardware) (set! hardware v)))
(define-inline (rtl_reg/ra-key::obj o::rtl_reg/ra) (with-access::rtl_reg/ra o (key) key))
(define-inline (rtl_reg/ra-key-set! o::rtl_reg/ra v::obj) (with-access::rtl_reg/ra o (key) (set! key v)))
(define-inline (rtl_reg/ra-name::obj o::rtl_reg/ra) (with-access::rtl_reg/ra o (name) name))
(define-inline (rtl_reg/ra-name-set! o::rtl_reg/ra v::obj) (with-access::rtl_reg/ra o (name) (set! name v)))
(define-inline (rtl_reg/ra-onexpr?::obj o::rtl_reg/ra) (with-access::rtl_reg/ra o (onexpr?) onexpr?))
(define-inline (rtl_reg/ra-onexpr?-set! o::rtl_reg/ra v::obj) (with-access::rtl_reg/ra o (onexpr?) (set! onexpr? v)))
(define-inline (rtl_reg/ra-var::obj o::rtl_reg/ra) (with-access::rtl_reg/ra o (var) var))
(define-inline (rtl_reg/ra-var-set! o::rtl_reg/ra v::obj) (with-access::rtl_reg/ra o (var) (set! var v)))
(define-inline (rtl_reg/ra-type::type o::rtl_reg/ra) (with-access::rtl_reg/ra o (type) type))
(define-inline (rtl_reg/ra-type-set! o::rtl_reg/ra v::type) (with-access::rtl_reg/ra o (type) (set! type v)))
))