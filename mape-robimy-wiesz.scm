(use-modules (srfi srfi-1) (ice-9 match) (ice-9 pretty-print))

;;; muki:
(define id-step 'DUPAid-step #;(lambda (x s) s))
(define id-collision 'DUPAid-collision #;(lambda (x y s) s))
(define id-action 'DUPAid-action #;(lambda (me it world) world))

(define hero-action id-action)
(define hero-step id-step)
;;; \muki


(define mapa-stara '(
	;;hero
	(HERO 0 8 63 0 0 (,(cons 'NIDERITE 0)) "the hero" ,hero-step ,id-collision ,hero-action)
	;;hallway upper left wall
	(Uwall1:2 0 1 2 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:5 0 1 5 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:6 0 1 6 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:9 0 1 9 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:10 0 1 10 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:13 0 1 13 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:14 0 1 14 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:17 0 1 17 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:18 0 1 18 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:21 0 1 21 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:22 0 1 22 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:25 0 1 25 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:26 0 1 26 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:29 0 1 29 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:30 0 1 30 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:33 0 1 33 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:34 0 1 34 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:37 0 1 37 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:38 0 1 38 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:41 0 1 41 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:42 0 1 42 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:45 0 1 45 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:46 0 1 46 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:49 0 1 49 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:50 0 1 50 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:53 0 1 53 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:54 0 1 54 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:57 0 1 57 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:58 0 1 58 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:61 0 1 61 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:62 0 1 62 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:63 0 1 63 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall1:64 0 1 64 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	;;hallway lower right wall
	(Lwall14:2 0 14 2 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:3 0 14 3 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:4 0 14 4 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:5 0 14 5 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:6 0 14 6 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:7 0 14 7 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:8 0 14 8 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:9 0 14 9 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:10 0 14 10 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:11 0 14 11 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:12 0 14 12 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:13 0 14 13 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:14 0 14 14 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:15 0 14 15 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:16 0 14 16 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:17 0 14 17 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:18 0 14 18 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:19 0 14 19 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:20 0 14 20 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:21 0 14 21 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:22 0 14 22 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:23 0 14 23 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:24 0 14 24 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:25 0 14 25 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:26 0 14 26 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:27 0 14 27 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:28 0 14 28 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:29 0 14 29 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:30 0 14 30 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:31 0 14 31 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:32 0 14 32 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:33 0 14 33 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:34 0 14 34 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:35 0 14 35 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:36 0 14 36 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:37 0 14 37 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:38 0 14 38 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:39 0 14 39 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:40 0 14 40 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:41 0 14 41 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:42 0 14 42 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:43 0 14 43 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:44 0 14 44 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:45 0 14 45 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:46 0 14 46 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:47 0 14 47 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:48 0 14 48 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:49 0 14 49 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:50 0 14 50 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:51 0 14 51 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:52 0 14 52 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:53 0 14 53 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:54 0 14 54 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:55 0 14 55 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:56 0 14 56 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:57 0 14 57 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:58 0 14 58 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:59 0 14 59 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:60 0 14 60 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:61 0 14 61 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:62 0 14 62 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:63 0 14 63 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	;;hallway upper right wall
	(Uwall1:1 0 1 1 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall2:1 0 2 1 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall3:1 0 3 1 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall4:1 0 4 1 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall5:1 0 5 1 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall6:1 0 6 1 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall9:1 0 9 1 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall10:1 0 10 1 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall11:1 0 11 1 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall12:1 0 12 1 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall13:1 0 13 1 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	(Uwall14:1 0 14 1 0 0 () "Uwall" ,id-step ,id-collision ,id-action)
	;;hallway lower left wall
	(Lwall2:64 0 2 64 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall3:64 0 3 64 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall4:64 0 4 64 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall5:64 0 5 64 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall6:64 0 6 64 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall9:64 0 9 64 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall10:64 0 10 64 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall11:64 0 11 64 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall12:64 0 12 64 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall13:64 0 13 64 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	(Lwall14:64 0 14 64 0 0 () "Lwall" ,id-step ,id-collision ,id-action)
	;;upper left windows I level
	(Uwindow1:3 0 1 3 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:4 0 1 4 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:7 0 1 7 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:8 0 1 8 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:11 0 1 11 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:12 0 1 12 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:15 0 1 15 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:16 0 1 16 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:19 0 1 19 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:20 0 1 20 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:23 0 1 23 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:24 0 1 24 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:27 0 1 27 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:28 0 1 28 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:31 0 1 31 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:32 0 1 32 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:35 0 1 35 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:36 0 1 36 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:39 0 1 39 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:40 0 1 40 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:43 0 1 43 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:44 0 1 44 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:47 0 1 47 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:48 0 1 48 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:51 0 1 51 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:52 0 1 52 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:55 0 1 55 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:56 0 1 56 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:59 0 1 59 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	(Uwindow1:60 0 1 60 0 0 () "Uwindow" ,id-step ,id-collision ,id-action)
	;;door in
	(Hdoor7:64 0 7 64 0 0 () "Hdoor" ,id-step ,id-collision ,id-action)
	(Hdoor8:64 0 8 64 0 0 () "Hdoor" ,id-step ,id-collision ,id-action)
	;;door out
	(Hdoor7:1 0 7 1 0 0 () "Hdoor" ,id-step ,id-collision ,id-action)
	(Hdoor8:1 0 8 1 0 0 () "Hdoor" ,id-step ,id-collision ,id-action)
	))

(pretty-print
 (map (match-lambda ((id sector-id x y dx dy state name . rest)   
		    (let ((s-id (match name
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
				  (otherwise 6))))
		      `(,id ,sector-id ,x ,y ,dx ,dy ,state ,name ,s-id . ,rest))))
     mapa-stara) )

(match (car mapa-stara)
  ((id sector-id x y dx dy state name . _) name))


		  
(+ 2 3)

dostajemi:

((HERO 0
       8
       63
       0
       0
       (,(cons 'NIDERITE 0))
       "the hero"
       0
       ,hero-step
       ,id-collision
       ,hero-action)
 (Uwall1:2
   0
   1
   2
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:5
   0
   1
   5
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:6
   0
   1
   6
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:9
   0
   1
   9
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:10
   0
   1
   10
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:13
   0
   1
   13
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:14
   0
   1
   14
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:17
   0
   1
   17
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:18
   0
   1
   18
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:21
   0
   1
   21
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:22
   0
   1
   22
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:25
   0
   1
   25
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:26
   0
   1
   26
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:29
   0
   1
   29
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:30
   0
   1
   30
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:33
   0
   1
   33
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:34
   0
   1
   34
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:37
   0
   1
   37
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:38
   0
   1
   38
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:41
   0
   1
   41
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:42
   0
   1
   42
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:45
   0
   1
   45
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:46
   0
   1
   46
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:49
   0
   1
   49
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:50
   0
   1
   50
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:53
   0
   1
   53
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:54
   0
   1
   54
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:57
   0
   1
   57
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:58
   0
   1
   58
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:61
   0
   1
   61
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:62
   0
   1
   62
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:63
   0
   1
   63
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:64
   0
   1
   64
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:2
   0
   14
   2
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:3
   0
   14
   3
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:4
   0
   14
   4
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:5
   0
   14
   5
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:6
   0
   14
   6
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:7
   0
   14
   7
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:8
   0
   14
   8
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:9
   0
   14
   9
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:10
   0
   14
   10
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:11
   0
   14
   11
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:12
   0
   14
   12
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:13
   0
   14
   13
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:14
   0
   14
   14
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:15
   0
   14
   15
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:16
   0
   14
   16
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:17
   0
   14
   17
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:18
   0
   14
   18
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:19
   0
   14
   19
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:20
   0
   14
   20
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:21
   0
   14
   21
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:22
   0
   14
   22
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:23
   0
   14
   23
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:24
   0
   14
   24
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:25
   0
   14
   25
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:26
   0
   14
   26
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:27
   0
   14
   27
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:28
   0
   14
   28
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:29
   0
   14
   29
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:30
   0
   14
   30
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:31
   0
   14
   31
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:32
   0
   14
   32
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:33
   0
   14
   33
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:34
   0
   14
   34
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:35
   0
   14
   35
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:36
   0
   14
   36
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:37
   0
   14
   37
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:38
   0
   14
   38
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:39
   0
   14
   39
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:40
   0
   14
   40
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:41
   0
   14
   41
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:42
   0
   14
   42
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:43
   0
   14
   43
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:44
   0
   14
   44
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:45
   0
   14
   45
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:46
   0
   14
   46
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:47
   0
   14
   47
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:48
   0
   14
   48
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:49
   0
   14
   49
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:50
   0
   14
   50
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:51
   0
   14
   51
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:52
   0
   14
   52
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:53
   0
   14
   53
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:54
   0
   14
   54
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:55
   0
   14
   55
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:56
   0
   14
   56
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:57
   0
   14
   57
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:58
   0
   14
   58
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:59
   0
   14
   59
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:60
   0
   14
   60
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:61
   0
   14
   61
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:62
   0
   14
   62
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:63
   0
   14
   63
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall1:1
   0
   1
   1
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall2:1
   0
   2
   1
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall3:1
   0
   3
   1
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall4:1
   0
   4
   1
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall5:1
   0
   5
   1
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall6:1
   0
   6
   1
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall9:1
   0
   9
   1
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall10:1
   0
   10
   1
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall11:1
   0
   11
   1
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall12:1
   0
   12
   1
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall13:1
   0
   13
   1
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Uwall14:1
   0
   14
   1
   0
   0
   ()
   "Uwall"
   2
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall2:64
   0
   2
   64
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall3:64
   0
   3
   64
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall4:64
   0
   4
   64
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall5:64
   0
   5
   64
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall6:64
   0
   6
   64
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall9:64
   0
   9
   64
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall10:64
   0
   10
   64
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall11:64
   0
   11
   64
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall12:64
   0
   12
   64
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall13:64
   0
   13
   64
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Lwall14:64
   0
   14
   64
   0
   0
   ()
   "Lwall"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:3
   0
   1
   3
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:4
   0
   1
   4
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:7
   0
   1
   7
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:8
   0
   1
   8
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:11
   0
   1
   11
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:12
   0
   1
   12
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:15
   0
   1
   15
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:16
   0
   1
   16
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:19
   0
   1
   19
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:20
   0
   1
   20
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:23
   0
   1
   23
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:24
   0
   1
   24
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:27
   0
   1
   27
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:28
   0
   1
   28
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:31
   0
   1
   31
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:32
   0
   1
   32
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:35
   0
   1
   35
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:36
   0
   1
   36
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:39
   0
   1
   39
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:40
   0
   1
   40
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:43
   0
   1
   43
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:44
   0
   1
   44
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:47
   0
   1
   47
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:48
   0
   1
   48
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:51
   0
   1
   51
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:52
   0
   1
   52
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:55
   0
   1
   55
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:56
   0
   1
   56
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:59
   0
   1
   59
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Uwindow1:60
   0
   1
   60
   0
   0
   ()
   "Uwindow"
   3
   ,id-step
   ,id-collision
   ,id-action)
 (Hdoor7:64
   0
   7
   64
   0
   0
   ()
   "Hdoor"
   6
   ,id-step
   ,id-collision
   ,id-action)
 (Hdoor8:64
   0
   8
   64
   0
   0
   ()
   "Hdoor"
   6
   ,id-step
   ,id-collision
   ,id-action)
 (Hdoor7:1
   0
   7
   1
   0
   0
   ()
   "Hdoor"
   6
   ,id-step
   ,id-collision
   ,id-action)
 (Hdoor8:1
   0
   8
   1
   0
   0
   ()
   "Hdoor"
   6
   ,id-step
   ,id-collision
   ,id-action))
