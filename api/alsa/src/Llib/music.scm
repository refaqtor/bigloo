;*=====================================================================*/
;*    serrano/prgm/project/bigloo/api/alsa/src/Llib/music.scm          */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Sat Jun 25 06:55:51 2011                          */
;*    Last change :  Tue Sep 20 08:01:20 2011 (serrano)                */
;*    Copyright   :  2011 Manuel Serrano                               */
;*    -------------------------------------------------------------    */
;*    A (multimedia) music player.                                     */
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module __alsa_music
   
   (library multimedia)
   
   (import  __alsa_alsa
	    __alsa_pcm)

   (export  (class alsamusic::music
	       (%decoder (default #f))
	       (%playlist::pair-nil (default '()))
	       (%thread::obj (default #f))
	       (%amutex::mutex read-only (default (make-mutex)))
	       (%acondv::condvar read-only (default (make-condition-variable)))
	       (%toseek::long (default 0))
	       (%buffer::obj (default #f))
	       (mkthread::procedure read-only (default make-thread))
	       (inbuf::bstring read-only (default (make-string (*fx 512 1024))))
	       (outbuf::bstring read-only (default (make-string (*fx 5 1024))))
	       (pcm::alsa-snd-pcm read-only (default (instantiate::alsa-snd-pcm)))
	       (decoders::pair-nil (default '())))

	    (class alsabuffer
	       (port::input-port read-only)
	       (readsz::long read-only (default 8192))
	       ;; the state is either empty:0, filled:1, full:2, stop:3, or ended:4
	       (%!bstate::int (default 0))
	       (%eof::bool (default #f))
	       (%bcondv::condvar read-only (default (make-condition-variable)))
	       (%bmutex::mutex read-only (default (make-mutex)))
	       (%inbuf::bstring read-only)
	       (%head::long (default 0))
	       (%!tail::long (default 0))
	       (profile-lock::long (default 0)))
	    
	    (class alsadecoder
	       (alsadecoder-init)
	       (mimetypes::pair-nil (default '()))
	       (%!pause::bool (default #f))
	       (%dmutex::mutex read-only (default (make-mutex)))
	       (%dcondv::condvar read-only (default (make-condition-variable))))
	    
	    (generic alsabuffer-fill! ::alsabuffer ::long)
	    (generic alsabuffer-assert ::alsabuffer ::bstring)
	    
	    (generic alsadecoder-init ::alsadecoder)
	    (generic alsadecoder-reset! ::alsadecoder)
	    (generic alsadecoder-close ::alsadecoder)
	    (generic alsadecoder-can-play-type? ::alsadecoder ::bstring)
	    (generic alsadecoder-decode ::alsadecoder ::alsamusic ::alsabuffer)
	    (generic alsadecoder-stop ::obj ::alsamusic)
	    
	    (generic alsadecoder-position::long ::alsadecoder ::bstring)
	    (generic alsadecoder-info::long ::alsadecoder)
	    (generic alsadecoder-seek::long ::alsadecoder ::long)
	    (generic alsadecoder-volume-set! ::alsadecoder ::long)))

;*---------------------------------------------------------------------*/
;*    $compiler-debug ...                                              */
;*---------------------------------------------------------------------*/
(define-macro ($compiler-debug)
   (bigloo-compiler-debug))

;*---------------------------------------------------------------------*/
;*    debug                                                            */
;*---------------------------------------------------------------------*/
(define debug ($compiler-debug))

;*---------------------------------------------------------------------*/
;*    music-init ::alsamusic ...                                       */
;*---------------------------------------------------------------------*/
(define-method (music-init o::alsamusic)
   (with-access::alsamusic o (%amutex %status inbuf outbuf)
      (with-lock %amutex
	 (lambda ()
	    (cond
	       ((<fx (string-length outbuf) 1024)
		(raise (instantiate::&alsa-error
			  (proc "alsamusic")
			  (msg "outbuf must be at least 1024 bytes")
			  (obj (string-length inbuf)))))
	       ((<fx (string-length inbuf) (string-length outbuf))
		(raise (instantiate::&alsa-error
			  (proc "alsamusic")
			  (msg "inbuf length must be greater that outbuf length")
			  (obj (cons (string-length inbuf) (string-length outbuf) ))))))
	    (musicstatus-volume-set! %status 100)
	    (musicstatus-state-set! %status 'uninitialized)))))

;*---------------------------------------------------------------------*/
;*    music-close ::alsamusic ...                                      */
;*---------------------------------------------------------------------*/
(define-method (music-close o::alsamusic)
   (unless (music-closed? o)
      (with-access::alsamusic o (pcm decoders)
	 (unless (eq? (alsa-snd-pcm-get-state pcm) 'not-open)
	    (alsa-snd-pcm-close pcm)
	    (for-each alsadecoder-close decoders)))))

;*---------------------------------------------------------------------*/
;*    music-closed? ::alsamusic ...                                    */
;*---------------------------------------------------------------------*/
(define-method (music-closed? o::alsamusic)
   (with-access::alsamusic o (pcm)
      (eq? (alsa-snd-pcm-get-state pcm) 'disconnected)))

;*---------------------------------------------------------------------*/
;*    music-reset! ::alsamusic ...                                     */
;*---------------------------------------------------------------------*/
(define-method (music-reset! o::alsamusic)
   (with-access::alsamusic o (pcm %amutex %status)
      (unless (eq? (alsa-snd-pcm-get-state pcm) 'not-open)
	 (alsa-snd-pcm-drop pcm)
	 (alsa-snd-pcm-reset pcm)
	 (musicstatus-state-set! %status 'stop)))
   o)

;*---------------------------------------------------------------------*/
;*    music-playlist-get ::alsamusic ...                               */
;*---------------------------------------------------------------------*/
(define-method (music-playlist-get o::alsamusic)
   (with-access::alsamusic o (%playlist)
      %playlist))

;*---------------------------------------------------------------------*/
;*    music-playlist-add! ::alsamusic ...                              */
;*---------------------------------------------------------------------*/
(define-method (music-playlist-add! o::alsamusic s)
   (with-access::alsamusic o (%amutex %playlist %status)
      (with-lock %amutex
	 (lambda ()
	    (set! %playlist (append! %playlist (list s)))
	    (with-access::musicstatus %status (playlistid playlistlength)
	       (set! playlistid (+fx 1 playlistid))
	       (set! playlistlength (+fx 1 playlistlength)))))))

;*---------------------------------------------------------------------*/
;*    music-playlist-delete! ::alsamusic ...                           */
;*---------------------------------------------------------------------*/
(define-method (music-playlist-delete! o::alsamusic n)
   (with-access::alsamusic o (%amutex %playlist %status)
      (with-lock %amutex
	 (lambda ()
	    (with-access::musicstatus %status (playlistid playlistlength)
	       (when (and (>=fx n 0) (<fx n playlistlength))
		  (set! %playlist (remq! (list-ref %playlist n) %playlist))
		  (set! playlistid (+fx 1 playlistid))
		  (set! playlistlength (length %playlist))))))))

;*---------------------------------------------------------------------*/
;*    music-playlist-clear! ::alsamusic ...                            */
;*---------------------------------------------------------------------*/
(define-method (music-playlist-clear! o::alsamusic)
   (with-access::alsamusic o (%amutex %playlist %status)
      (with-lock %amutex
	 (lambda ()
	    (set! %playlist '())
	    (with-access::musicstatus %status (playlistlength song)
	       (set! song 0)
	       (set! playlistlength 0))))))

;*---------------------------------------------------------------------*/
;*    music-status ...                                                 */
;*---------------------------------------------------------------------*/
(define-method (music-status o::alsamusic)
   (with-access::alsamusic o (%status)
      %status))

;*---------------------------------------------------------------------*/
;*    music-update-status! ::mpg123 ...                                */
;*---------------------------------------------------------------------*/
(define-method (music-update-status! o::alsamusic status)
   (with-access::alsamusic o (%amutex %status)
      (with-lock %amutex
	 (lambda ()
	    (musicstatus-volume-set! status (musicstatus-volume %status))
	    (musicstatus-state-set! status (musicstatus-state %status))
	    (musicstatus-repeat-set! status (musicstatus-repeat %status))
	    (musicstatus-random-set! status (musicstatus-random %status))
	    (musicstatus-playlistid-set! status (musicstatus-playlistid %status))
	    (musicstatus-playlistlength-set! status (musicstatus-playlistlength %status))
	    (musicstatus-xfade-set! status (musicstatus-xfade %status))
	    (musicstatus-song-set! status (musicstatus-song %status))
	    (musicstatus-songid-set! status (musicstatus-songid %status))
	    (musicstatus-songpos-set! status (musicstatus-songpos %status))
	    (musicstatus-songlength-set! status (musicstatus-songlength %status))
	    (musicstatus-bitrate-set! status (musicstatus-bitrate %status))
	    (musicstatus-khz-set! status (musicstatus-khz %status))
	    (musicstatus-err-set! status (musicstatus-err %status))))))

;*---------------------------------------------------------------------*/
;*    music-can-play-type? ::alsamusic ...                             */
;*---------------------------------------------------------------------*/
(define-method (music-can-play-type? o::alsamusic mimetype::bstring)
   (with-access::alsamusic o (decoders)
      (any (lambda (d) (alsadecoder-can-play-type? d mimetype)) decoders)))
   
;*---------------------------------------------------------------------*/
;*    music-play ::alsamusic ...                                       */
;*---------------------------------------------------------------------*/
(define-method (music-play o::alsamusic . s)
   (with-access::alsamusic o (%amutex %status %playlist %amutex %decoder)
      (with-access::musicstatus %status (song playlistlength state)
	 (mutex-lock! %amutex)
	 (cond
	    ((eq? state 'pause)
	     (mutex-unlock! %amutex)
	     (music-pause o))
	    ((pair? s)
	     (unless (integer? (car s))
		(bigloo-type-error "music-play ::alsamusic" 'int (car s)))
	     (unwind-protect
		(begin
		   (alsadecoder-stop %decoder o)
		   (playlist-play! o (car s)))
		(mutex-unlock! %amutex)))
	    ((and (>=fx song 0) (<fx song playlistlength))
	     (unwind-protect
		(begin
		   (alsadecoder-stop %decoder o)
		   (playlist-play! o song))
		(mutex-unlock! %amutex)))))))

;*---------------------------------------------------------------------*/
;*    music-seek ...                                                   */
;*---------------------------------------------------------------------*/
(define-method (music-seek o::alsamusic pos . song)
   (with-access::alsamusic o (%amutex %decoder %toseek)
      (with-lock %amutex
	 (lambda ()
	    (if (pair? song)
		(begin
		   (unless (integer? (car song))
		      (bigloo-type-error '|music-seek ::alsamusic| 'int (car song)))
		   (set! %toseek pos)
		   (music-play o song))
		(alsadecoder-seek %decoder pos))))))

;*---------------------------------------------------------------------*/
;*    mime-type ...                                                    */
;*---------------------------------------------------------------------*/
(define (mime-type path)
   (cond
      ((string-suffix? ".mp3" path) "audio/mpeg")
      ((string-suffix? ".ogg" path) "application/ogg")
      ((string-suffix? ".flac" path) "application/x-flac")
      ((string-suffix? ".wav" path) "audio/x-wav")
      ((string-suffix? ".swf" path) "application/x-shockwave-flash")
      ((string-suffix? ".swfl" path) "application/x-shockwave-flash")
      (else "audio/binary")))

;*---------------------------------------------------------------------*/
;*    playlist-play! ...                                               */
;*---------------------------------------------------------------------*/
(define (playlist-play! o::alsamusic n)

   (define (ehandler/sans-lock e)
      (with-access::alsamusic o (%status)
	 (musicstatus-state-set! %status 'error)
	 (musicstatus-err-set! %status e)))
   
   (define (ehandler e)
      (with-access::alsamusic o (%amutex)
	 (mutex-lock! %amutex)
	 (ehandler/sans-lock e)
	 (mutex-unlock! %amutex)))
   
   (define (play o::alsamusic d::alsadecoder p::input-port)
      (with-access::alsamusic o (%buffer %decoder inbuf outbuf mkthread)
	 (when (alsadecoder? %decoder)
	    (alsadecoder-reset! %decoder))
	 (set! %decoder d)
	 (let ((buffer (instantiate::alsabuffer
			  (port p)
			  (%inbuf inbuf))))
	    (set! %buffer buffer)
	    (thread-start!
	       (mkthread
		  (lambda ()
		     (alsabuffer-fill! buffer (string-length outbuf)))
		  (gensym 'alsamusic-buffer)))
	    (thread-start!
	       (mkthread
		  (lambda ()
		     (with-handler
			ehandler
			(alsadecoder-decode d o buffer)))
		  (gensym 'alsamusic-decoder))))))
   
   (with-access::alsamusic o (%playlist %status %decoder decoders pcm)
      (when (eq? (alsa-snd-pcm-get-state pcm) 'not-open)
	 (alsa-snd-pcm-open pcm))
      (when (and (>=fx n 0) (<fx n (length %playlist)))
	 (let* ((url (list-ref %playlist n))
		(mime (mime-type url)))
	    (with-access::musicstatus %status (state song songpos songlength songid playlistid)
	       (set! songpos 0)
	       (set! songlength 0)
	       (set! song n)
	       (set! songid (+fx (* 10000 playlistid) n))
	       (let loop ((decoders decoders))
		  (if (pair? decoders)
		      (let ((d (car decoders)))
			 (if (alsadecoder-can-play-type? d mime)
			     (begin
				(let ((p (open-input-file url)))
				   (if (input-port? p)
				       (begin
					  (set! state 'init)
					  (play o d p)
					  (with-access::alsamusic o
						(%loop-mutex %loop-condv)
					     (with-lock %loop-mutex
						(lambda ()
						   (condition-variable-broadcast! %loop-condv)))))
				       (let ((e (instantiate::&io-port-error
						   (proc "music-play")
						   (msg "Cannot open")
						   (obj url))))
					  (ehandler/sans-lock e)
					  (raise e)))))
			     (loop (cdr decoders))))
		      (set! state 'skip))))))))

;*---------------------------------------------------------------------*/
;*    music-stop ::alsamusic ...                                       */
;*---------------------------------------------------------------------*/
(define-method (music-stop o::alsamusic)
   (with-access::alsamusic o (%amutex %decoder pcm)
      (with-lock %amutex
	 (lambda ()
	    (unless (eq? (alsa-snd-pcm-get-state pcm) 'not-open)
	       (alsadecoder-stop %decoder o))))))

;*---------------------------------------------------------------------*/
;*    alsadecoder-stop ...                                             */
;*---------------------------------------------------------------------*/
(define-generic (alsadecoder-stop dec::obj o)
   (when (alsadecoder? dec)
      (with-access::alsadecoder dec (%dmutex %dcondv %!pause)
	 (mutex-lock! %dmutex)
	 (when %!pause
	    (set! %!pause #f)
	    (condition-variable-broadcast! %dcondv))
	 (mutex-unlock! %dmutex)))
   (with-access::alsamusic o (%amutex %buffer %status pcm)
      (when (alsabuffer? %buffer)
	 (with-access::alsabuffer %buffer (%bmutex %bcondv %!bstate)
	    (mutex-lock! %bmutex)
	    (unless (>=fx %!bstate 3)
	       (set! %!bstate 3)
	       (condition-variable-broadcast! %bcondv)
	       (condition-variable-wait! %bcondv %bmutex))
	    (mutex-unlock! %bmutex)))))

;*---------------------------------------------------------------------*/
;*    music-pause ...                                                  */
;*---------------------------------------------------------------------*/
(define-method (music-pause o::alsamusic)
   (with-access::alsamusic o (%decoder)
      (with-access::alsadecoder %decoder (%dmutex %dcondv %!pause)
	 (mutex-lock! %dmutex)
	 (if %!pause
	     (begin
		(set! %!pause #f)
		(condition-variable-broadcast! %dcondv))
	     (set! %!pause #t))
	 (mutex-unlock! %dmutex))))

;*---------------------------------------------------------------------*/
;*    alsabuffer-assert ...                                            */
;*---------------------------------------------------------------------*/
(define-generic (alsabuffer-assert buffer::alsabuffer proc)
   (with-access::alsabuffer buffer (%!tail %head %inbuf)
      (define inlen (string-length %inbuf))
      (define (err msg)
	 (error proc msg `(%!tail: ,%!tail %head: ,%head inlen: ,inlen)))
      (cond
	 ((<fx %!tail 0)
	  (err "negative %!tail"))
	 ((<fx %head 0)
	  (err "negative %head"))
	 ((>=fx %!tail inlen)
	  (err "tail >= buffer.length"))
	 ((>=fx %head inlen)
	  (err "head >= buffer.length")))))
	 
;*---------------------------------------------------------------------*/
;*    alsabuffer-fill! ...                                             */
;*---------------------------------------------------------------------*/
(define-generic (alsabuffer-fill! buffer::alsabuffer outlen::long)
   (with-access::alsabuffer buffer (%bmutex %bcondv %!bstate %head %!tail %inbuf %eof readsz port)
      
      (define inlen (string-length %inbuf))
      
      (define (available)
	 (cond
	    ((>fx %head %!tail) (-fx %head %!tail))
	    ((<fx %head %!tail) (+fx (-fx inlen (-fx %!tail 1)) %head))
	    (else inlen)))

      (define (empty-state?)
	 (and (eq? %!bstate 0) (>fx (*fx (available) 4) inlen)))
      
      (define (fill sz)
	 (let* ((sz (minfx sz readsz))
		(i (read-fill-string! %inbuf %head sz port)))
	    (if (eof-object? i)
		(set! %eof #t)
		(let ((nhead (+fx %head i)))
		   (if (=fx nhead inlen)
		       (set! %head 0)
		       (set! %head nhead))
		   (cond
		      ((=fx %head %!tail)
		       ;; set state full
		       (mutex-lock! %bmutex)
		       (when (>fx debug 0)
			  (with-access::alsabuffer buffer (profile-lock)
			     (set! profile-lock (+fx 1 profile-lock))
			     (tprint "fill.2, set full (bs=2) mutex-lock="
				profile-lock)))
		       (set! %!bstate 2)
		       (condition-variable-broadcast! %bcondv)
		       (condition-variable-wait! %bcondv %bmutex)
		       (mutex-unlock! %bmutex))
		      ((empty-state?)
		       ;; set state filled
		       (mutex-lock! %bmutex)
		       (when (>fx debug 0)
			  (with-access::alsabuffer buffer (profile-lock)
			     (set! profile-lock (+fx 1 profile-lock))
			     (tprint "fill.2, set filled (bs=1) mutex-lock="
				profile-lock)))
		       (set! %!bstate 1)
		       (condition-variable-broadcast! %bcondv)
		       (mutex-unlock! %bmutex))))))
	 (alsabuffer-assert buffer "fill"))
      
      (let loop ()
	 (when (>fx debug 1)
	    (tprint "fill.1 %!bstate=" %!bstate
	       " tl=" %!tail " hd=" %head " eof=" %eof))
	 (cond
	    ((or (>=fx %!bstate 3) %eof)
	     (mutex-lock! %bmutex)
	     (condition-variable-broadcast! %bcondv)
	     (mutex-unlock! %bmutex))
	    ((=fx %!bstate 2)
	     ;; buffer full, wait to be flushed
	     (mutex-lock! %bmutex)
	     (when (=fx %!bstate 2)
		;; a kind of double check locking, correct, is
		;; ptr read/write are atomic
		(condition-variable-wait! %bcondv %bmutex))
	     (mutex-unlock! %bmutex)
	     (loop))
	    ((<fx %head %!tail)
	     ;; free space before the tail
	     (fill (-fx %!tail %head))
	     (loop))
	    (else
	     ;; free space after the tail (>=fx %head %!tail)
	     (fill (-fx inlen %head))
	     (loop))))))

;*---------------------------------------------------------------------*/
;*    alsadecoder-decode ::alsadecoder ...                             */
;*---------------------------------------------------------------------*/
(define-generic (alsadecoder-decode d::alsadecoder o::alsamusic b::alsabuffer))

;*---------------------------------------------------------------------*/
;*    music-volume-get ::alsamusic ...                                 */
;*---------------------------------------------------------------------*/
(define-method (music-volume-get o::alsamusic)
   (with-access::alsamusic o (%status)
      (musicstatus-volume %status)))

;*---------------------------------------------------------------------*/
;*    music-volume-set! ::alsamusic ...                                */
;*---------------------------------------------------------------------*/
(define-method (music-volume-set! o::alsamusic vol)
   (with-access::alsamusic o (decoders %status)
      (for-each (lambda (d) (alsadecoder-volume-set! d vol)) decoders)
      (musicstatus-volume-set! %status vol)))
   
;*---------------------------------------------------------------------*/
;*    alsadecoder-init ::alsadecoder ...                               */
;*---------------------------------------------------------------------*/
(define-generic (alsadecoder-init o::alsadecoder)
   o)

;*---------------------------------------------------------------------*/
;*    alsadecoder-reset! ...                                           */
;*---------------------------------------------------------------------*/
(define-generic (alsadecoder-reset! o::alsadecoder)
   (with-access::alsadecoder o (%!pause)
      (set! %!pause #f))
   #f)

;*---------------------------------------------------------------------*/
;*    alsadecoder-close ::alsadecoder ...                              */
;*---------------------------------------------------------------------*/
(define-generic (alsadecoder-close o::alsadecoder))
   
;*---------------------------------------------------------------------*/
;*    alsadecoder-can-play-type? ...                                   */
;*---------------------------------------------------------------------*/
(define-generic (alsadecoder-can-play-type? o::alsadecoder mime::bstring)
   (with-access::alsadecoder o (mimetypes)
      (member mime mimetypes)))

;*---------------------------------------------------------------------*/
;*    alsadecoder-position ::alsadecoder ...                           */
;*---------------------------------------------------------------------*/
(define-generic (alsadecoder-position o::alsadecoder inbuf))

;*---------------------------------------------------------------------*/
;*    alsadecoder-info ::alsadecoder ...                               */
;*---------------------------------------------------------------------*/
(define-generic (alsadecoder-info o::alsadecoder))

;*---------------------------------------------------------------------*/
;*    alsadecoder-seek ::alsadecoder ...                               */
;*---------------------------------------------------------------------*/
(define-generic (alsadecoder-seek o::alsadecoder ms::long))

;*---------------------------------------------------------------------*/
;*    alsadecoder-volume-set! ::alsadecoder ...                        */
;*---------------------------------------------------------------------*/
(define-generic (alsadecoder-volume-set! o::alsadecoder v::long))
