;*=====================================================================*/
;*    .../project/bigloo/bigloo/api/multimedia/src/Llib/midi.scm       */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Thu Mar  7 17:33:01 2019                          */
;*    Last change :  Tue Mar 12 10:24:04 2019 (serrano)                */
;*    Copyright   :  2019 Manuel Serrano                               */
;*    -------------------------------------------------------------    */
;*    Midi support (sequencer and tools).                              */
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module __multimedia-midi
   
   (export (class midiscore
	      (midiscore-init)
	      (format::long read-only)
	      (tempo::long (default 500000))
	      (ppq::long (default 96))
	      (tracks::vector (default '#())))
	   
	   (class miditrack
	      (miditrack-init)
	      (%stream read-only (default #f))
	      (%reader::midireader read-only)
	      (%close::procedure read-only)
	      (len::int32 read-only (default 0))
	      (tempo::long (default 500000))
	      
	      (ip::obj read-only (default #f))
	      (start::long read-only (default 0))
	      (datastart::long read-only (default 0))
	      (wtick::uint32 (default #u32:0))
	      (status::long (default -1))
	      (oldstatus::long (default 0))
	      (eot::bool (default #f)))
	   
	   (class midireader
	      (midireader-init)
	      (peek-byte::procedure read-only)
	      (read-byte::procedure read-only)
	      (read-int16::procedure read-only)
	      (read-int32::procedure read-only)
	      (read-int::procedure read-only)
	      (read-vlq::procedure read-only)
	      (read-chars::procedure read-only))

	   (class midiplayer
	      (midiplayer-init)
	      (err::procedure (default error))
	      (cdelay::procedure read-only (default midiplayer-cdelay))
	      ;; midi messages
	      (noteoff::procedure read-only (default midiplayer-noteoff))
	      (noteon::procedure read-only (default midiplayer-noteon))
	      (aftertouch::procedure read-only (default midiplayer-aftertouch))
	      
	      (ctrlchange::procedure read-only (default midiplayer-ctrlchange))
	      (prgmchange::procedure read-only (default midiplayer-prgmchange))
	      (after-touch::procedure read-only (default midiplayer-after-touch))
	      (pitch::procedure read-only (default midiplayer-pitch))
	      ;; sysex
	      (sysex::procedure (default midiplayer-sysex))
	      ;; meta events
	      (meta-seqnum::procedure (default midiplayer-ignore))
	      (meta-text::procedure (default midiplayer-ignore))
	      (meta-copyright::procedure (default midiplayer-ignore))
	      (meta-track::procedure (default midiplayer-ignore))
	      (meta-instrument::procedure (default midiplayer-ignore))
	      (meta-lyric::procedure (default midiplayer-ignore))
	      (meta-marker::procedure (default midiplayer-ignore))
	      (meta-cue::procedure (default midiplayer-ignore))
	      (meta-channpref::procedure (default midiplayer-ignore))
	      (meta-midiport::procedure (default midiplayer-ignore))
	      (meta-eot::procedure (default midiplayer-ignore))
	      (meta-tempo::procedure (default midiplayer-ignore))
	      (meta-smtpe::procedure (default (lambda (mp ms hr mm se fr ff) #f)))
	      (meta-timesig::procedure (default (lambda (mp ms nn dd cc bb) #f)))
	      (meta-keysig::procedure (default midiplayer-ignore)))

	   (class midisink
	      (midisink-init)
	      (stream (default #f))
	      (usleep::procedure read-only (default sleep))
	      (write-byte::procedure read-only (default (lambda (op b) (write-byte b op))))
	      (write-string::procedure read-only (default (lambda (op s) (write-string s op)))))
	   
	   (generic midiscore-init ::midiscore)
	   (generic miditrack-init ::miditrack)
	   (generic midireader-init ::midireader)
	   (generic midiplayer-init ::midiplayer)
	   (generic midisink-init ::midisink)
	   
	   (midiscore-file::midiscore ::bstring)
	   (miditrack-input-port::miditrack ::input-port ::long ::long)
	   (miditrack-file::miditrack ::bstring ::long ::long ::long)

	   (midiscore-play ::midiscore ::midiplayer ::midisink)

	   (midiplayer-cdelay ::midiplayer ::midisink ::miditrack ::long ::long ::long)
	   (midiplayer-ignore ::midiplayer ::midisink ::obj)
	   (midiplayer-noteoff ::midiplayer ::midisink ::long ::long ::long)
	   (midiplayer-noteon ::midiplayer ::midisink ::long ::long ::long)
	   (midiplayer-aftertouch ::midiplayer ::midisink ::long ::long ::long)
	   (midiplayer-ctrlchange ::midiplayer ::midisink ::long ::long ::long)
	   (midiplayer-prgmchange ::midiplayer ::midisink ::long ::long)
	   (midiplayer-after-touch ::midiplayer ::midisink ::long ::long)
	   (midiplayer-pitch ::midiplayer ::midisink ::long ::long ::long)
	   (midiplayer-sysex ::midiplayer ::midisink ::bstring)
	   
	   (midi-note-name::bstring ::long)
	   (midi-program-name::bstring ::long)
	   (midi-controller-name::bstring ::long)
	   (midi-program-index ::bstring)))

;*---------------------------------------------------------------------*/
;*    midireader-input-port ...                                        */
;*---------------------------------------------------------------------*/
(define midireader-input-port
   (instantiate::midireader
      (peek-byte peek-byte)
      (read-byte read-byte)
      (read-int16 read-int16)
      (read-int32 read-int32)
      (read-int read-int)
      (read-vlq read-vlq)
      (read-chars read-chars)))

;*---------------------------------------------------------------------*/
;*    midiplayer-read ...                                              */
;*---------------------------------------------------------------------*/
(define midiplayer-read
   (instantiate::midiplayer
      (cdelay (lambda (mp ms track ppq dt us) #f))
      (noteoff (lambda (mp ms x y z) #f))
      (noteon (lambda (mp ms x y z) #f))
      (aftertouch (lambda (mp ms x y z) #f))
      (ctrlchange (lambda (mp ms x y z) #f))
      (prgmchange (lambda (mp ms x y) #f))
      (after-touch (lambda (mp ms x y) #f))
      (pitch (lambda (mp ms x y z) #f))
      (sysex (lambda (mp ms s) #f))))
      
;*---------------------------------------------------------------------*/
;*    midiscore-file ...                                               */
;*---------------------------------------------------------------------*/
(define (midiscore-file filename)
   (let ((ip (open-input-file filename)))
      (multiple-value-bind (sz fmt tck tempo ppq)
	 (midi-read-mthd ip)
	 (let ((tracks (case fmt
			  ((0) (vector (miditrack-input-port ip tempo ppq)))
			  ((1) (miditracks-input-port ip tempo ppq tck))
			  ((2) (error "midiscore-file" "format not supported" fmt))
			  (else (error "midiplayer-file" "bad midi format" fmt)))))
	    (instantiate::midiscore
	       (format fmt)
	       (tempo tempo)
	       (ppq ppq)
	       (tracks tracks))))))

;*---------------------------------------------------------------------*/
;*    midiscore-close ...                                              */
;*---------------------------------------------------------------------*/
(define (midiscore-close mscore::midiscore)
   (with-access::midiscore mscore (tracks)
      (vector-for-each (lambda (track)
			  (with-access::miditrack track (%close %stream)
			     (%close %stream)))
	 tracks)))

;*---------------------------------------------------------------------*/
;*    miditrack-input-port ...                                         */
;*---------------------------------------------------------------------*/
(define (miditrack-input-port ip::input-port tempo::long ppq::long)
   (instantiate::miditrack
      (%stream ip)
      (%reader midireader-input-port)
      (%close close-input-port)
      (len (midi-read-mtrk ip))
      (tempo tempo)))

;*---------------------------------------------------------------------*/
;*    miditracks-input-port ...                                        */
;*---------------------------------------------------------------------*/
(define (miditracks-input-port ip::input-port tempo::long ppq::long tnum)
   
   (define (read-track ip tempo ppq)
      (let ((track (miditrack-input-port ip tempo ppq)))
	 (let loop ((olds 0))
	    (let ((s (miditrack-play-event track midimplayer-read
			(midisink-nil) ppq olds 0)))
	       (when (>=fx s 0)
		  (loop s))))))
   
   (define (open-input-file/position file pos)
      (let ((port (open-input-file file)))
	 (input-port-position-set! port pos)
	 port))
   
   (let ((t0 (read-track ip tempo ppq)))
      (with-access::miditrack t0 (tempo)
	 (tprint "tempo=" tempo)
	 (let* ((file (input-port-name ip))
		(tracks (let loop ((i 0)
				   (pos (input-port-position ip))
				   (tks '()))
			   (if (<fx i tnum)
			       (list->vector (reverse! tks))
			       (let* ((ip (open-input-file/position file pos))
				      (t (miditrack-input-port ip tempo ppq)))
				  (with-access::miditrack t (len)
				     (loop (+fx i 1)
					(input-port-position ip)
					(cons t tks))))))))
	    (close-input-port ip)
	    tracks))))
   
;*---------------------------------------------------------------------*/
;*    miditrack-file ...                                               */
;*---------------------------------------------------------------------*/
(define (miditrack-file filename offset tempo::long ppq::long)
   (call-with-input-file filename
      (lambda (ip)
	 (set-input-port-position! ip offset)
	 (miditrack-input-port ip tempo ppq))))

;*---------------------------------------------------------------------*/
;*    midiscore-play ...                                               */
;*---------------------------------------------------------------------*/
(define (midiscore-play mscore::midiscore mplayer::midiplayer msink::midisink)
   (with-access::midiscore mscore (format)
      (case format
	 ((0) (midiscore-play0 mscore mplayer msink))
	 ((1) (midiscore-play1 mscore mplayer msink))
	 (else (error "midiscore-play" "bad midi format" format)))))

;*---------------------------------------------------------------------*/
;*    midiscore-play0 ...                                              */
;*---------------------------------------------------------------------*/
(define (midiscore-play0 mscore::midiscore mplayer::midiplayer msink::midisink)
   (with-access::midiscore mscore (tracks ppq)
      (let ((track (vector-ref tracks 0)))
	 (let loop ((olds 0)
		    (t0 (current-microseconds)))
	    (let ((s (miditrack-play-event track mplayer msink ppq olds t0)))
	       (when (>=fx s 0)
		  (let ((t0 (current-microseconds)))
		     (loop s t0))))))))

;*---------------------------------------------------------------------*/
;*    midiscore-play1 ...                                              */
;*---------------------------------------------------------------------*/
(define (midiscore-play1 mscore::midiscore mplay::midiplayer msink::midisink)
   (tprint "TODO"))

;*---------------------------------------------------------------------*/
;*    miditrack-play-event ...                                         */
;*---------------------------------------------------------------------*/
(define (miditrack-play-event::long track::miditrack
	   mplayer::midiplayer msink::midisink
	   ppq::long oldstatus::long t0::llong)
   
   (with-access::miditrack track (%stream %reader tempo)
      (with-access::midireader %reader (read-vlq peek-byte read-byte read-chars)
	 (with-access::midiplayer mplayer (err cdelay
					     noteoff noteon aftertouch
					     ctrlchange prgmchange
					     after-touch pitch
					     sysex
					     meta-text meta-seqnum
					     meta-copyright meta-track
					     meta-instrument meta-lyric
					     meta-marker meta-cue
					     meta-channpref meta-eot
					     meta-tempo meta-smtpe
					     meta-timesig meta-keysig)
	    (let* ((dt (read-vlq %stream))
		   (status (if (<fx (peek-byte %stream) 128)
			       oldstatus
			       (read-byte %stream))))
	       (cond
		  ((=fx (bit-rsh status 4) #x8)
		   ;; noteoff
		   (let* ((kk (char->integer (read-char %stream)))
			  (vv (char->integer (read-char %stream))))
		      (cdelay mplayer msink track ppq dt
			 (llong->fixnum (-llong (current-microseconds) t0)))
		      (noteoff mplayer msink (bit-and status #b1111) kk vv)
		      status))
		  ((=fx (bit-rsh status 4) #x9)
		   ;; noteon
		   (let* ((kk (char->integer (read-char %stream)))
			  (vv (char->integer (read-char %stream))))
		      (cdelay mplayer msink track ppq dt
			 (llong->fixnum (-llong (current-microseconds) t0)))
		      (noteon mplayer msink (bit-and status #b1111) kk vv)
		      status))
		  ((=fx (bit-rsh status 4) #xa)
		   ;; after touch
		   (let* ((cc (char->integer (read-char %stream)))
			  (vv (char->integer (read-char %stream))))
		      (cdelay mplayer msink track ppq dt
			 (llong->fixnum (-llong (current-microseconds) t0)))
		      (aftertouch mplayer msink (bit-and status #b1111) cc vv)
		      status))
		  ((=fx (bit-rsh status 4) #xb)
		   ;; control change
		   (let* ((cc (char->integer (read-char %stream)))
			  (nn (char->integer (read-char %stream))))
		      (cdelay mplayer msink track ppq dt
			 (llong->fixnum (-llong (current-microseconds) t0)))
		      (ctrlchange mplayer msink (bit-and status #b1111) cc nn )
		      status))
		  ((=fx (bit-rsh status 4) #xc)
		   ;; program change
		   (let ((pp (char->integer (read-char %stream))))
		      (cdelay mplayer msink track ppq dt
			 (llong->fixnum (-llong (current-microseconds) t0)))
		      (prgmchange mplayer msink (bit-and status #b1111) pp)
		      status))
		  ((=fx (bit-rsh status 4) #xd)
		   ;; channel key press
		   (let ((pp (char->integer (read-char %stream))))
		      (cdelay mplayer msink track ppq dt
			 (llong->fixnum (-llong (current-microseconds) t0)))
		      (after-touch mplayer msink (bit-and status #b1111) pp)
		      status))
		  ((=fx (bit-rsh status 4) #xe)
		   ;; pitch
		   (let ((cc (char->integer (read-char %stream)))
			 (vv (char->integer (read-char %stream))))
		      (cdelay mplayer msink track ppq dt
			 (llong->fixnum (-llong (current-microseconds) t0)))
		      (pitch mplayer msink (bit-and status #b1111) cc vv)
		      status))
		  ((=fx status #xff)
		   ;; meta events
		   (let ((c (read-byte %stream))
			 (l (read-vlq %stream)))
		      (case c
			 ((#x00)
			  ;; sequence number
			  (meta-seqnum mplayer msink (read-int16 %stream)))
			 ((#x01)
			  ;; text
			  (meta-text mplayer msink (read-chars l %stream)))
			 ((#x02)
			  ;; copyright notice
			  (meta-copyright mplayer msink (read-chars l %stream)))
			 ((#x03)
			  ;; sequence/track name
			  (meta-track mplayer msink (read-chars l %stream)))
			 ((#x04)
			  ;; instrument name
			  (meta-instrument mplayer msink (read-chars l %stream)))
			 ((#x05)
			  ;; lyric
			  (meta-lyric mplayer msink (read-chars l %stream)))
			 ((#x06)
			  ;; marker
			  (meta-marker mplayer msink (read-chars l %stream)))
			 ((#x07)
			  ;; cue point
			  (meta-marker mplayer msink (read-chars l %stream)))
			 ((#x20)
			  ;; channel prefix
			  (meta-channpref mplayer msink (read-byte %stream)))
			 ((#x21)
			  ;; midi port
			  (meta-channpref mplayer msink (read-int l %stream)))
			 ((#x2f)
			  ;; end of track
			  (set! status -1)
			  (meta-eot mplayer msink #unspecified))
			 ((#x51)
			  ;; duration in usec of a quarter note (une noire)
			  (set! tempo (read-int l %stream))
			  (meta-tempo mplayer msink tempo))
			 ((#x54)
			  ;; SMTPE offset
			  (let* ((hr (read-byte %stream))
				 (mm (read-byte %stream))
				 (se (read-byte %stream))
				 (fr (read-byte %stream))
				 (ff (read-byte %stream)))
			     (meta-smtpe mplayer msink hr mm se fr ff)))
			 ((#x58)
			  ;; time signature
			  (let* ((nn (char->integer (read-char %stream)))
				 (dd (char->integer (read-char %stream)))
				 (cc (char->integer (read-char %stream)))
				 (bb (char->integer (read-char %stream))))
			     (meta-timesig mplayer msink nn dd cc bb)))
			 ((#x59)
			  ;; key signature
			  (meta-keysig (read-int l %stream)))
			 (else
			  (err "midiplay" "illegal meta-event"
			     (format "%d:%d" status c)))))
		   status)
		  ((or (=fx status #xf0) (=fx status #xf7))
		   ;; sysex events
		   (cdelay mplayer msink track dt ppq
		      (llong->fixnum (-llong (current-microseconds) t0)))
		   (sysex mplayer msink (read-chars (read-vlq %stream) %stream))
		   status)
		  (else
		   (err "midiplay" "illegal event" status))))))))
   
;*---------------------------------------------------------------------*/
;*    midi-read-mthd ...                                               */
;*---------------------------------------------------------------------*/
(define (midi-read-mthd ip)
   (let ((ty (read-type ip)))
      (if (not (string=? ty "MThd"))
	  (error "read-midi-mthd" "Bad header" ty)
	  (let* ((sz (read-int32 ip))
		 (fmt (int32->fixnum (read-int16 ip)))
		 (tck (int32->fixnum (read-int16 ip)))
		 (div (int32->fixnum (read-int16 ip))))
	     (if (=fx (bit-rsh div 15) 0)
		 (values sz fmt tck 500000 (bit-and div #b111111111111111))
		 (case (-fx #x80 (bit-and (bit-rsh div 8) #x7f))
		    ((24)
		     (values sz fmt tck 500000 (*fx 12 (bit-and div #xff))))
		    ((25)
		     (values sz fmt tck 400000 (*fx 10 (bit-and div #xff))))
		    ((29)
		     (values sz fmt tck 100000000 (*fx 2997 (bit-and div #xff))))
		    ((30)
		     (values sz fmt tck 500000 (*fx 15 (bit-and div #xff))))
		    (else
		     (error "read-midi-mthd"
			"invalid number of SMPTE frames per second"
			(-fx #x80 (bit-and (bit-rsh div 8) #x7f))))))))))

;*---------------------------------------------------------------------*/
;*    midi-read-mtrk ...                                               */
;*---------------------------------------------------------------------*/
(define (midi-read-mtrk ip)
   (let ((ty (read-type ip)))
      (if (not (string=? ty "MTrk"))
	  (error "read-midi-mtrk" "Bad header" ty)
	  (read-int32 ip))))
   
;*---------------------------------------------------------------------*/
;*    char->int32 ...                                                  */
;*---------------------------------------------------------------------*/
(define (char->int32 c)
   (fixnum->int32 (char->integer c)))

;*---------------------------------------------------------------------*/
;*    read-int16 ...                                                   */
;*---------------------------------------------------------------------*/
(define (read-int16 ip)
   (let* ((b1 (read-char ip))
	  (b0 (read-char ip)))
      (+s32 (bit-lshs32 (char->int32 b1) 8)
	 (char->int32 b0))))

;*---------------------------------------------------------------------*/
;*    read-int32 ...                                                   */
;*---------------------------------------------------------------------*/
(define (read-int32 ip)
   (let* ((b3 (read-char ip))
	  (b2 (read-char ip))
	  (b1 (read-char ip))
	  (b0 (read-char ip)))
      (+s32 (bit-lshs32 (char->int32 b3) 24)
	 (+s32 (bit-lshs32 (char->int32 b2) 16)
	    (+s32 (bit-lshs32 (char->int32 b1) 8)
	       (char->int32 b0))))))

;*---------------------------------------------------------------------*/
;*    read-int ...                                                     */
;*---------------------------------------------------------------------*/
(define (read-int len::long ip::input-port)
   (let loop ((val (char->integer (read-char ip)))
	      (len len))
      (if (=fx len 1)
	  val
	  (loop (+fx (bit-lsh val 8) (char->integer (read-char ip)))
	     (-fx len 1)))))

;*---------------------------------------------------------------------*/
;*    read-vlq ...                                                     */
;*---------------------------------------------------------------------*/
(define (read-vlq ip)
   (let ((c (char->integer (read-char ip))))
      (if (<=fx c #x7f)
	  c
	  (let loop ((val (bit-lsh (-fx c 128) 7)))
	     (let ((c (char->integer (read-char ip))))
		(if (<= c 127)
		    (+fx val c)
		    (loop (bit-lsh (+fx val c) 7))))))))

;*---------------------------------------------------------------------*/
;*    midi-text-names ...                                              */
;*---------------------------------------------------------------------*/
(define midi-text-names
   '#("" "text" "copyright" "track" "instrument" "lyric" "marker" "cue"))

;*---------------------------------------------------------------------*/
;*    midi-controller-names ...                                        */
;*---------------------------------------------------------------------*/
(define midi-controller-names
   '#("Bank Select"
      "Modulation Wheel or Lever"
      "Breath Controller"
      "Undefined"
      "Foot Controller"
      "Portamento Time"
      "Data Entry MSB"
      "Channel Volume"
      "Balance"
      "Undefined"
      "Pan"
      "Expression Controller"
      "Effect Control 1"
      "Effect Control 2"
      "Undefined"
      "Undefined"
      "General Purpose Controller 1"
      "General Purpose Controller 2"
      "General Purpose Controller 3"
      "General Purpose Controller 4"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "LSB for Control 0"
      "LSB for Control 1"
      "LSB for Control 2"
      "LSB for Control 3"
      "LSB for Control 4"
      "LSB for Control 5"
      "LSB for Control 6"
      "LSB for Control 7"
      "LSB for Control 8"
      "LSB for Control 9"
      "LSB for Control 10"
      "LSB for Control 11"
      "LSB for Control 12"
      "LSB for Control 13"
      "LSB for Control 14"
      "LSB for Control 15"
      "LSB for Control 16"
      "LSB for Control 17"
      "LSB for Control 18"
      "LSB for Control 19"
      "LSB for Control 20"
      "LSB for Control 21"
      "LSB for Control 22"
      "LSB for Control 23"
      "LSB for Control 24"
      "LSB for Control 25"
      "LSB for Control 26"
      "LSB for Control 27"
      "LSB for Control 28"
      "LSB for Control 29"
      "LSB for Control 30"
      "LSB for Control 31"
      "Damper Pedal on/off (Sustain)"
      "Portamento On/Off"
      "Sostenuto On/Off"
      "Soft Pedal On/Off"
      "Legato Footswitch"
      "Hold 2"
      "Sound Controller 1 (default: Sound Variation)"
      "Sound Controller 2 (default: Timbre/Harmonic Intens.)"
      "Sound Controller 3 (default: Release Time)"
      "Sound Controller 4 (default: Attack Time)"
      "Sound Controller 5 (default: Brightness)"
      "Sound Controller 6 (default: Decay Time - see MMA RP-021)"
      "Sound Controller 7 (default: Vibrato Rate - see MMA RP-021)"
      "Sound Controller 8 (default: Vibrato Depth - see MMA RP-021)"
      "Sound Controller 9 (default: Vibrato Delay - see MMA RP-021)"
      "Sound Controller 10 (default undefined - see MMA RP-021)"
      "General Purpose Controller 5"
      "General Purpose Controller 6"
      "General Purpose Controller 7"
      "General Purpose Controller 8"
      "Portamento Control"
      "Undefined"
      "Undefined"
      "Undefined"
      "High Resolution Velocity Prefix"
      "Undefined"
      "Undefined"
      "Effects 1 Depth"
      "Effects 2 Depth"
      "Effects 3 Depth"
      "Effects 4 Depth"
      "Effects 5 Depth"
      "Data Increment"
      "Data Decrement"
      "Non-Registered Parameter Number (NRPN)"
      "Non-Registered Parameter Number (NRPN)"
      "Registered Parameter Number (RPN)"
      "Registered Parameter Number (RPN)"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "Undefined"
      "[Channel Mode Message] All Sound Off"
      "[Channel Mode Message] Reset All Controllers"
      "[Channel Mode Message] Local Control On/Off"
      "[Channel Mode Message] All Notes Off"
      "[Channel Mode Message] Omni Mode Off (+ all notes off)"
      "[Channel Mode Message] Omni Mode On (+ all notes off)"
      "[Channel Mode Message] Mono Mode On (+ poly off, + all notes off)"
      "[Channel Mode Message] Poly Mode On (+ mono off, +all notes off)"))
      
;*---------------------------------------------------------------------*/
;*    midi-program-names ...                                           */
;*---------------------------------------------------------------------*/
(define midi-program-names
   '#(""
      ;; piano
      "Acoustic Grand Piano"
      "Bright Acoustic Piano"
      "Electric Grand Piano"
      "Honky-tonk Piano"
      "Electric Piano 1"
      "Electric Piano 2"
      "Harpsichord"
      "Clavinet"
      ;; Chromatic Percussion:
      "Celesta"
      "Glockenspiel"
      "Music Box"
      "Vibraphone"
      "Marimba"
      "Xylophone"
      "Tubular Bells"
      "Dulcimer"
      ;; organ
      "Drawbar Organ"
      "Percussive Organ"
      "Rock Organ"
      "Church Organ"
      "Reed Organ"
      "Accordion"
      "Harmonica"
      "Tango Accordion"
      ;; Guitar
      "Acoustic Guitar (nylon)"
      "Acoustic Guitar (steel)"
      "Electric Guitar (jazz)"
      "Electric Guitar (clean)"
      "Electric Guitar (muted)"
      "Overdriven Guitar"
      "Distortion Guitar"
      "Guitar harmonics"
      ;; Bass
      "Acoustic Bass"
      "Electric Bass (finger)"
      "Electric Bass (pick)"
      "Fretless Bass"
      "Slap Bass 1"
      "Slap Bass 2"
      "Synth Bass 1"
      "Synth Bass 2"
      ;; Strings
      "Violin"
      "Viola"
      "Cello"
      "Contrabass"
      "Tremolo Strings"
      "Pizzicato Strings"
      "Orchestral Harp"
      "Timpani"
      "String Ensemble 1"
      "String Ensemble 2"
      "Synth Strings 1"
      "Synth Strings 2"
      "Choir Aahs"
      "Voice Oohs"
      "Synth Voice"
      "Orchestra Hit"
      ;; Brass
      "Trumpet"
      "Trombone"
      "Tuba"
      "Muted Trumpet"
      "French Horn"
      "Brass Section"
      "Synth Brass 1"
      "Synth Brass 2"
      ;; Reed
      "Soprano Sax"
      "Alto Sax"
      "Tenor Sax"
      "Baritone Sax"
      "Oboe"
      "English Horn"
      "Bassoon"
      "Clarinet"
      ;; Pipe
      "Piccolo"
      "Flute"
      "Recorder"
      "Pan Flute"
      "Blown Bottle"
      "Shakuhachi"
      "Whistle"
      "Ocarina"
      ;; Synth Lead
      "Lead 1 (square)"
      "Lead 2 (sawtooth)"
      "Lead 3 (calliope)"
      "Lead 4 (chiff)"
      "Lead 5 (charang)"
      "Lead 6 (voice)"
      "Lead 7 (fifths)"
      "Lead 8 (bass + lead)"
      ;; Synth Pad
      "Pad 1 (new age)"
      "Pad 2 (warm)"
      "Pad 3 (polysynth)"
      "Pad 4 (choir)"
      "Pad 5 (bowed)"
      "Pad 6 (metallic)"
      "Pad 7 (halo)"
      "Pad 8 (sweep)"
      ;; Synth Effects
      "FX 1 (rain)"
      "FX 2 (soundtrack)"
      "FX 3 (crystal)"
      "FX 4 (atmosphere)"
      "FX 5 (brightness)"
      "FX 6 (goblins)"
      "FX 7 (echoes)"
      "FX 8 (sci-fi)"
      ;; Ethnic
      "Sitar"
      "Banjo"
      "Shamisen"
      "Koto"
      "Kalimba"
      "Bag pipe"
      "Fiddle"
      "Shanai"
      ;; Percussive
      "Tinkle Bell"
      "Agogo"
      "Steel Drums"
      "Woodblock"
      "Taiko Drum"
      "Melodic Tom"
      "Synth Drum"
      ;; Sound effects
      "Reverse Cymbal"
      "Guitar Fret Noise"
      "Breath Noise"
      "Seashore"
      "Bird Tweet"
      "Telephone Ring"
      "Helicopter"
      "Applause"
      "Gunshot"))

;*---------------------------------------------------------------------*/
;*    midi-note-names ...                                              */
;*---------------------------------------------------------------------*/
(define midi-note-names
   '#("C" "C#" "D" "D#" "E" "F" "F#" "G" "G#" "A" "A#" "B"))

;*---------------------------------------------------------------------*/
;*    midiscore-init ...                                               */
;*---------------------------------------------------------------------*/
(define-generic (midiscore-init mscore::midiscore)
   mscore)

;*---------------------------------------------------------------------*/
;*    miditrack-init ...                                               */
;*---------------------------------------------------------------------*/
(define-generic (miditrack-init mtrack::miditrack)
   mtrack)

;*---------------------------------------------------------------------*/
;*    midireader-init ...                                              */
;*---------------------------------------------------------------------*/
(define-generic (midireader-init mreader::midireader)
   mreader)

;*---------------------------------------------------------------------*/
;*    midiplayer-init ...                                              */
;*---------------------------------------------------------------------*/
(define-generic (midiplayer-init mplayer::midiplayer)
   mplayer)

;*---------------------------------------------------------------------*/
;*    midisink-init ...                                                */
;*---------------------------------------------------------------------*/
(define-generic (midisink-init msink::midisink)
   msink)

;*---------------------------------------------------------------------*/
;*    midiplayer-cdelay ...                                            */
;*---------------------------------------------------------------------*/
(define (midiplayer-cdelay mp::midiplayer ms::midisink track::miditrack ppq dt us)
   (with-access::miditrack track (tempo)
      (with-access::midisink ms (usleep)
	 (when (>fx dt 0)
	    (usleep (-fx (tempo->usec dt tempo ppq) us))))))
   
;*---------------------------------------------------------------------*/
;*    midiplayer-ignore ...                                            */
;*---------------------------------------------------------------------*/
(define (midiplayer-ignore mp::midiplayer ms::midisink obj)
   #unspecified)

;*---------------------------------------------------------------------*/
;*    midiplayer-cmd2 ...                                              */
;*---------------------------------------------------------------------*/
(define (midiplayer-cmd2 ms::midisink cmd::long nn::long kk::long)
   (with-access::midisink ms (stream write-byte)
      (write-byte stream (bit-or cmd nn))
      (write-byte stream kk)))

;*---------------------------------------------------------------------*/
;*    midiplayer-cmd3 ...                                              */
;*---------------------------------------------------------------------*/
(define (midiplayer-cmd3 ms::midisink cmd::long nn::long kk::long vv::long)
   (with-access::midisink ms (stream write-byte)
      (write-byte stream (bit-or cmd nn))
      (write-byte stream kk)
      (write-byte stream vv)))

;*---------------------------------------------------------------------*/
;*    midiplayer-noteoff ...                                           */
;*---------------------------------------------------------------------*/
(define (midiplayer-noteoff mp::midiplayer ms::midisink nn::long kk::long vv::long)
   (midiplayer-cmd3 ms #x80 nn kk vv))

;*---------------------------------------------------------------------*/
;*    midiplayer-noteon ...                                            */
;*---------------------------------------------------------------------*/
(define (midiplayer-noteon mp::midiplayer ms::midisink nn::long kk::long vv::long)
   (midiplayer-cmd3 ms #x90 nn kk vv))

;*---------------------------------------------------------------------*/
;*    midiplayer-aftertouch ...                                        */
;*---------------------------------------------------------------------*/
(define (midiplayer-aftertouch mp::midiplayer ms::midisink nn::long kk::long vv::long)
   (midiplayer-cmd3 ms #xa0 nn kk vv))

;*---------------------------------------------------------------------*/
;*    midiplayer-ctrlchange ...                                        */
;*---------------------------------------------------------------------*/
(define (midiplayer-ctrlchange mp::midiplayer ms::midisink nn::long kk::long vv::long)
   (midiplayer-cmd3 ms #xb0 nn kk vv))

;*---------------------------------------------------------------------*/
;*    midiplayer-prgmchange ...                                        */
;*---------------------------------------------------------------------*/
(define (midiplayer-prgmchange mp::midiplayer ms::midisink nn::long pp::long)
   (midiplayer-cmd2 ms #xc0 nn pp))

;*---------------------------------------------------------------------*/
;*    midiplayer-after-touch ...                                       */
;*---------------------------------------------------------------------*/
(define (midiplayer-after-touch mp::midiplayer ms::midisink nn::long pp::long)
   (midiplayer-cmd2 ms #xd0 nn pp))

;*---------------------------------------------------------------------*/
;*    midiplayer-pitch ...                                             */
;*---------------------------------------------------------------------*/
(define (midiplayer-pitch mp::midiplayer ms::midisink nn::long cc::long vv::long)
   (midiplayer-cmd3 ms #xd0 nn cc vv))
	   
;*---------------------------------------------------------------------*/
;*    midiplayer-sysex ...                                             */
;*---------------------------------------------------------------------*/
(define (midiplayer-sysex mp::midiplayer ms::midisink data)
   (with-access::midisink ms (stream write-string)
      (write-string stream)))

;*---------------------------------------------------------------------*/
;*    midi-note-name ...                                               */
;*---------------------------------------------------------------------*/
(define (midi-note-name kk::long)
   (let ((note (remainderfx kk (vector-length midi-note-names)))
	 (octave (/fx kk (vector-length midi-note-names))))
      (format "~a[~a]" (vector-ref midi-note-names note) octave)))

;*---------------------------------------------------------------------*/
;*    midi-controller-name ...                                         */
;*---------------------------------------------------------------------*/
(define (midi-controller-name cc::long)
   (if (<fx cc (vector-length midi-controller-names))
       (vector-ref midi-controller-names cc)
       "unknown controller"))

;*---------------------------------------------------------------------*/
;*    midi-program-name ...                                            */
;*---------------------------------------------------------------------*/
(define (midi-program-name pp::long)
   (if (<fx pp (vector-length midi-program-names))
       (vector-ref midi-program-names pp)
       "unknown program"))

;*---------------------------------------------------------------------*/
;*    midi-progran-index ...                                           */
;*---------------------------------------------------------------------*/
(define (midi-program-index prgm)
   (let loop ((i (-fx (vector-length midi-program-names) 1)))
      (when (>=fx i 0)
	 (if (string-ci=? (vector-ref midi-program-names i) prgm)
	     i
	     (loop (-fx i 1))))))

;*---------------------------------------------------------------------*/
;*    check-byte ...                                                   */
;*---------------------------------------------------------------------*/
(define (check-byte ip byte)
   (let ((c (read-byte ip)))
      (unless (=fx c byte)
	 (error "check-byte" (format "byte ~a expected" byte) c))))

;*---------------------------------------------------------------------*/
;*    tempo->usec ...                                                  */
;*---------------------------------------------------------------------*/
(define (tempo->usec tick tempo tpb)
   (/fx (*fx tick tempo) tpb))

;*---------------------------------------------------------------------*/
;*    read-type ...                                                    */
;*---------------------------------------------------------------------*/
(define (read-type ip)
   (read-chars 4 ip))

;* {*---------------------------------------------------------------------*} */
;* {*    midiplayer-play ...                                              *} */
;* {*---------------------------------------------------------------------*} */
;* (define (midiplayer-play player::midiplayer ip op)                  */
;*    (multiple-value-bind (sz fmt tck tempo ppq)                      */
;*       (midi-read-mthd ip)                                           */
;*       (with-access::midiplayer player (mthd)                        */
;* 	 (multiple-value-bind (sz fmt tck tempo ppq)                   */
;* 	    (mthd sz fmt tck tempo ppq)                                */
;* 	    (case (int32->fixnum fmt)                                  */
;* 	       ((0) (read-track player ip op tempo ppq))               */
;* 	       ((1) (read-multi-track player ip op tempo ppq tck))     */
;* 	       ((2) (error "midiplayer-play" "format not supported" fmt)) */
;* 	       (else (error "midiplayer-play" "bad midi format" fmt))))))) */
;*                                                                     */
;* {*---------------------------------------------------------------------*} */
;* {*    miditrack-read-event ...                                         *} */
;* {*---------------------------------------------------------------------*} */
;* (define (miditrack-read-event t::miditrack player::midiplayer op)   */
;*    (with-access::midiplayer player ((seteot eot)                    */
;* 				    (settempo tempo)                   */
;* 				    noteon noteoff ctrlchange prgmchange */
;* 				    meta-text meta-copyright meta-track) */
;*       (with-access::miditrack t (num ip wtick status eot (%tempo tempo)) */
;* 	 (cond                                                         */
;* 	    ((=fx status #xff)                                         */
;* 	     (let ((c (read-byte ip))                                  */
;* 		   (l (read-vlq ip)))                                  */
;* 		(case c                                                */
;* 		   ((0)                                                */
;* 		    (read-byte ip)                                     */
;* 		    (tprint "!!!!!!!!!! ss=" (read-int16 ip))          */
;* 		    #unspecified)                                      */
;* 		   ((#x01)                                             */
;* 		    (meta-text t (read-chars l ip)))                   */
;* 		   ((#x02)                                             */
;* 		    (meta-copyright t (read-chars l ip)))              */
;* 		   ((#x03)                                             */
;* 		    (meta-track t (read-chars l ip)))                  */
;* 		   ((#x04 #x05 #x06 #x07)                              */
;* 		    (let ((text (read-chars l ip)))                    */
;* 		       #unspecified))                                  */
;* 		   ((#x20)                                             */
;* 		    ;; channel prefix                                  */
;* 		    (let ((cc (read-byte ip)))                         */
;* 		       #unspecified))                                  */
;* 		   ((#x21)                                             */
;* 		    ;; midi port                                       */
;* 		    (let ((port (read-int l ip)))                      */
;* 		       #unspecified))                                  */
;* 		   ((#x2f)                                             */
;* 		    (set! eot #t)                                      */
;* 		    (seteot t)                                         */
;* 		    %tempo)                                            */
;* 		   ((#x51)                                             */
;* 		    ;; duration in usec of a quarter note (une noire)  */
;* 		    (set! %tempo (settempo t (read-int l ip)))         */
;* 		    #unspecified)                                      */
;* 		   ((#x54)                                             */
;* 		    (let* ((hr (read-byte ip))                         */
;* 			   (mm (read-byte ip))                         */
;* 			   (se (read-byte ip))                         */
;* 			   (fr (read-byte ip))                         */
;* 			   (ff (read-byte ip)))                        */
;* 		       #unspecified))                                  */
;* 		   ((#x59)                                             */
;* 		    (let ((sig (read-int l ip)))                       */
;* 		       #unspecified))                                  */
;* 		   ((#x58)                                             */
;* 		    (let* ((nn (char->integer (read-char ip)))         */
;* 			   (dd (char->integer (read-char ip)))         */
;* 			   (cc (char->integer (read-char ip)))         */
;* 			   (bb (char->integer (read-char ip))))        */
;* 		       #unspecified))                                  */
;* 		   (else                                               */
;* 		    (tprint "  !!!!!!!!!!!!!! else=" c " " (integer->string c 16)))))) */
;* 	    ((or (=fx status #xf0) (=fx status #xf7))                  */
;* 	     (midi-write-string op (read-chars (read-vlq ip) ip))      */
;* 	     #unspecified)                                             */
;* 	    ((=fx (bit-rsh status 4) #xb)                              */
;* 	     ;; controller change                                      */
;* 	     (let* ((cc (char->integer (read-char ip)))                */
;* 		    (nn (char->integer (read-char ip))))               */
;* 		(ctrlchange t (bit-and status #b1111) cc nn op)))      */
;* 	    ((=fx (bit-rsh status 4) #xc)                              */
;* 	     ;; program change                                         */
;* 	     (let ((pp (char->integer (read-char ip))))                */
;* 		(prgmchange t (bit-and status #b1111) pp op)))         */
;* 	    ((=fx (bit-rsh status 4) #xd)                              */
;* 	     ;; channel key press                                      */
;* 	     (let ((pp (char->integer (read-char ip))))                */
;* 		(midi-write-byte op status)                            */
;* 		(midi-write-byte op pp)                                */
;* 		#unspecified))                                         */
;* 	    ((or (=fx (bit-rsh status 4) #xa)                          */
;* 		 (=fx (bit-rsh status 4) #xe))                         */
;* 	     (let ((cc (char->integer (read-char ip)))                 */
;* 		   (vv (char->integer (read-char ip))))                */
;* 		(midi-write-byte op status)                            */
;* 		(midi-write-byte op cc)                                */
;* 		(midi-write-byte op vv)                                */
;* 		#unspecified))                                         */
;* 	    ((=fx status -1)                                           */
;* 	     #unspecified)                                             */
;* 	    (else                                                      */
;* 	     (tprint "status else=" status " "                         */
;* 		(integer->string status 16)))))))                      */
;*                                                                     */
;* {*---------------------------------------------------------------------*} */
;* {*    read-track ...                                                   *} */
;* {*    -------------------------------------------------------------    *} */
;* {*    ip: the input port                                               *} */
;* {*    op: the output port (possibly a MIDI port)                       *} */
;* {*    tpb: tick per beat (aka ppqn)                                    *} */
;* {*    -------------------------------------------------------------    *} */
;* {*    Read a complete track.                                           *} */
;* {*---------------------------------------------------------------------*} */
;* (define (read-track player::midiplayer ip op tempo ppq)             */
;*    (let ((offs (input-port-position ip)))                           */
;*       (with-access::midiplayer player (noteon noteoff ctrlchange prgmchange */
;* 				       meta-text meta-copyright meta-track) */
;* 	 (let ((tklen (midi-read-mtrk ip)))                            */
;* 	    (let ((track (instantiate::miditrack                       */
;* 			    (tempo tempo)                              */
;* 			    (%reader midireader-input-port)            */
;* 			    (start offs)                               */
;* 			    (datastart (input-port-position ip))       */
;* 			    (len (int32->fixnum tklen))                */
;* 			    (ip ip))))                                 */
;* 	       (with-access::miditrack track (status oldstatus eot (%tempo tempo)) */
;* 		  (let loop ()                                         */
;* 		     (let ((dt (read-vlq ip)))                         */
;* 			(set! status (read-byte ip))                   */
;* 			(when (<fx status 128)                         */
;* 			   (begin                                      */
;* 			      (unread-char! (integer->char status) ip) */
;* 			      (set! status oldstatus))                 */
;* 			   (set! oldstatus status))                    */
;* 			(when (and (>fx dt 0) (not (=fx status #xff))) */
;* 			   (sleep (tempo->usec dt %tempo ppq)))        */
;* 			(miditrack-read-event track player op)         */
;* 			(unless eot                                    */
;* 			   (loop)))))                                  */
;* 	       track)))))                                              */
;*                                                                     */
;* {*---------------------------------------------------------------------*} */
;* {*    miditrack-step ...                                               *} */
;* {*    -------------------------------------------------------------    *} */
;* {*    step inside a midi track of a multi-track midi file.             *} */
;* {*---------------------------------------------------------------------*} */
;* (define-generic (miditrack-step t::miditrack player::midiplayer op tick::uint32 ppq) */
;*    (with-access::midiplayer player (noteon noteoff ctrlchange prgmchange */
;* 				      meta-text meta-copyright meta-track) */
;*       (with-access::miditrack t (num ip wtick status oldstatus eot) */
;* 	 (when (<=u32 wtick tick)                                      */
;* 	    (let loop ()                                               */
;* 	       (miditrack-read-event t player op)                      */
;* 	       (if eot                                                 */
;* 		   (set! wtick (fixnum->uint32 -1))                    */
;* 		   (let ((dt (read-vlq ip)))                           */
;* 		      (set! status (read-byte ip))                     */
;* 		      (if (<fx status 128)                             */
;* 			  (begin                                       */
;* 			     (unread-char! (integer->char status) ip)  */
;* 			     (set! status oldstatus))                  */
;* 			  (set! oldstatus status))                     */
;* 		      (if (>fx dt 0)                                   */
;* 			  (set! wtick (+u32 tick (fixnum->int32 dt)))  */
;* 			  (loop)))))))))                               */
;*                                                                     */
;* {*---------------------------------------------------------------------*} */
;* {*    miditrack-open ...                                               *} */
;* {*---------------------------------------------------------------------*} */
;* (define (miditrack-open::miditrack num file offs)                   */
;*                                                                     */
;*    (define (open-input-port/position file offs)                     */
;*       (let ((ip (open-input-file file)))                            */
;* 	 (set-input-port-position! ip offs)                            */
;* 	 ip))                                                          */
;*                                                                     */
;*    (let* ((ip (open-input-port/position file offs))                 */
;* 	  (tklen (int32->fixnum (midi-read-mtrk ip))))                 */
;*       (instantiate::miditrack                                       */
;* 	 (%reader midireader-input-port)                               */
;* 	 (start offs)                                                  */
;* 	 (datastart (input-port-position ip))                          */
;* 	 (len tklen)                                                   */
;* 	 (ip ip))))                                                    */
;*                                                                     */
;* {*---------------------------------------------------------------------*} */
;* {*    read-multi-track ...                                             *} */
;* {*---------------------------------------------------------------------*} */
;* (define (read-multi-track player::midiplayer ip op tempo ppq ntk::long) */
;*    (let ((ti (read-track player ip op tempo ppq)))                  */
;*       (with-access::midiplayer player (topen)                       */
;* 	 (let* ((file (input-port-name ip))                            */
;* 		(offs (input-port-position ip))                        */
;* 		(tracks (let loop ((i 1)                               */
;* 				   (offs (input-port-position ip)))    */
;* 			   (if (=fx i ntk)                             */
;* 			       '()                                     */
;* 			       (let ((t (topen i file offs)))          */
;* 				  (with-access::miditrack t (datastart len) */
;* 				     (cons t                           */
;* 					(loop (+fx i 1) (+fx datastart len)))))))) */
;* 		(res (with-access::miditrack ti ((%tempo tempo)) (/fx %tempo ppq)))) */
;* 	    (close-input-port ip)                                      */
;* 	    (let loop ((tick #u32:0))                                  */
;* 	       (let ((t0 (current-microseconds)))                      */
;* 		  (for-each (lambda (t::miditrack)                     */
;* 			       (miditrack-step t player op tick ppq))  */
;* 		     tracks)                                           */
;* 		  (let ((dt (llong->fixnum (-llong (current-microseconds) t0)))) */
;* 		     (sleep (-fx res dt))                              */
;* 		     (loop (+u32 tick #u32:1)))))                      */
;* 	    (for-each (lambda (t::miditrack)                           */
;* 			 (with-access::miditrack t (ip)                */
;* 			    (close-input-port ip)))                    */
;* 	       tracks)))))                                             */
;* 						                       */
;*                                                                     */
;*                                                                     */
;*                                                                     */
;*                                                                     */
