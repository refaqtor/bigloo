;*=====================================================================*/
;*    serrano/prgm/project/bigloo/comptime/Object/struct.scm           */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Thu May 30 11:52:53 1996                          */
;*    Last change :  Wed Nov  9 13:25:16 2011 (serrano)                */
;*    Copyright   :  1996-2011 Manuel Serrano, see LICENSE file        */
;*    -------------------------------------------------------------    */
;*    The object<->struct conversion                                   */
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module object_struct
   (import  tools_error
	    tools_misc
	    type_type
	    type_env
	    type_cache
	    type_tools
	    ast_var
	    ast_env
	    ast_ident
	    tools_error
	    engine_param
	    backend_backend
	    object_class
	    object_tools
	    object_slots
	    ast_private)
   (export  (gen-plain-class<->struct ::type ::pair)
	    (gen-wide-class<->struct ::type ::pair)))

;*---------------------------------------------------------------------*/
;*    gen-plain-class<->struct ...                                     */
;*---------------------------------------------------------------------*/
(define (gen-plain-class<->struct class src-def)
   (with-access::tclass class (id slots abstract?)
      (if (or abstract? (not *optim-object-serialization*))
	  '()
	  (list (gen-struct->plain-class id class slots src-def)))))
   
;*---------------------------------------------------------------------*/
;*    gen-wide-class<->struct ...                                      */
;*---------------------------------------------------------------------*/
(define (gen-wide-class<->struct class src-def)
   (with-access::tclass class (id slots)
      (list (gen-wide-class->struct id class slots src-def)
	 (gen-struct->wide-class id class slots src-def))))
   
;*---------------------------------------------------------------------*/
;*    save-slot ...                                                    */
;*---------------------------------------------------------------------*/
(define (save-slot oname sname cname i slot)
   (define (save-immediat-slot)
      `(struct-set! ,sname
		    ,i
		    (,(symbol-append cname '- (slot-id slot))
		     ,oname)))
   (cond
      ((slot-virtual? slot)
       #unspecified)
      (else
       (save-immediat-slot))))

;*---------------------------------------------------------------------*/
;*    slots-length ...                                                 */
;*---------------------------------------------------------------------*/
(define (slots-length slots)
   (let loop ((slots slots)
	      (len   0))
      (cond
	 ((null? slots)
	  len)
	 ((slot-virtual? (car slots))
	  (loop (cdr slots) len))
	 (else
	  (loop (cdr slots) (+fx 1 len))))))

;*---------------------------------------------------------------------*/
;*    gen-plain-class->struct ...                                      */
;*---------------------------------------------------------------------*/
(define (gen-plain-class->struct cname type slots src-def)
   (let ((len   (+fx 1 (slots-length slots)))
	 (oname (gensym 'obj))
	 (sname (gensym 'res)))
      (epairify
       `(define-method (object->struct::struct ,(make-typed-ident oname cname))
	   (let ((,sname (make-struct ',cname ,len #unspecified)))
	      (begin
		 (struct-set! ,sname 0 #f)
		 ,@(let loop ((i     1)
			      (slots slots)
			      (res   '()))
		      (cond
			 ((=fx i len)
			  (reverse! res))
			 ((slot-virtual? (car slots))
			  (loop (+fx i 1)
				(cdr slots)
				res))
			 (else
			  (loop (+fx i 1)
				(cdr slots)
				(cons (save-slot oname
						 sname
						 cname
						 i
						 (car slots))
				      res)))))
		 ,sname)))
       src-def)))

;*---------------------------------------------------------------------*/
;*    gen-wide-class->struct ...                                       */
;*---------------------------------------------------------------------*/
(define (gen-wide-class->struct cname type slots src-def)
   (let* ((len    (slots-length slots))
	  (oname  (gensym 'obj))
	  (res    (gensym 'res))
	  (tres   (symbol-append res '::struct))
	  (aux    (gensym 'aux)))
      (epairify
       `(define-method (object->struct::struct ,(make-typed-ident oname cname))
	   (let ((,tres (call-next-method)))
	      (let ((,aux (make-struct ',cname ,len #unspecified)))
		 ,@(let loop ((i     0)
			      (slots slots)
			      (res   '()))
		      (cond
			 ((=fx i len)
			  (reverse! res))
			 ((slot-virtual? (car slots))
			  (loop (+fx i 1)
				(cdr slots)
				res))
			 (else
			  (loop (+fx i 1)
				(cdr slots)
				(cons (save-slot oname aux cname i (car slots))
				      res)))))
		 (struct-set! ,res 0 ,aux)
		 ;; we now swap the structures' keys
		 (struct-key-set! ,aux (struct-key ,res))
		 (struct-key-set! ,res ',cname)
		 ;; and we return res
		 ,res)))
       src-def)))

;*---------------------------------------------------------------------*/
;*    restore-slot ...                                                 */
;*---------------------------------------------------------------------*/
(define (restore-slot oname sname cname type i slot)
   (let* ((loop          (gensym 'loop))
	  (runner        (gensym 'i))
	  (v             (gensym 'v))
	  (len           (gensym 'len))
	  (runner-typed  (symbol-append runner '::long))) 
      (cond
	 ((slot-virtual? slot)
	  #unspecified)
	 (else
	  `(let ((,(make-typed-ident v (type-id (slot-type slot)))
		  (struct-ref s ,i)))
	      ,(make-direct-set! type slot 'o v))))))

;*---------------------------------------------------------------------*/
;*    gen-struct->plain-class ...                                      */
;*    -------------------------------------------------------------    */
;*    This function fills `object' and returns it.                     */
;*    -------------------------------------------------------------    */
;*    This function is very similar to the make-object function        */
;*    execpted that it founds the value in the structure rather than   */
;*    being provided as actual values.                                 */
;*---------------------------------------------------------------------*/
(define (gen-struct->plain-class cname type slots src-def)
   (epairify
    `(define-method (struct+object->object::object ,(make-typed-ident 'o cname)
						   s::struct)
	(begin
	   (object-widening-set! o (struct-ref s 0))
	   ,@(let loop ((i     1)
			(slots slots)
			(res   '()))
		(cond
		   ((null? slots)
		    (reverse! res))
		   ((slot-virtual? (car slots))
		    (loop (+fx i 1)
			  (cdr slots)
			  res))
		   (else
		    (let ((new (restore-slot 'o 's cname type i (car slots))))
		       (loop (+fx i 1)
			     (cdr slots)
			     (cons new res))))))
	   o))
    src-def))

;*---------------------------------------------------------------------*/
;*    gen-struct->wide-class ...                                       */
;*---------------------------------------------------------------------*/
(define (gen-struct->wide-class cname type slots src-def)
   (let* ((old       (gensym 'old))
	  (len       (slots-length slots))
	  (aux       (gensym 'aux))
	  (taux      (symbol-append aux '::struct))
	  (new       (gensym 'new))
	  (tid       (type-id type))
	  (holder    (tclass-holder type))
	  (widening  (symbol-append (tclass-widening type) '- tid))
	  (super     (tclass-its-super type))
	  (sname     (type-id super)))
      (define (cast type expr)
	 (if (backend-pragma-support (the-backend))
	     `(,(make-typed-ident 'pragma (type-id type))
	       ,(string-append "((" (type-name type) ")($1))")
	       ,expr)
	     (make-private-sexp 'cast (type-id type) expr)))
      (epairify
	 `(define-method (struct+object->object::object
			    ,(make-typed-ident 'o cname)
			    s::struct)
	     (let ((,old ,(cast (tclass-its-super type) 'o)))
		,@(let loop ((i 1)
			     (slots (tclass-all-slots (tclass-its-super type)))
			     (res '()))
		     (cond
			((null? slots)
			 (reverse! res))
			((slot-virtual? (car slots))
			 (loop (+fx i 1)
			    (cdr slots)
			    res))
			(else
			 (let ((new (restore-slot old 's sname super i (car slots))))
			    (loop (+fx i 1)
			       (cdr slots)
			       (cons new res)))))))
	     (let ((,taux (struct-ref s 0)))
		(object-class-num-set! o
		   (class-num
		      (@ ,(global-id holder)
			 ,(global-module holder))))
		(object-widening-set!
		   o
		   (,widening ,@(let loop ((i 0)
					   (slots slots)
					   (ref*  '()))
				   (cond
				      ((=fx i len)
				       (reverse! ref*))
				      ((slot-virtual? (car slots))
				       (loop (+fx i 1)
					  (cdr slots)
					  ref*))
				      (else
				       (loop (+fx i 1)
					  (cdr slots)
					  (cons `(struct-ref ,aux ,i)
					     ref*)))))))
		o))
	 src-def)))

	  
	  
