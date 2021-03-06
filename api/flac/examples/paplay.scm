;*=====================================================================*/
;*    serrano/prgm/project/bigloo/api/flac/examples/paplay.scm         */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Sun Jun 26 07:30:16 2011                          */
;*    Last change :  Wed Jan 27 17:26:52 2016 (serrano)                */
;*    Copyright   :  2011-16 Manuel Serrano                            */
;*    -------------------------------------------------------------    */
;*    A multimedia MUSIC player built on top of FLAC and ALSA.         */
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module musicplay
   (library multimedia pthread alsa pulseaudio flac)
   (main main))

;*---------------------------------------------------------------------*/
;*    directory->files ...                                             */
;*---------------------------------------------------------------------*/
(define (directory->files path)
   (if (directory? path)
       (append-map (lambda (p)
		      (directory->files (make-file-name path p)))
	  (sort (lambda (s1 s2)
		   (>fx (string-natural-compare3 s1 s2) 0))
	     (directory->list path)))
       (list path)))

;*---------------------------------------------------------------------*/
;*    main ...                                                         */
;*---------------------------------------------------------------------*/
(define (main args)
   
   (let ((files '())
	 (volume 80))
      
      (args-parse (cdr args)
	 ((("-h" "--help") (help "This message"))
	  (print "musicplay")
	  (print "usage: musicplay [options] file1 file2 ...")
	  (newline)
	  (args-parse-usage #f)
	  (exit 0))
	 ((("-v" "--volume") ?vol (help "Set volume"))
	  (set! volume (string->integer vol)))
	 (else
	  (set! files (append (directory->files else) files))))
      
      (define (onstate o status)
	 (with-access::musicstatus status (state)
	    (tprint "state: " state)))
      
      (define (onerror o e)
	 (tprint "error: " e))
      
      (define (onvolume o v)
	 (tprint "volume: " v))
      
      (define (onevent o e v)
	 (tprint "event: " e " " v))
      
      (when (pair? files)
	 (let* ((decoder (instantiate::flac-pulseaudiodecoder
			    (mimetypes '("audio/flac" "application/x-flac"))))
		(player (instantiate::pulseaudiomusic
			   (onstate onstate)
			   (onerror onerror)
			   (onvolume onvolume)
			   (onevent onevent)
			   (decoders (list decoder))
			   (name "bigloo"))))
	    (music-volume-set! player volume)
	    (music-playlist-clear! player)
	    (print "playing (" (current-date) "): ")
	    (for-each (lambda (p)
			 (print "  " p)
			 (music-playlist-add! player p))
	       (reverse files))
	    (music-play player)))))

