#!/usr/bin/env gosh

;; 
;; Rontgen
;; -------
;; RG/AQUA::AQUARIUM Rinko Presentation Software
;; Copyright (C) 2022 Collodi Choi
;; All rights reserved.
;; 2022-Nov-18 Created by Collodi Choi
;; Powered by Scheme R74S Gauche and Gauche-Makiki
;;

(add-load-path ".." :relative)
(use gauche.threads)
(use gauche.parseopt)
(use text.html-lite)
(use srfi-1)
(use makiki)

(define index 0) ;; Imagemagick counts from 0
(define slide-length 23) ;; TODO: build a macro to automate this

(define indexprev
    (lambda ()
        (set! index (if (= index 0) slide-length (- index 1)) )))

(define indexnext
    (lambda ()
        (set! index (modulo (+ index 1) slide-length))))

(define footer
  (html:footer :class "w3-container w3-white" :width "100%" 
    (html:p (html:i "Copyright© 2022 Collodi Choi. All rights reserved. Powered by " 
      (html:a :href "http://www.w3schools.com/w3css/default.asp" "w3.css") " & Scheme R7RS"))))

;; main program just starts the server.
;; logs goes to stdout (:access-log #t :error-log #t)
;; we pass the timestamp to :app-data - it is avaliable to the 'app'
;;  argument in the http handlers below.
(define (main args)
  (let-args (cdr args) ([port "p|port=i" 8012])
    (start-http-server :access-log #t :error-log #t :port port
                       :app-data (sys-ctime (sys-time))))
  0)

;; The root path handler.  We show some html, constructed by text.html-lite.
(define-http-handler "/"
  (^[req app]
    (respond/ok req
      (html:html
       (html:link :rel "stylesheet" :href "https://www.w3schools.com/w3css/4/w3.css")
       (html:link :rel "stylesheet" :href "https://fonts.googleapis.com/css?family=Allerta+Stencil")
       (html:link :rel "stylesheet" :href "/src/main.css")
       (html:head (html:title "AQUARIUM::SYSTEM"))
       (html:body :class "w3-container w3-light-grey"
         (html:div :class "outer"
                  (html:h1 :class "w3-allerta" "RG/AQUARIUM::WEBSYSTEM")
                  (html:p "La servilo funkcias ekde " app
                          "ĉe PORT " (request-server-port req)
                          " sur host " (request-server-host req)
                          " kun Scheme R7RS"
                          ".")
                  (html:p
                   ;; (html:a :class "topmenu" :href "/src/" "Browse makiki source")
                   ;; (html:a :class "topmenu" :href "/echo-headers" "View request headers")
                   (html:a :class "topmenu" :href "/present/studentin" "Prelego Diapozitivoj / Lecture Slides")
                   (html:a :class "topmenu" :href "/present/lehrer" "Prelego Kontrolo / Lecture Control")
                   (html:a :class "topmenu" :href "/present/lehrer/upload" "Alŝutu diapozitivojn / Upload Slides") 
                   (html:a :class "topmenu" :href "/src/wiki" "Akvario Vikio / Aquarium Wiki"))
                  (html:p
                   (html:img :class "slide" :width "100%" :src "/src/slides/s1.jpg")))
         footer)))))

(define-http-handler "/present/studentin"
  (^[req app]
    (respond/ok req
      (html:html
       (html:script :src "/src/studentin.js")
       (html:link :rel "stylesheet" :href "https://www.w3schools.com/w3css/4/w3.css")
       (html:link :rel "stylesheet" :href "/src/present.css")
       (html:head (html:title "AQUARIUM::SYSTEM"))
       (html:body :class "w3-container w3-light-grey"
         (html:div :class "outer"
                  (html:div :id "main"
                      (html:div :class "w3-bar w3-white"
                          (html:a :class "w3-bar-item w3-button" :href "/" "Top")
                          (html:div :class "w3-bar-item" (html:b "Lecture Slides"))
                          (html:button :type "button" :onClick "largerSlide()" 
                                       :class "w3-button w3-white w3-bar-item w3-right" "&nbsp+&nbsp")
                          (html:button :type "button" :onClick "smallerSlide()" 
                                       :class "w3-button w3-black w3-bar-item w3-right" "&nbsp-&nbsp")))
                  (html:p
                   (html:img :id "slideimg" :class "slide" 
                             ;; :src "/present/slides/current"
                             )))
         footer)))))

(define-http-handler "/present/lehrer"
  (^[req app]
    (respond/ok req
      (html:html
       (html:head (html:title "AQUARIUM::SYSTEM"))
       (html:link :rel "stylesheet" :href "https://www.w3schools.com/w3css/4/w3.css")
       (html:link :rel "stylesheet" :href "/src/present.css")
       (html:body :class "w3-container w3-light-grey"
         (html:div :class "outer"
                  (html:div :class "w3-bar w3-white"
                   (html:a :class "w3-bar-item w3-button" :href "/" "Top")
                   (html:div :class "w3-bar-item" (html:b "Lecture Control"))
                   (html:a :class "w3-bar-item w3-button w3-right" :href "/present/lehrer/next" "Next")
                   (html:a :class "w3-bar-item w3-button w3-right" :href "/present/lehrer/prev" "Prev"))
                  (html:img :class "center" :id "slideimg"
                             :src (format #f "/src/slides/slide-~d.png" index))
                  footer))))))


(define-http-handler "/present/slides/current"
  (^[req app] (respond/redirect req (format #f "/src/slides/slide-~d.png" index)) ))

(define-http-handler "/present/lehrer/prev"
  (^[req app] (respond/redirect req "/present/lehrer") (indexprev) ))

(define-http-handler "/present/lehrer/next"
  (^[req app] (respond/redirect req "/present/lehrer") (indexnext) ))

;; The path '/src/' shows the current directory and below.
;; We pass the proc to extract path below '/src' to the :path-trans
;; arg of file-handler, which will interpret the translated path relative
;; to the document-root, which defaults to ".".
(define-http-handler #/^\/src(\/.*)$/
  (file-handler :path-trans (^[req] ((request-path-rxmatch req) 1))))

;; Redirect "/src" to "/src/".
(define-http-handler "/src"
  (^[req app] (respond/redirect req "/src/")))

;; '/echo-header' reports back http request headers, handy for diagnostics.
(define-http-handler "/echo-headers"
  (^[req app]
    (respond/ok req
                (html:html
                 (html:head (html:title "echo-header"))
                 (html:body (html:h1 "Request headers")
                            (html:pre
                             (map (^p (map (^v #"~(car p): ~v\n") (cdr p)))
                                  (request-headers req))))))))

;; Local variables:
;; mode: scheme
;; end:
