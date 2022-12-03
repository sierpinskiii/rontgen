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
(use gauche.process)
(use text.html-lite)
(use srfi-1)
(use file.util)
(use makiki)

(use util.match)
(use data.cache)
(use srfi-27)

(load "./session2.scm")

(define *upload-img-prefix* "/tmp/upload-sample-")  ;; default in Gauche-Makiki

(make-directory* "./tmp")

(define index 0) ;; Imagemagick counts from 0
(define mode 0) ;; image=0, quizz=1
(define slide-length 23) ;; TODO: build a macro to automate this
(define update-flag 0)

(define index-prev
    (lambda ()
        (set! index (if (= index 0) slide-length (- index 1)) )))

(define index-next
    (lambda ()
        (set! index (modulo (+ index 1) slide-length))))

(define footer
  (html:footer :class "w3-container w3-white" :width "100%" 
    (html:p (html:i "Copyright© 2022 " (html:a :href "https://github.com/sierpinskiii/rontgen" "Collodi Choi") ". All rights reserved. Powered by " 
      (html:a :href "http://www.w3schools.com/w3css/default.asp" "w3.css") " & Scheme R7RS"))))

(define img-slide
  (html:img :id "slideimg" :class "slide" 
    ;; :src "/present/slides/current"
    ))

(define quizz-slide
  (html:div :id "slidequizz" :class "slide" 
    ;; :src "/present/slides/current"
    ))


(define quizz-mode
  (set! mode 1))

(define image-mode
  (set! mode 0))

;; main program just starts the server.
;; logs goes to stdout (:access-log #t :error-log #t)
;; we pass the timestamp to :app-data - it is avaliable to the 'app'

;;  argument in the http handlers below.
;(define (main args)
;  (let-args (cdr args) ([port "p|port=i" 8012])
;    (start-http-server :access-log #t :error-log #t :port port
;                       :app-data (sys-ctime (sys-time))))
;  0)

(define (main args)
  (let-args (cdr args) ([port "p|port=i" 8012])
    (random-source-randomize! default-random-source)
    (start-http-server :access-log #t :error-log #t :port port
                       :app-data (atom (make <app>))))
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
                  (html:p "La servilo funkcias ekde "
                          "ĉe PORT " (request-server-port req)
                          " sur host " (request-server-host req)
                          " kun Scheme R7RS"
                          ".")
                  (html:p
                   (html:a :class "topmenu" :id "present-studentin"
                           :href "/present/studentin" "")
                   (html:a :class "topmenu" :id "present-lehrer"
                           :href "/present/lehrer" "")
                   (html:a :class "topmenu" :id "present-lehrer-upload"
                           :href "/present/lehrer/upload" "") 
                   (html:a :class "topmenu" :id "login"
                           :href "/login" "")
                   (html:a :class "topmenu" :id "logout"
                           :href "/logout" "")
                   (html:a :class "topmenu" :id "src-wiki"
                           :href "https://collodi.dev/aquawiki" ""))
                  (html:p
                   (html:img :class "slide" :width "100%" :src "/src/slides/s1.jpg")))
         footer)))))


(define-http-handler "/present/studentin"
  (^[req app]
    (respond/ok req
      (html:html
       (html:script :src "/src/screen.js")
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
                  (html:p :id "screen"))
         footer)))))


(define-http-handler "/present/screen"
  (^[req app]
    (respond/ok req
        (if (= mode 0)
          (html:img :id "slideimg" :class "slide" 
            :src (format #f "/src/slides/slide-~d.png" index))
          
          (html:div 
            (html:input :class "w3-radio" :type "radio"
                        :name "answer1" :value "I don't know"))))))


(define-http-handler "/present/flag"
  (^[req app]
    (respond/ok "0")))


(define-http-handler "/present/lehrer"
  ? check-login
  (^[req app]
    (respond/ok req
      (html:html
       (html:head (html:title "AQUARIUM::SYSTEM"))
       (html:script :src "/src/screen.js")
       (html:link :rel "stylesheet" :href "https://www.w3schools.com/w3css/4/w3.css")
       (html:link :rel "stylesheet" :href "/src/present.css")
       (html:body :class "w3-container w3-light-grey"
         (html:div :class "outer"
                  (html:div :class "w3-bar w3-white"
                   (html:a :class "w3-bar-item w3-button" :href "/" "Top")
                   (html:div :class "w3-bar-item" (html:b "Lecture Control"))

                   (html:div :class "w3-dropdown-hover"
                     (html:button :class "w3-button" "Project")
                     (html:div :class "w3-dropdown-content w3-bar-block w3-card-4"
                       (html:a :href "/present/lehrer/mode/image" :class "w3-bar-item w3-button" "Introduction_to_LN.pdf.d")
                       (html:a :href "/present/lehrer/mode/quizz" :class "w3-bar-item w3-button" "Dirac_Nocation.pdf.d")
                       ))

                   (html:div :class "w3-dropdown-hover"
                     (html:button :class "w3-button" "Mode")
                     (html:div :class "w3-dropdown-content w3-bar-block w3-card-4"
                       (html:a :href "/present/lehrer/mode/image" :class "w3-bar-item w3-button" "(image-mode t)")
                       (html:a :href "/present/lehrer/mode/quizz" :class "w3-bar-item w3-button" "(quizz-mode t)")
                       ))


                   (html:a :class "w3-bar-item w3-button w3-right" :href "/present/lehrer/next" "Next")
                   (html:a :class "w3-bar-item w3-button w3-right" :href "/present/lehrer/prev" "Prev")

                   (html:button :type "button" :onClick "largerSlide()" 
                                :class "w3-button w3-white w3-bar-item w3-right" "&nbsp+&nbsp")
                   (html:button :type "button" :onClick "smallerSlide()" 
                                :class "w3-button w3-black w3-bar-item w3-right" "&nbsp-&nbsp"))

                  (html:div :id "screen")

                  footer))))))


;; (define-http-handler "/present/slides/current"
;;  (^[req app] (respond/redirect req (format #f "/src/slides/slide-~d.png" index)) ))

(define-http-handler "/present/lehrer/prev"
  ? check-login
  (^[req app] (respond/redirect req "/present/lehrer") (index-prev) ))

(define-http-handler "/present/lehrer/next"
  ? check-login
  (^[req app] (respond/redirect req "/present/lehrer") (index-next) ))


(define-http-handler "/present/lehrer/mode/image"
  ? check-login
  (^[req app] (respond/redirect req "/present/lehrer") (set! mode 0) ))

(define-http-handler "/present/lehrer/mode/quizz"
  ? check-login
  (^[req app] (respond/redirect req "/present/lehrer") (set! mode 1) ))


(define-http-handler "/present/lehrer/upload"
  ? check-login
  (^[req app]
    ($ respond/ok req
       '(sxml
         (html
          (head (title "Upload test"))
          (body
           (form (@ (action "/present/lehrer/upload/slides") (method "POST")
                    (enctype "multipart/form-data"))
                 (p "Choose file(s) to upload:"
                    (input (@ (type "file") (name "files")
                              (multiple "multiple"))))
                 (input (@ (type "submit") (name "submit")
                           (value "post"))))))))))


(define-http-handler "/" (file-handler))
                                    ;; :directory-index '("/tmp" #t)
                                    ;; :path-trans
                                    ;; :prefix "/tmp/upload-sample-"
                                    ;; :root (document-root)))

(define-http-handler "/present/lehrer/upload/slides"
  (with-post-parameters
   (^[req app]
     (let-params req ([tnames "q:files" :list #t])
       ($ respond/ok req
          `(sxml
            (html
             (head (title "Upload test"))
             (body
              (p "Uploaded files:")
               ,@(map
                  (^[filename]
                    (x->string (copy-file (car filename) 
                                          (string-append "./proj/" (cadr filename)))))
                  tnames)))))))
   :part-handlers `(("files" file+name :prefix ,*upload-img-prefix*))))



;; Browsers may try to fetch this.  We catch this specially so that
;; the later 'catch all' clause won't be confused.
(define-http-handler "/favicon.ico" (^[req app] (respond/ng req 404)))

;; Logout
(define-http-handler "/logout"
  (^[req app]
    (session-delete! req app)
    ($ respond/ok req
       (html:html
        (html:head (html:title "Logged out"))
        (html:body (html:p "You've successfully logged out.")
                   (html:p (html:a :href "/" "login")))))))

;; Login check
(define-http-handler "/login"
  ? session-data
  (with-post-parameters
   (^[req app]
     (match (request-guard-value req)
       [(and (#f . path) data)
        (let-params req ([u "q:user"]
                         [p "q:pass"])
          (if (equal? (assoc-ref *password-db* u) p)
            (begin
              (set! (car data) #t)
              (set! (cdr data) u)
              (respond/redirect req path))
            (respond/ok req (login-form "Invalid login"))))]
       [(#t . user)
        ($ respond/ok req
           (html:html
            (html:head (html:title "Welcome"))
            (html:body (html:p "You've already logged in.")
                       (html:p (html:a :href "/" "Top"))
                       (html:p (html:a :href "/logout" "Log out")))))]))))

(define (login-form msg)
  (html:html
   (html:head (html:title "Login"))
   (html:link :rel "stylesheet" :href "https://www.w3schools.com/w3css/4/w3.css")
   (html:link :rel "stylesheet" :href "https://unpkg.com/@sakun/system.css")
   (html:body (if msg (html:p msg) "")
       (html:div :class "w3-display-container" :style "width:100%;height:100%"
           (html:div :class "w3-display-middle"
              (html:form
               :action "/login" :method "POST"
               (html:label :for "text_email" "Username")(html:br)
               (html:input :id "text_email" :type "text" :name "user")(html:br)
               (html:label :for "pwd" "Password")(html:br)
               (html:input :id "text_pwd" :type "password" :name "pass")(html:br)(html:br)
               (html:input :type "submit" :name "submit" :value "Login")))))))

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
                 (html:link :rel "stylesheet" :href "https://www.w3schools.com/w3css/4/w3.css")
                 (html:head (html:title "echo-header"))
                 (html:body (html:h1 "Request headers")
                            (html:pre
                             (map (^p (map (^v #"~(car p): ~v\n") (cdr p)))
                                  (request-headers req))))))))

;; We use 'catch all' pattern, so that any req that hasn't match
;; previous patterns comes here.
(define-http-handler #/^.*$/
  (^[req app]
    (session-create! req app `(#f . ,(request-path req)))
    (respond/ok req (login-form #f))))
;; Local variables:
;; mode: scheme
;; end:
