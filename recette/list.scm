;*---------------------------------------------------------------------*/
;*    serrano/prgm/project/bigloo/recette/list.scm                     */
;*                                                                     */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Tue Nov  3 09:21:42 1992                          */
;*    Last change :  Mon Mar 21 10:26:49 2011 (serrano)                */
;*                                                                     */
;*    On teste les operations primitives sur les listes                */
;*---------------------------------------------------------------------*/

;*---------------------------------------------------------------------*/
;*    Le module                                                        */
;*---------------------------------------------------------------------*/
(module list
   (import  (main "main.scm"))
   (include "test.sch")
   (export  (test-list))
   (option  (set! *shared-cnst?* #f)))
 
;*---------------------------------------------------------------------*/
;*    test-list ...                                                    */
;*---------------------------------------------------------------------*/
(define (test-list)
   (test-module "list" "list.scm")
   (test "car" (car (list 1 2 3)) 1)
   (test "cdr" (cdr (list 1 2 3)) '(2 3))
   (test "set-car!" (let ((x (cons 1 2))) (set-car! x 0) x) (cons 0 2))
   (test "set-cdr!" (let ((x (cons 1 2))) (set-cdr! x 0) x) (cons 1 0))
   (test "cons" (cons 1 (cons 2 '())) '(1 2))
   (test "epair.1" (epair? (econs 1 2 3)) #t)
   (test "epair.2" (epair? (cons 2 3)) #f)
   (test "epair.3" (pair? (econs 1 2 3)) #t)
   (test "epair.4" (cer (econs 1 2 3)) 3)
   (test "epair.5" (let ((p (econs 1 2 3)))
		    (set-cer! p 4)
		    (cer p))
	 4)
   (test "epair.6" (car (econs 1 2 3)) 1)
   (test "epair.7" (cdr (econs 1 2 3)) 2)
   (test "map.1" (map (lambda (x) (+ 1 x)) '(1 2 3)) '(2 3 4))
   (test "map.2" (map cons '(1 2 3) '(4 5 6)) '((1 . 4) (2 . 5) (3 . 6)))
   (test "map.3" (map list '(1 2 3) '(4 5 6)) '((1 4) (2 5) (3 6)))
   (test "map.4" (map (lambda (a b) (list a b)) '(1 2 3) '(4 5 6))
         '((1 4) (2 5) (3 6)))
   (test "map.5" (map (lambda (a b c) (list a b c)) '(1 2 3) '(4 5 6) '(7 8 9))
         '((1 4 7) (2 5 8) (3 6 9)))
   (test "map.6" (map (lambda (x) x) '()) '())
   (test "map.7" (map car '()) '())
   (test "map.8" (map car '((1))) '(1))
   (test "append-map" (append-map (lambda (x) (list x (- x))) '(1 3 8))
	 '(1 -1 3 -3 8 -8))
   (test "append-map!" (append-map! (lambda (x) (list x (- x))) '(1 3 8))
	 '(1 -1 3 -3 8 -8))
   (test "for-each.1" (begin (for-each (lambda (x) x) '()) #t) #t) 
   (test "for-each.2" (let ((v 0))
		       (for-each (lambda (x) (set! v (+ x v)))
				 '(1 2 3))
		       v)
	 6)
   (test "for-each.3" (let ((v 0))
		       (for-each (lambda (x y) (set! v (+ y x v)))
				 '(1 2 3) '(4 5 6))
		       v)
	 21)
   (test "for-each.4" (let ((v 0))
		       (for-each (lambda (x y z) (set! v (+ y x v z)))
				 '(1 2 3) '(4 5 6) '(7 8 9))
		       v)
	 45)
   (test "filter" (filter number? '(1 2 #\a "foo" foo 3)) '(1 2 3))
   (test "filter!" (let ((l (list 1 2 #\a "foo" 'foo 3)))
		      (set! l (filter! number? l))
		      l) '(1 2 3))
   (test "any?" (any? number? '(1 2 3 4 5 6)) #t)
   (test "any?" (any? number? '(toto 1 2 3 4 5 6)) #t)
   (test "any?" (any? number? '(toto 1 2 3 4 5 6 tutu)) #t)
   (test "any?" (any? number? '(toto tutu)) #f)
   (test "any?" (any? > '(1 2 3 4) '(5 6 7 8)) #f)
   (test "any?" (any? > '(1 2 3 4) '(5 0 7 8)) #t)
   (test "every?" (every? number? '(1 2 3 4 5 6)) #t)
   (test "every?" (every? number? '(toto 1 2 3 4 5 6)) #f)
   (test "every?" (every? number? '(toto 1 2 3 4 5 6 tutu)) #f)
   (test "every?" (every? number? '(toto tutu)) #f)
   (test "every?" (every? > '(1 2 3 4) '(5 6 7 8)) #f)
   (test "every?" (every? > '(5 6 7 8) '(1 2 3 4)) #t)
   (test "reverse" (reverse '(1 2 3 4)) '(4 3 2 1))
   (test "reverse!" (reverse! '(1 2 3 4)) '(4 3 2 1))
   (test "list-tail" (list-tail '(1 2 3 4) 2) '(3 4))
   (test "list-ref" (list-ref '(1 2 (3 4) 5) 2) '(3 4))
   (test "assoc" (assoc 1 '((2 3) (4 5))) #f)
   (test "equal.1" (equal? '(1 2 (3 4 (5) (6 7)) (5 6) "titi"
			     #(1 2 (6 #(6 7)) titi) tutu)
			 '(1 2 (3 4 (5) (6 7)) (5 6) "titi"
			     #(1 2 (6 #(6 7)) titi) tutu))
	 #t)
   (test "equal.2" (equal? '(1 2 (3 4 (5) (6 7)) (5 6) "titi"
			     #(1 2 (6 #(6 7)) titi) tutu)
			 '(1 2 (3 4 (5) (6 7)) (5 6) "titi"
			     #(1 2 (6 #(6 7)) toto) tutu))
	 #f)
   (test "member.1" (member '(1 2 3) '((0 1 2) (1 2 3) (4 5 6)))
	 '((1 2 3) (4 5 6)))
   (test "length" (length '(1 2 3)) 3)
   (test "append.1" (append '(1 2 (3 4)) '((5 6) 7)) '(1 2 (3 4) (5 6) 7))
   (test "append.2" (append '(a b) '(c . d)) '(a b c . d))
   (test "append.3" (append '() 'a)  'a)
   (test "list" (list 1 2 3) '(1 2 3))
   (test "list?.1" (list? '(1 2 . 4)) #f)
   (test "list?.2" (list? '(1 2 3 4)) #t)
   (test "remq" (let ((x '(1 2 3 4))) (remq 2 x)) '(1 3 4))
   (test "remq!" (let ((x '(1 2 3 4))) (remq! 2 x) x) '(1 3 4))
   (test "delete" (let ((x '(1 2 (3 4) 5))) (delete '(3 4) x)) '(1 2 5))
   (test "delete!" (let ((x '(1 2 (3 4) 5))) (delete! '(3 4) x) x) '(1 2 5))
   (test "memq.1" (memq 3 '(1 2 3 4 5)) '(3 4 5))
   (test "memq.2" (memq #\a '(1 2 3 4 5)) #f)
   (test "member.2" (member '(2 3) '((1 2) (2 3) (3 4) (4 5)))
	 '((2 3) (3 4) (4 5)))
   (test "cons*.1" (cons* 1 0) '(1 . 0))
   (test "cons*.2" (cons* (cons* (quote x) 0 (quote ())) (quote ())) '((x 0)))
   (test "make-list.1" (make-list 2) '(#unspecified #unspecified))
   (test "make-list.2" (make-list 10 4) '(4 4 4 4 4 4 4 4 4 4))
   (test "list-tabulate" (list-tabulate 4 values) '(0 1 2 3))
   (test "iota.1" (iota 5) '(0 1 2 3 4))
   (test "iota.2" (iota 5 0 -1.) '(0. -1. -2. -3. -4.))
   (test "delete-duplicates.1" (delete-duplicates '(a b a c a b c z))
	 '(a b c z))
   (test "delete-duplicates.2"
	 (delete-duplicates '((a . 3) (b . 7) (a . 9) (c . 1))
			    (lambda (x y) (eq? (car x) (car y))))
	 '((a . 3) (b . 7) (c . 1))))
