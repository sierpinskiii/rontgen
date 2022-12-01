#!/usr/bin/env gosh
;; Authentication and session management example for Gauche 0.9.5 and later.
;; Run this script in the top directory of Gauche-makiki

(add-load-path ".." :relative)
(use gauche.parseopt)
(use gauche.threads)
(use text.html-lite)
(use util.match)
(use data.cache)
(use srfi-27)
(use makiki)

;; application
(define-class <app> ()
  (;; session table is just a TTLR cache, keyed by session token in the cookie.
   ;; session data :
   ;;  (#f . <path>)     - a non-logged-in client is trying to access <path>
   ;;  (#t . <username>) - logged in.
   [sessions :init-form (make-ttlr-cache (* 10 60))]))

(define *password-db*
  ;; ((user . pass) ..)
  '(("ravel" . "maurice")
    ("debussy" . "claude")
    ("faure" . "gabriel")))

;; Returns session-data (#f . path) or (#t . user), if it exists.
(define (session-data req app)
  (let-params req ([cookie "c:sess"])
    (and cookie
         (atomic app (^a (cache-lookup! (~ a'sessions) cookie #f))))))

;; Returns username if the client has active session, #f otherwise.
(define (check-login req app)
  (and-let* ([data (session-data req app)]
             [ (car data) ])
    (cdr data)))

;; Delete session
(define (session-delete! req app)
  (let-params req ([cookie "c:sess"])
    (and cookie
         (atomic app (^a (cache-evict! (~ a'sessions) cookie))))))

;; Create a new session
(define (session-create! req app data)
  (let1 key (format "~8,'0x~16,'0x" (sys-time) (random-integer (expt 2 64)))
    ($ atomic app (^a (cache-write! (~ a'sessions) key data)))
    (response-cookie-add! req "sess" key :path "/")))


;; Local variables:
;; mode: scheme
;; end:
