#!../src/slayer
!#
(use-modules (slayer)
	     (slayer image)	     
	     (slayer font)
	     (extra common))

(use-modules (ice-9 match)) ;;; tylko dla gejzerka...

(define *animation-on* #f)

(define *general-game-state* 'PLAY) ;; TITLE HIGHSCORE MESSAGE ANIMATION GAMEOVER ...?

;;; brudne komunikaty:
(define (mk-message msgs transform)  
;  (write `(mk-msg ,msgs)) (newline)
  (set! *general-game-state* `(MESSAGE ,msgs ,transform)))


(define (to-int n) (inexact->exact (floor n)))

;;; rotejtowanie listy (a1 a2 ... an-1 an) -> (a2 a3 ... an a1)
(define (rot-list l)
  (if (null? l)
      l
      (append (cdr l) (list (car l)))))

;;; alisty dla nasz
(define (AL:new keys vals)
  (if (null? keys)
      '()
      (cons (cons (car keys)
		  (car vals))
	    (AL:new (cdr keys)
		    (cdr vals)))))

(define (AL:insert key val al)
  (cons (cons key val) al))

(define (AL:lookup key al)
;  (write `(lookup ,key)) (newline)
  (cond ((null? al) #f)
	((eq? key (caar al)) (cdar al))
	(else (AL:lookup key (cdr al)))))

(define (AL:update key val al)
;  (write `(update ,key ,val)) (newline)
  (cond ((null? al) al) ;; ?
	((eq? key (caar al)) (cons (cons key val) (cdr al)))
	(else (cons (car al) (AL:update key val (cdr al))))))

(define (AL:update-insert key val al)
  (cond ((null? al) (AL:insert key val al)) ;; !!
	((eq? key (caar al)) (cons (cons key val) (cdr al)))
	(else (cons (car al) (AL:update-insert key val (cdr al))))))


(define (AL:delete key _ al)
;  (write `(al-del ,key ,al)) (newline)
  (cond ((null? al) '()) ;; ?!...
	((eq? key (caar al)) (cdr al))
	(else (cons (car al) (AL:delete key _ (cdr al))))))


;(define a1 (AL:new '(q w e) '(1 2 3)))
;(define a2 (AL:update 'x '7 a1))
;(define a2 (AL:update 'w '99 a2))
;(AL:lookup 'x a2)
;(AL:lookup 'w a2)
;(write (AL:delete 'w a2))
;(write (AL:delete 'y a2))

;;; nno.


;;; cudne makro od godka...
(define-macro (define-accessors tree)
  (letrec ((gather-leaves (lambda (path subtree)
                            (cond ((null? subtree)
                                   '())
                                  ((symbol? subtree)
                                   (list (cons subtree path)))
                                  (#t
                                   (append (gather-leaves (list 'car path)
                                                          (car subtree))
                                           (gather-leaves (list 'cdr path)
                                                          (cdr subtree))))))))
    `(begin . ,(map (match-lambda ((name . body)
                                   `(define (,name s) ,body)))
                    (gather-leaves 's tree))
            )))

;;; ... i lecimy: -- swiat ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-accessors (W:sectors #;+jakis-config?))
;;; -- sektor ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-accessors (S:id S:objects S:floor-frames S:to-next-floor-frame  #;+konfig-jakis?))
;;;; -- obiekt ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-accessors (O:id
                   O:sector O:x O:y
                   O:dx O:dy
                   O:STATE O:name
                   O:step O:on-collision O:on-action))
;;; -- "ramka podlogowa" ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-accessors (F:length F:tiles))
;;; -- kafel podlowogy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-accessors (FT:x FT:y FT:sprite))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; a tera ta: atomowe operacje na świecie T=[W->W]

;;; cmp: TxT -> T
(define cmp (lambda (t1 t2) (lambda (world) (t2 (t1 world)))))

;;; i) Id:W->W, Id(w)=w dla w:-W,
(define T:identity (lambda (world) world))

;;;; zanurzenie albo co jeszcze gorszego
(define (mk-AL-operation al-op)
  (lambda (object)
    (lambda (world)
      (let* ((object-id (O:id object))
	     (sector-id (O:sector object))
	     (object (cdr object)))
	`(,(map (lambda (sector)
		  (if (eq? (S:id sector) sector-id)
		      (list (S:id sector)
			    (al-op object-id object (S:objects sector))
			    (S:floor-frames sector)
			    (S:to-next-floor-frame sector))
		      sector))
		(W:sectors world)))))))
;;; ii-iv) update<o>, insert<o>, delete<o> : W->W dla o:-O,
(define T:update<o> (mk-AL-operation AL:update))
(define T:insert<o> (mk-AL-operation AL:insert))
(define T:delete<o> (mk-AL-operation AL:delete))

;;; v) move<o> : O->(W->W)
(define T:move<o> (lambda (object)
		    (lambda (world)
		      (let* ((object-id (O:id object))
			     (sector (O:sector object))
			     (x (O:x object))
			     (y (O:y object))
			     (dx (O:dx object))
			     (dy (O:dy object))
			     (nx (+ x dx))
			     (ny (+ y dy))
			     (something? (find-at sector nx ny world)))
;    (write `(t-move leci o= ,object dx= ,dx dy= ,dy smt= ,something?)) (newline) ;;;
			(if (or (not (= dx 0))
				(not (= dy 0)))
			    (if something?				
				 ((O:on-collision something?) something? object world)
				 ((T:update<o> `(,object-id ,sector ,nx ,ny ,dx ,dy . ,(cdddr (cdddr object))))
				  world))
			    (T:identity world))))))

;;; vi) action<o> : O->(W->W)
(define T:action<o> (lambda (object)
		      (lambda (world)
			(let* ((object-id (O:id object))
			       (sector (O:sector object))
			       (x (O:x object))
			       (y (O:y object))
			       (dx (O:dx object))
			       (dy (O:dy object))
			       (nx (+ x dx))
			       (ny (+ y dy))
			       (something? (find-at sector nx ny world)))
			  (if something?
			       ((O:on-action something?) something? object world)
			       (T:identity world))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; gotowe? teraz troszkę magii posiłkowej dla predykatów (odpytwań do świata):

(define (find object-id world)
  (let loop ((sectors (W:sectors world)))
    (if (null? sectors)
	#f
	(let* ((sector (car sectors))
	       (sectors (cdr sectors))
	       (found (filter (lambda (o) (eq? (O:id o) object-id)) (S:objects sector))))
	  (if (null? found)
	      (loop sectors)
	      (car found))))))
;(find 'b '(((s1 ((a 1) (b 1) (c 1))) (s2 ((q 2) (dupa 2) (w 2))) )))

(define (find-at sector-id x y world)
  (let* ((objects (car (AL:lookup sector-id (W:sectors world))))
	 (found (filter (lambda (o)
			  (and (eq? (O:x o) x)
			       (eq? (O:y o) y)))
			objects)))
    (if (null? found)
	#f
	(car found))))
;(find-at 's1 1 1 '(((s1 ((a 1 4 5) (b 1 2 3) (c 1 1 1))) (s2 ((q 2) (dupa 2) (w 2))) )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; a teraz procedury kroku!

(define id-step (lambda (x s) s))


(define (hero-step self world)
; (write *joystick*) (newline)
  ((match *joystick*
     ('0 T:identity)
     ('N (try-walk self 0 -1))
     ('E (try-walk self 1 0)) 
     ('W (try-walk self -1 0))
     ('S (try-walk self 0 1)) 
     ('A (try-action self)))
   world))
  
(define (try-walk self dx dy)
  (lambda (world)
    (let* ((new-self `(,(O:id self)
		       ,(O:sector self)
		       ,(O:x self)
		       ,(O:y self)
		       ,dx
		       ,dy
		       . ,(cdddr (cdddr self))))
	   (world1 ((T:update<o> new-self) world)))
      ((T:move<o> new-self) world1))))

(define (try-action self) ;;; !!
  (lambda (world)  
;    (write `(try-ac ,self)) (newline)
    (let* ((sector (O:sector self))
	   (x (O:x self))
	   (y (O:y self))
	   (dx (O:dx self))
	   (dy (O:dy self))
	   (nx (+ x dx))
	   (ny (+ y dy))
	   (something? (find-at sector nx ny world)))
;      (write something?)(newline)
      (if (or (not (= dx 0))
	      (not (= dy 0)))
	  (if something?
	      ((O:on-action something?) something? self world)
	      ((O:on-action self) self self world))
	  (T:identity world)))))


(define (evil-step obj world)
;  world
  (let* ((object-id (O:id obj))
	 (sector-id (O:sector obj))
	 (x (O:x obj))
	 (y (O:y obj))
	 (dx (O:dx obj))
	 (dy (O:dy obj))
	 (nx (+ x dx))
	 (ny (+ y dy))
	 (something? (find-at sector-id nx ny world)))
    (if something?	
	((T:update<o> `(,object-id ,sector-id ,x ,y ,(* dx -1) ,(* dy -1) . ,(cdddr (cdddr obj))))
	 ((if (eq? (O:id something?) 'HERO)
	      (T:delete<o> something?)
	      T:identity)
	  world))
	((T:move<o> obj) world))))


(define (beam-step obj world)
  (let* ((object-id (O:id obj))
	 (sector-id (O:sector obj))
	 (x (O:x obj))
	 (y (O:y obj))
	 (dx (O:dx obj))
	 (dy (O:dy obj))
	 (nx (+ x dx))
	 (ny (+ y dy))
	 (something? (find-at sector-id nx ny world)))
    (if something?
	(explode-collision `(,object-id ,sector-id ,x ,y ,(* dx -1) ,(* dy -1) . ,(cdddr (cdddr obj)))
			   something?
			   world)
	((T:move<o> obj) world))))


(define (laser-step obj world)
  (let* ((object-id (O:id obj))
	 (sector-id (O:sector obj))
	 (time (AL:lookup 'TIME (O:STATE obj)))
	 (x (O:x obj))
	 (y (O:y obj))
	 (dx (O:dx obj))
	 (dy (O:dy obj))
	 (nx (+ x dx))
	 (ny (+ y dy))
	 (something? (find-at sector-id nx ny world)))
;    (write `(l-s ,time)) (newline)
    (cond ((= time 0)
	   (if something?
	       world
	       ((cmp (T:update<o> `(,object-id ,sector-id ,x ,y ,dx ,dy ,(AL:update 'TIME 1 (O:STATE obj)) . ,(cdddr (cddddr obj))))
		     (T:insert<o> `(,(gensym "LASERBEAM") ,sector-id ,nx ,ny ,dx ,dy () "a laser beam" ,beam-step ,explode-collision ,id-action)))
		world)))
	  ((> time 6)
	   ((T:update<o> `(,object-id ,sector-id ,x ,y ,dx ,dy ,(AL:update 'TIME 0 (O:STATE obj)) . ,(cdddr (cddddr obj)))) world))
	  (else
	   ((T:update<o> `(,object-id ,sector-id ,x ,y ,dx ,dy ,(AL:update 'TIME (+ time 1) (O:STATE obj)) . ,(cdddr (cddddr obj)))) world)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; i procedury kolizji

(define id-collision (lambda (x y s) ;(write 'id-col) (newline)
		       s))
		   
(define push-collision
  (lambda (me it world)
;    (write `(push-col ,me ,it)) (newline)
    (let* ((sector-id (O:sector me))
	   (my-x (O:x me))
	   (my-y (O:y me))
	   (its-dx (O:dx it))
	   (its-dy (O:dy it))
	   (nx (+ my-x its-dx))
	   (ny (+ my-y its-dy))
	   (something? (find-at sector-id nx ny world)))
      ((if something?
	   T:identity
	   (cmp (T:update<o> `(,(O:id me) ,sector-id ,my-x ,my-y ,its-dx ,its-dy . ,(cdddr (cdddr me))))
		(cmp (T:move<o> me)
		     (cmp (T:move<o> it)
			  (lambda (world)
			    (let* ((me (find (O:id me) world)))
			      ((T:update<o> `(,(O:id me) ,(O:sector me) ,(O:x me) ,(O:y me) 0 0 . ,(cdddr (cdddr me))))
			       world)))))))
       world))))
	   

(define explode-collision  
  (lambda (me it world)
;    (write 'boom) (newline)
    ((if (or (string=? (O:name it) "Uwall") (string=? (O:name it) "Lwall"))
	(T:delete<o> me)
	(cmp (T:delete<o> it)
	     (T:delete<o> me)))
     world)))


(define evil-collision
  (lambda (me it world)
;    (write 'boom) (newline)
    ((if (string=? (O:name it) "the hero")
	(cmp (T:delete<o> me)
	     (T:delete<o> it))
	T:identity)
     world)))


;;; ??
(define mirror-collision
  (lambda (me it world)
    ((O:on-collision it) it me world)))


(define pick-collision
  (lambda (me it world) ;;;; tuu będzie kiedyś ZDARZENIE z komunikatem, dla beki.
    (begin
;      (write `(pick ,me ,it)) (newline)
      (mk-message '(("WELL DONE, YOU FOUND A SAMPLE OF NIDERITE!" 180 166)
		    ("PRESS FIRE." 180 196))
		  (cmp (T:update<o> `(,(O:id it)
				      ,(O:sector it) ,(O:x it) ,(O:y it)
				      ,(O:dx it) ,(O:dy it)
				      ,(let* ((niderite (AL:lookup 'NIDERITE (O:STATE it)))
					      (new-niderite (if niderite
								(+ niderite 6)
								6)))
					; (write `(NIDERYT -- ,new-niderite)) (newline)
					 (AL:update-insert 'NIDERITE new-niderite (O:STATE it)))
				      . ,(cdddr (cddddr it))))
		       (T:delete<o> me)))
      world)))


(define mk-teleport-collision
  (lambda (nx ny ndx ndy)
    (lambda (me it world) ;;;; tuu będzie kiedyś ZDARZENIE z komunikatem, dla beki.
      (mk-message '(("YOU HAVE BEEN TELEPORTED." 180 166)
		    ("PRESS FIRE." 180 196))
		  (T:update<o> `(,(O:id it)
				 ,(O:sector it) ,nx ,ny
				 ,ndx ,ndy		       
				 . ,(cdddr (cdddr it)))))
      world)))


(define door-collision 
  (lambda (me it world)
;    (write `(door-c ,me ,it)) (newline)
    (T:identity world)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; iii procedury akcji

(define id-action (lambda (me it world) world))

(define hero-action
  (lambda (me it world)
 ;   (write `(hero-act ,me ,it)) (newline)
    (let* ((new-x (+ (O:x me) (O:dx me)))
	   (new-y (+ (O:y me) (O:dy me)))
	   (sector (O:sector me))
	   (obstacle? (find-at sector new-x new-y world))
	   (carrying (AL:lookup 'CARRYING (O:STATE me)))
	   (carrying1 (if carrying
			  `(,(O:id carrying)
			    ,(O:sector me) ,new-x ,(+ (O:y me) (O:dy me))
			    ,(O:dx me) ,(O:dy me)
			    . ,(cdddr (cdddr carrying)))
			  #f))
	   (new-state (AL:delete 'CARRYING 23 (O:STATE me) ))
	   (new-me `(,(O:id me)
		     ,(O:sector me) ,(O:x me) ,(O:y me) ,(O:dx me) ,(O:dy me)
		     ,new-state
		     . ,(cdddr (cddddr me)))))
      (if (and carrying
	       (not obstacle?))
	  ((cmp (T:insert<o> carrying1) (T:update<o> new-me)) world)
	  (T:identity world)))))

(define pick-action
  (lambda (me it world)
;    (write `(-> ,(AL:update-insert 'CARRYING me (O:STATE it)))) (newline)
    (mk-message `((,(string-append "YOU HAVE PICKED " (O:name me) ".") 180 166)
		    ("PRESS FIRE." 180 196))
		(cmp (T:update<o> `(,(O:id it)
				    ,(O:sector it) ,(O:x it) ,(O:y it)
				    ,(O:dx it) ,(O:dy it)
				    ,(AL:update-insert 'CARRYING me (O:STATE it))
				    . ,(cdddr (cddddr it))))
		     (T:delete<o> me)))
    world))

(define open-action
  (lambda (me it world)
;    (write `(open-act ,me ,it)) (newline)
    (let ((carrying (AL:lookup 'CARRYING (O:STATE it))))
      (if (and carrying
	       (string=? (O:name carrying) "a key"))
	  ((T:delete<o> me) world)
	  ((T:delete<o> it) world)))))


;(AL:update-insert 'x 5 (AL:new '(q w e) '(1 2 3)))
;;; ...


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; wreszcie 1 krok świata -- step każdego z obiektów w sektorze w którym znajduje się bohater

(define (std-step world)
  (let* ((hero (find 'HERO world))
	 (sector-id (O:sector hero))
	 (sector (cons sector-id (AL:lookup sector-id (W:sectors world))))
	 (objects (S:objects sector))
	 (floors (S:floor-frames sector))
	 (to-next (S:to-next-floor-frame sector))
	 ;;; no i przeliczyć podłogi!
	 (new-world `(,(map (lambda (sec)
			      (if (eq? (S:id sec) sector-id)
				  (let* ((floor-frames (S:floor-frames sec))
					 (cur-frame (car floor-frames))
					 (frame-length (F:length cur-frame)))
				    (if (> to-next 0)
					`(,sector-id ,objects ,floors ,(- to-next 1))
					(let* ((new-floors (rot-list floor-frames))
					       (new-cur-frame (car new-floors))
					       (new-to-next (F:length new-cur-frame)))
					  `(,sector-id ,objects ,new-floors ,new-to-next))))
				  sec))
			    (W:sectors world)))))
    (let loop ((pend objects)
	       (world new-world))
      (if (null? pend)
	  world
	  (loop (cdr pend)
		((O:step (car pend)) (car pend) world))))))
	  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; tadaam. wszystko.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; the i/o crap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(cond-expand 
 (slayer-audio (use-modules (slayer audio)) (display "using audio\n"))
 (else (define load-sound noop)
       (define play-sound! noop)
       (display "dismissing audio\n")))

#;(define *samples* (list->array 1 `(,(load-sound "pandora-art/click.wav")
				   ,(load-sound "pandora-art/beep.wav"))))

(set-window-title! "Fear of the dark!")
(set-screen-size! 640 480)

(define *sprites* (list->array 1 `(,(load-image "robbot-art/ludek.png") ; 0
				   ,(load-image "robbot-art/crate.png") ; 1
				   ,(load-image "robbot-art/Uwall.png") ; 2
				   ,(load-image "robbot-art/Lwall.png") ; 3
				   ,(load-image "robbot-art/b5.png") ; 4
				   ,(load-image "robbot-art/b02.png") ; 5
				   ,(load-image "robbot-art/b7.png") ; 6
				   ,(load-image "robbot-art/key.png") ; 7
				   ,(load-image "robbot-art/b3.png") ; 8
				   ,(load-image "robbot-art/floor.png") ; 9 floor
				   ,(load-image "robbot-art/floor_dark.png") ; 10 floor_dark
				   ,(load-image "robbot-art/floor_a_1.png") ; 11
				   ,(load-image "robbot-art/floor_b_1.png") ; 12
				   ,(load-image "robbot-art/floor_a_2.png") ; 13
				   ,(load-image "robbot-art/floor_b_2.png") ; 14
				   ,(load-image "robbot-art/floor_a_3.png") ; 15
				   ,(load-image "robbot-art/floor_b_3.png") ; 16
				   ,(load-image "robbot-art/floor_a_4.png") ; 17
				   ,(load-image "robbot-art/floor_b_4.png") ; 18
				   ,(load-image "robbot-art/floor_a_5.png") ; 19
				   ,(load-image "robbot-art/floor_b_5.png") ; 20
				   )))

(define *font* (load-font "robbot-art/VeraMono.ttf" 11))

(define *display* '()) ;; !!

(define (mk-display-message msg x y)
  (lambda ()    
   (draw-image! (render-text msg *font*) x y)))

(define (mk-display-messages msgs)
  (lambda ()
    (for-each (match-lambda ((msg x y)
			     (draw-image! (render-text msg *font*) x y)))
	      msgs)))

(define display-world
 (lambda()
   ;miejsce na statusbar czy co
   (for-each
    (match-lambda ((x y sprite-index)
		   (let* ((sprite (array-ref *sprites* sprite-index))
			  (size (image-size sprite))
			  (height (cadr size))
			  (y1 (- y (- height 32))))
		     (if (and (> x -33)
			      (> y -33)
			      (< x 673)
			      (< y1 481))
			 (draw-image! sprite x y1)))))
    *display*)))

(define *joystick* 0)

(keydn 'space (lambda () (set! *joystick* 'A)))
(keydn 'up    (lambda () (set! *joystick* 'N)))
(keydn 'right (lambda () (set! *joystick* 'E)))
(keydn 'left  (lambda () (set! *joystick* 'W)))
(keydn 'down  (lambda () (set! *joystick* 'S)))

(keyup 'up    (lambda () (set! *joystick* 0)))
(keyup 'down  (lambda () (set! *joystick* 0)))
(keyup 'right (lambda () (set! *joystick* 0)))
(keyup 'left  (lambda () (set! *joystick* 0)))
;(keyup 'space (lambda () (set! *joystick* 0)))

(keydn 'esc quit)
(keydn 'q quit)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; the isometric gfx crap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (set-to-display! view)
;  (write view) (newline)
  (let* ((objects (car view))
	 (floors (cdr view))
	 (tile-half-width 32)
	 (tile-half-height 16)
	 (center-x 320)
	 (top-y 0)
	 (hero-visual-x 11.0)
	 (hero-visual-y 11.0)
	 (hero (cons 'HERO (AL:lookup 'HERO objects)))
	 (hero-x (O:x hero))
	 (hero-y (O:y hero))
	 (diff-x (- hero-visual-x hero-x))
	 (diff-y (- hero-visual-y hero-y)))
;(write `(,hero hx= ,hero-x hy= ,hero-y dx= ,diff-x dy= ,diff-y)) (newline)
    (set! *display*
	  (append
	   ;;; podlogi [swiatlo]:
	   (map (match-lambda ((map-x map-y sprite-index)
			       (let* ((map-x (+ map-x diff-x)) ;; centrowanie na bohatera
				      (map-y (+ map-y diff-y)) ;; 
				      (disp-x
				       (+ (- center-x tile-half-width)
					  (* tile-half-width (- map-x map-y))))
				      (disp-y
				       (+ top-y
					  (* tile-half-height (+ map-x map-y)))))
				 `(,(to-int disp-x) ,(to-int disp-y) ,sprite-index))))
		floors)
	   ;;; obiekty:
	   (map (match-lambda ((id sector map-x map-y dx dy state name . _)
			       (let* ((map-x (+ map-x diff-x)) ;; centrowanie na bohatera
				      (map-y (+ map-y diff-y)) ;; 
				      (disp-x
				       (+ (- center-x tile-half-width)
					  (* tile-half-width (- map-x map-y))))
				      (disp-y
				       (+ top-y
					  (* tile-half-height (+ map-x map-y))))
				      (sprite-index
				       ((match-lambda 
				       	      ("the hero" 0)
						      ("an evil" 1)
						      ("carpet" 5)
						      ("Hdoor" 6)
						      ("a key" 7)
						      ("Uwall" 2)
						      ("Lwall" 3)
						      ("Uwindow" 3)
						      ("stair-wall" 2)
						      ("stair3" 2)
						      ("stair2" 1)
						      ("stair1" 3)
						      ("a laser beam" 3)
						      ("a laser gun" 3)
						      ("a niderite sample" 4)
						      (otherwise 6) ;?
						      ) name)))
				 `(,(to-int disp-x) ,(to-int disp-y) ,sprite-index))))
		(sort-objects-for-display objects hero-x hero-y))
	   '()  ;; do rysowania dodatkowego krapu
	   ))))


(define (current-view world)
  (let* ((hero (find 'HERO world))
	 (sector-id (O:sector hero))
	 (sector (cons sector-id (AL:lookup sector-id (W:sectors world)))))
    (cons (S:objects sector) (cadar (S:floor-frames sector)))))


(define (sort-objects-for-display visibles-list hx hy)
  (let* ((viewport-safe-distance 16)
	 (visibles-list (filter (match-lambda ((id sector x y . cośtam-cośtam) ;;;;;;;;; !!!!!!!!!!!!!!!!!
					       (and (< x (+ hx viewport-safe-distance))
						   (> x (- hx viewport-safe-distance))
						   (< y (+ hy viewport-safe-distance))
						   (> y (- hy viewport-safe-distance)))))
				visibles-list))
	 (dist-from-origin ;; sq.rt. is monotone anyway, and for some reason the observer stands at (666,666).
	  (match-lambda ((id sector x y . _)
			 (+ (* (- 666.0 x) (- 666.0 x))
			    (* (- 666.0 y) (- 666.0 y)))))))
;    (write (length visibles-list)) (newline)
    (sort visibles-list
	  (lambda (a b)
	     (> (dist-from-origin a)
		(dist-from-origin b))))))	   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; the main loop crap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define *state* 
  `(,(list 
  	; (include "maps/foyer.scm")
    (include "maps/hallway.scm")
   )))

(add-timer! 200
	    (lambda()
;	      (write (if (pair? *general-game-state*) (car *general-game-state*) *general-game-state*)) (newline)
	      (match *general-game-state*
		('PLAY
		 (let ((old-state *state*))
		   (set-display-procedure! display-world)
		   (set-to-display! (current-view *state*))
		   (set! *state* (std-step *state*))

		   (if (not (find 'HERO *state*))		       
		       (mk-message '(("YOU HAVE BEEN KILLED." 180 166)
				     ("PRESS FIRE." 180 196))
				   (T:insert<o> `(HERO 0 3 3 0 0 () "the hero" ,hero-step ,id-collision ,hero-action))))

		   (if (eq? *joystick* 'A) (set! *joystick* 0))

		   (if (and *animation-on* (eq? *general-game-state* 'PLAY))
		       (set! *general-game-state* `(ANIMATE ,old-state ,*state* 1)))
		   ))

		(('MESSAGE msgs transform)
		 (begin
;		   (write 'mesydz!) (newline)
		   (set-display-procedure!
		    (mk-display-messages msgs))
		   (if (eq? *joystick* 'A)
		       (begin (set! *state* (transform *state*))
			      (set! *general-game-state* 'PLAY)))
		   (set! *joystick* 0)))
		(('ANIMATE old new step)
		 (let ((max-steps 1.0))
		   (set-display-procedure! display-world)
		   (if (> step max-steps)
		       (begin
			 (set! *general-game-state* 'PLAY)
			 23)
		       (let* ((hero (find 'HERO old))
			      (sector-id (O:sector hero))
			      (objects (S:objects (cons sector-id (AL:lookup sector-id (W:sectors old)))))
			      (floors (cadar (S:floor-frames (cons sector-id (AL:lookup sector-id (W:sectors old))))))
			      (new-floors floors) ;; tu bedzie anonimowanie podlog!!! TODO
			      (new-objects
			       (let loop ((objects objects))
; (write `(animate loop ,(length objects))) (newline)
				 (if (null? objects)
				     '()
				     (let* ((obj-before (car objects))
					    (objects (cdr objects))
					    (obj-before-id (O:id obj-before))
					    (obj-after (find obj-before-id new)))
;				       (write `(zyje! ,obj-after ,obj-before-id #;,new)) (newline)
				       (if obj-after
					   (let* ((x-before (O:x obj-before))
						  (y-before (O:y obj-before))
						  (x-after (O:x obj-after))
						  (y-after (O:y obj-after))
						  (nx (+ x-before
							 (* (- x-after x-before)
							    (/ step (+ 1.0 max-steps)))))
						  (ny (+ y-before
							 (* (- y-after y-before)
							    (/ step (+ 1.0 max-steps))))))
;					     (write `(hejho! (,x-before ,y-before) (,x-after ,y-after) (,nx ,ny))) (newline)
					     (cons `(,obj-before-id ,sector-id ,nx ,ny . ,(cddddr obj-before))
						   (loop objects)))
			       ;;; znikanie? na razie nic...
					   (cons obj-before
						 (loop objects))))))))
			 (set-to-display! (cons new-objects new-floors))
			 (set! *general-game-state* `(ANIMATE ,old ,new ,(+ step 1)))
			 )))))))

