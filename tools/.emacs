;; Raccouris clavier
(global-set-key [f2] 'save-buffer)
(global-set-key [f3] 'find-file)
(global-set-key [f4] 'kill-this-buffer)
(global-set-key [f9] 'compile)
(global-set-key [(control z)] 'undo)
(global-set-key [(control g)] 'goto-line)

;;;
;;; Paths
;;;
; ajout au PATH-Emacs
(setq load-path (cons "~/.emacs.d/" load-path))
(setq load-path (cons "~/.emacs.d/rails" load-path))
(setq load-path (cons "~/.emacs.d/mmm-mode" load-path))

;; ruby
(autoload 'ruby-mode "ruby-mode" "Load ruby-mode")
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-hook 'ruby-mode-hook 'turn-on-font-lock)

;;rails
;; See http://wiki.rubyonrails.org/rails/pages/HowToUseEmacsWithRails
;; For all snippets
;; See http://www.credmp.org/index.php/2006/11/28/ruby-on-rails-and-emacs/
;; for a tutorial
(defun try-complete-abbrev (old)
  (if (expand-abbrev) t nil))
(setq hippie-expand-try-functions-list
      '(try-complete-abbrev
        try-complete-file-name
        try-expand-dabbrev))
(require 'rails)
(require 'snippet)
(add-hook 'ruby-mode-hook
          (lambda()
            (add-hook 'local-write-file-hooks
                      '(lambda()
                         (save-excursion
                           (untabify (point-min) (point-max))
                           (delete-trailing-whitespace)
                           )))
            (set (make-local-variable 'indent-tabs-mode) 'nil)
            (set (make-local-variable 'tab-width) 2)
            (imenu-add-to-menubar "IMENU")
            (require 'ruby-electric)
            (ruby-electric-mode t)
            ))
;; nXml, for multiple mode in rhtml
(load "~/.emacs.d/nxml/autostart.el")
;; only special background in submode
(setq mumamo-chunk-coloring 'submode-colored)
(setq nxhtml-skip-welcome t)
;; do not turn on rng-validate-mode automatically, I don't like
;; the anoying red underlines
(setq rng-nxml-auto-validate-flag nil)
(defun kid-rhtml-mode ()
  (nxhtml-mode)
  ;; I don't use cua-mode, but nxhtml always complains. So, OK, let's
  ;; define this dummy variable
  (make-local-variable 'cua-inhibit-cua-keys)
  (setq mumamo-current-chunk-family '("eRuby nXhtml Family" nxhtml-mode
                                      (mumamo-chunk-eruby
                                       mumamo-chunk-inlined-style
                                       mumamo-chunk-inlined-script
                                       mumamo-chunk-style=
                                       mumamo-chunk-onjs=)))
  (mumamo-mode)
  (rails-minor-mode t)
  (auto-fill-mode -1)
  (setq tab-width 2)
  (setq indent-tab-mode nil))


;; Clavier et affichage français (avec utf-8)
(prefer-coding-system 'utf-8)
;; (standard-display-european t)

;; coupe automatiquement en 80 colonnes !
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;; Vire les espaces en fin de ligne
;; See http://www.splode.com/users/friedman/software/emacs-lisp/
(setq show-trailing-whitespace t)
(autoload 'nuke-trailing-whitespace "whitespace" nil t)
(add-hook 'mail-send-hook 'nuke-trailing-whitespace)
(add-hook 'write-file-hooks 'nuke-trailing-whitespace)
(setq nuke-trailing-whitespace-p t)

;; Taille maximale d'un buffer pour la couleur
'(font-lock-maximum-size (t . 256000))

; Browse-url (utilisation de Firefox au lieu de Netscape)
(setq browse-url-generic-program "firefox")



; Édition des feuilles de style CSS
; port www/css-mode.el
; http://www.garshol.priv.no/download/software/css-mode/index.html
(autoload 'css-mode "css-mode")

;; Stop at the end of the file, not just add lines
(setq next-line-add-newlines nil)
(setq auto-mode-alist (append '(
		       ("\\.txt$" . text-mode)
		       ("\\.lsp$" . lisp-mode)
		       ("\\.c$"   . c-mode)
		       ("\\.y$"   . c++-mode)
		       ("\\.l$"   . c++-mode)
		       ("\\.cc$"  . c++-mode)
		       ("\\.cxx$" . c++-mode)
		       ("\\.C$"   . c++-mode)
		       ("\\.cpp$" . c++-mode)
			   ("\\.css$" . css-mode)
		       ("\\.java$". java-mode)
		       ("\\.rhtml$". kid-rhtml-mode)
		       ("\\.h$"   . c++-mode)
		       ("\\.pl$"  . prolog-mode)
		       ("\\.tex$" . LaTeX-mode)
		       ("\\.TeX$" . TeX-mode)
		       ("\\.texinfo$" . texinfo-mode))
			      auto-mode-alist))
;(add-hook 'text-mode-hook
;	  '(lambda ()
;	     (setq require-final-newline 1)
;	     (auto-fill-mode 1)
;	     (ispell-minor-mode 1)
;	     ))

;; Pour un mode TeX intéressant

;; Profitons d'un ecran de plus de 80 colonnes
(cond (window-system
       (set-fill-column 90)
       ))

;; Pour avoir le numéro de ligne du curseur
(line-number-mode 1)

(autoload 'reftex-mode     "reftex" "RefTeX Minor Mode" t)
(autoload 'turn-on-reftex  "reftex" "RefTeX Minor Mode" nil)
(autoload 'reftex-citation "reftex" "Do citation with RefTeX" t)
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)   ; with AUCTeX LaTeX mode
(add-hook 'latex-mode-hook 'turn-on-reftex)   ; with Emacs latex mode



;; Pour mettre en lumière les sources
;(cond (window-system
;       (setq hilit-mode-enable-list  '(not text-mode)
;	     hilit-background-mode   'light
;	     hilit-inhibit-hooks     nil
;	     hilit-inhibit-rebinding nil)
;       (require 'hilit19)
;       ))
;
;; Enable region highlight
(transient-mark-mode 1)
;; But only in the selected window
(setq highlight-nonselected-windows nil)

;; Enable pending-delete
(delete-selection-mode 1)

;; Affiche le numéro de ligne et de colonne
(column-number-mode t)
(line-number-mode t)

;; Autorise la séléction à l'aide de la touche SHIFT
(custom-set-variables '(pc-selection-mode t nil (pc-select)))

;; Autorise la séléction à l'aide de la touche SHIFT
(custom-set-variables '(pc-selection-mode t nil (pc-select)))

;; Affiche l'heure au format 24h
(setq display-time-24hr-format t)
(setq display-time-day-and-date t)

;; Activer la coloration syntaxique
(global-font-lock-mode t)

;; Afficher la 'parenthèse correspondante'
(require 'paren)
(show-paren-mode)


;; ===== Set the highlight current line minor mode =====

;; In every buffer, the line which contains the cursor will be fully
;; highlighted

(global-hl-line-mode 1)


;; ========== Prevent Emacs from making backup files ==========
(setq make-backup-files nil)
(setq vc-make-backup-files nil)
(setq backup-directory-alist
'(("." . "~/.emacs-backup-files/")))

;; Set emacs background colour
(set-background-color "black")
(set-foreground-color "white")
;; Set cursor and mouse-pointer colours
(set-cursor-color "red")
(set-mouse-color "goldenrod")

;;##########################################################
;; Gestion du calendrier
;; les semaines commencent le lundi:
(setq calendar-week-start-day 1)
;; dates au format MM/JJ/AA :
(setq european-calendar-style t)
;; les vacances chrétiennes :
(setq all-christian-calendar-holiday t)
;; jours, mois en français :
(defvar calendar-day-abbrev-array
  ["dim" "lun" "mar" "mer" "jeu" "ven" "sam"])
(defvar calendar-day-name-array
  ["dimanche" "lundi" "mardi" "mercredi" "jeudi" "vendredi" "samedi"])
(defvar calendar-month-abbrev-array
  ["jan" "fév" "mar" "avr" "mai" "jun"
   "jul" "aoû" "sep" "oct" "nov" "déc"])
(defvar calendar-month-name-array
  ["janvier" "février" "mars" "avril" "mai" "juin"
   "juillet" "août" "septembre" "octobre" "novembre" "décembre"])

;; on efface tous les autres jours feries
(setq general-holidays nil)
(setq christian-holidays nil)(setq hebrew-holidays nil)
(setq islamic-holidays nil)
(setq oriental-holidays nil)
(setq solar-holidays nil)

;; Gestion des fetes de Paques
(defun feries-paques ()
  "Liste des jours de vacances  relatifs a paques."
  (let* ((century (1+ (/ displayed-year 100)))
	 (shifted-epact	;; Age of moon for April 5...
	  (% (+ 14 (* 11 (% displayed-year 19))	;;     ...by Nicaean rule
		(- ;; ...corrected for the Gregorian century rule
		 (/ (* 3 century) 4))
		(/ ;; ...corrected for Metonic cycle inaccuracy.
		 (+ 5 (* 8 century)) 25)
		(* 30 century))	;;              Keeps value positive.
		 30))
	 (adjusted-epact ;;  Adjust for 29.5 day month.
	  (if (or (= shifted-epact 0)
		  (and (= shifted-epact 1) (< 10 (% displayed-year 19))))
		  (1+ shifted-epact)
		shifted-epact))
	 (paschal-moon ;; Day after the full moon on or after March 21.
	  (- (calendar-absolute-from-gregorian (list 4 19 displayed-year))
		 adjusted-epact))
	 (abs-easter (calendar-dayname-on-or-before 0 (+ paschal-moon 7)))
	 (day-list
	  (list
	   (list (calendar-gregorian-from-absolute abs-easter)
		 "Pâques")
	   (list (calendar-gregorian-from-absolute (+ abs-easter 1))
		 "Lundi de Pâques")
	   (list (calendar-gregorian-from-absolute (+ abs-easter 39))
		 "Jeudi de l'ascension")
	   (list (calendar-gregorian-from-absolute (+ abs-easter 49))
		 "Pentecôte")
	   (list (calendar-gregorian-from-absolute (+ abs-easter 50))
		 "Lundi de Pentecôte")))
	 (output-list
	  (filter-visible-calendar-holidays day-list)))
	output-list))

;; Les vacances francaises
(setq local-holidays
	  '((holiday-fixed 1 1 "Nouvel an")
		(holiday-fixed 5 1 "Fête du travail")
		(holiday-fixed 5 8 "Victoire 1945")
		(feries-paques)
		(holiday-fixed 7 14 "Fête nationale")
		(holiday-fixed 8 15 "Assomption")
		(holiday-fixed 11 11 "Armistice 1918")
		(holiday-fixed 11 1 "Toussaint")
		(holiday-fixed 12 25 "Noël")))

;; afficher les fetes
(setq mark-holidays-in-calendar t)

;; afficher le jour d'aujourd'hui
(setq today-visible-calendar-hook 'calendar-mark-today)
(setq calendar-today-marker 'highlight)


;; ========== Support Wheel Mouse Scrolling ==========
(mouse-wheel-mode t)

;; Cscope powar !!!
(require 'cscope)

;; Tabulation prend 4 espaces, un peu plus lisible
(setq default-tab-width 4)


;;OpenOffice. See http://go-oo.org/emacs.el
(defvar my-openoffice-path-regexp
  "OOo"
  "Regexp that matches paths into your OpenOffice.org source tree.")

(defun my-openoffice-c-hook ()
  (when (string-match my-openoffice-path-regexp buffer-file-name)
      (message "Using OpenOffice.org code settings")
      (setq tab-width 4)
      (setq tab-stop-list '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72
			    76 80 84 88 92 96 100 104 108 112 116 120))
      (c-set-style "stroustrup")
      (set-variable 'c-basic-offset 4)
      (set-variable 'indent-tabs-mode t)))

(add-hook 'c-mode-common-hook 'my-openoffice-c-hook)

(add-to-list 'auto-mode-alist (cons "\\.sdi\\'" 'c++-mode))
(add-to-list 'auto-mode-alist (cons "\\.hrc\\'" 'c++-mode))
(add-to-list 'auto-mode-alist (cons "\\.src\\'" 'c++-mode))
