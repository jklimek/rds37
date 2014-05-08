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
(define-accessors (FT:x FT:y FT:shade))

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
    ((if (string=? (O:name it) "a wall")
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

(set-window-title! "r o b b o t")
(set-screen-size! 640 480)

(define *sprites* (list->array 1 `(,(load-image "robbot-art/b1.png") ; 0
				   ,(load-image "robbot-art/b2.png") ; 1
				   ,(load-image "robbot-art/b00.png") ; 2
				   ,(load-image "robbot-art/b4.png") ; 3
				   ,(load-image "robbot-art/b5.png") ; 4
				   ,(load-image "robbot-art/b9.png") ; 5
				   ,(load-image "robbot-art/b7.png") ; 6
				   ,(load-image "robbot-art/b8.png") ; 7
				   ,(load-image "robbot-art/b3.png") ; 8
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
			  (y (- y (- height 16))))
		     (draw-image! sprite x y))))
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
	 (tile-half-width 16)
	 (tile-half-height 8)
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
	   (map (match-lambda ((map-x map-y shade)
			       (let* ((map-x (+ map-x diff-x)) ;; centrowanie na bohatera
				      (map-y (+ map-y diff-y)) ;; 
				      (disp-x
				       (+ (- center-x tile-half-width)
					  (* tile-half-width (- map-x map-y))))
				      (disp-y
				       (+ top-y
					  (* tile-half-height (+ map-x map-y))))
				      (sprite-index (+ shade 1))) ;; ?
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
				       ((match-lambda ("the hero" 0)
						      ("an evil" 3)
						      ("a crate" 1)
						      ("a door" 5)
						      ("a key" 7)
						      ("a wall" 2)
						      ("a laser beam" 1)
						      ("a laser gun" 3)
						      ("a niderite sample" 4)
						      (otherwise 6) ;?
						      ) name)))
				 `(,(to-int disp-x) ,(to-int disp-y) ,sprite-index))))
		(sort-objects-for-display objects))
	   '()  ;; do rysowania dodatkowego krapu
	   ))))


(define (current-view world)
  (let* ((hero (find 'HERO world))
	 (sector-id (O:sector hero))
	 (sector (cons sector-id (AL:lookup sector-id (W:sectors world)))))
    (cons (S:objects sector) (cadar (S:floor-frames sector)))))


(define (sort-objects-for-display visibles-list)
  (let ((dist-from-origin ;; sq.rt. is monotone anyway, and for some reason the observer stands at (66,66).
	 (match-lambda ((id sector x y . _)
			(+ (* (- 66.0 x) (- 66.0 x))
			   (* (- 66.0 y) (- 66.0 y)))))))
     (sort visibles-list
	   (lambda (a b)
	     (> (dist-from-origin a)
		(dist-from-origin b))))))
	   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; the main loop crap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define *state* 
  `(((0 (
     (WALL1 0 1 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL2 0 2 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL3 0 3 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL4 0 4 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL5 0 5 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL6 0 6 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL7 0 7 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL8 0 8 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL9 0 9 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL10 0 10 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL11 0 11 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL12 0 12 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL13 0 13 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL14 0 14 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL15 0 15 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL16 0 16 1 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL17 0 1 2 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL18 0 5 2 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (CRATE19 0 7 2 0 0 () "a crate" ,id-step ,push-collision ,id-action)
     (WALL20 0 9 2 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL21 0 11 2 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL22 0 16 2 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL23 0 1 3 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (HERO 0 3 3 0 0 (,(cons 'NIDERITE 0)) "the hero" ,hero-step ,id-collision ,hero-action)
     (WALL25 0 5 3 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL26 0 7 3 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (CRATE27 0 9 3 0 0 () "a crate" ,id-step ,push-collision ,id-action)
     (WALL28 0 16 3 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL29 0 1 4 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL30 0 5 4 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL31 0 7 4 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (CRATE32 0 8 4 0 0 () "a crate" ,id-step ,push-collision ,id-action)
     (WALL33 0 9 4 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL34 0 11 4 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (EVIL1 0 13 4 0 -1 () "an evil" ,evil-step ,evil-collision ,id-action)
     (WALL36 0 16 4 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL37 0 1 5 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL38 0 5 5 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL39 0 11 5 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL40 0 16 5 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL41 0 1 6 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL42 0 5 6 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL43 0 6 6 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL44 0 7 6 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (CRATE45 0 8 6 0 0 () "a crate" ,id-step ,push-collision ,id-action)
     (WALL46 0 9 6 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL47 0 10 6 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL48 0 11 6 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL49 0 12 6 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL50 0 14 6 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL51 0 15 6 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL52 0 16 6 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL53 0 1 7 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL54 0 5 7 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL55 0 10 7 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL56 0 16 7 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL57 0 1 8 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL58 0 2 8 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (CRATE59 0 3 8 0 0 () "a crate" ,id-step ,push-collision ,id-action)
     (WALL60 0 4 8 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL61 0 5 8 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (CRATE62 0 8 8 0 0 () "a crate" ,id-step ,push-collision ,id-action)
     (WALL63 0 10 8 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL64 0 12 8 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL65 0 14 8 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL66 0 16 8 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL67 0 1 9 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (CRATE68 0 7 9 0 0 () "a crate" ,id-step ,push-collision ,id-action)
     (WALL69 0 10 9 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL70 0 16 9 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL71 0 1 10 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL72 0 5 10 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL73 0 10 10 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL74 0 12 10 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL75 0 14 10 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL76 0 16 10 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL77 0 1 11 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (CRATE78 0 2 11 0 0 () "a crate" ,id-step ,push-collision ,id-action)
     (CRATE79 0 3 11 0 0 () "a crate" ,id-step ,push-collision ,id-action)
     (CRATE80 0 4 11 0 0 () "a crate" ,id-step ,push-collision ,id-action)
     (WALL81 0 5 11 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL82 0 10 11 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL83 0 16 11 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL84 0 1 12 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL85 0 5 12 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL86 0 16 12 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL87 0 1 13 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL88 0 2 13 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (CRATE89 0 3 13 0 0 () "a crate" ,id-step ,push-collision ,id-action)
     (WALL90 0 4 13 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL91 0 5 13 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL92 0 6 13 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL93 0 7 13 0 0 () "a wall" ,id-step ,id-collision ,id-action)

     (TELEPORT1 0 8 16 0 0 () "a teleport" ,id-step ,(mk-teleport-collision 12 2 0 1) ,id-action) ;; !

     (WALL94 0 9 13 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL95 0 10 13 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL96 0 11 13 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL97 0 12 13 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL98 0 14 13 0 0 () "a wall" ,id-step ,id-collision ,id-action)
;     (WALL99 0 15 13 0 0 () "a wall" ,id-step ,id-collision ,id-action) ;; !!
     (WALL100 0 16 13 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL101 0 1 14 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (EVIL2 0 8 12 1 0 () "an evil" ,evil-step ,evil-collision ,id-action)
     (WALL103 0 16 14 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL104 0 1 15 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL105 0 16 15 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL106 0 1 16 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL107 0 2 16 0 0 () "a wall" ,id-step ,id-collision ,id-action)

     (NID1 0 3 15 0 0 () "a niderite sample" ,id-step ,pick-collision ,id-action) ;; ?

     (KEY1 0 2 15 0 0 () "a key" ,id-step ,id-collision ,pick-action) ;; ?
     (DOOR1 0 15 13 0 0 () "a door" ,id-step ,door-collision ,open-action) ;; ?

     (WALL108 0 3 16 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL109 0 4 16 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL110 0 5 16 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL111 0 6 16 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL112 0 7 16 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL113 0 9 16 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL114 0 10 16 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL115 0 11 16 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL116 0 12 16 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL117 0 13 16 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL118 0 14 16 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL119 0 15 16 0 0 () "a wall" ,id-step ,id-collision ,id-action)
     (WALL120 0 15 15 0 0 () "a wall" ,id-step ,id-collision ,id-action)

    (LASER1 0 15 14 -1 0 ( ,(cons 'TIME 0) ) "a laser gun" ,laser-step ,id-collision ,(lambda (me it world) ((T:delete<o> me) world)))
     )
	;;; tera podlogowe
	;;; sekw. podlogowa:
	(
	 (3 ((2 2 2) (2 3 2) (3 2 2) (3 3 1)))
	 (2 ((2 2 1) (2 3 1) (3 2 1) (4 4 2)))
	)
	;;; (ile do nastepnego)
	1

     ))))

;(car (AL:lookup 0 (W:sectors *state*)))

(add-timer! 66
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
			      (floors (S:floor-frames (cons sector-id (AL:lookup sector-id (W:sectors old)))))
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

