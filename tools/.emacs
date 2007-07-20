;; Raccouris clavier
(global-set-key [f2] 'save-buffer)
(global-set-key [f3] 'find-file)
(global-set-key [f5] 'comment-region)
(global-set-key [f6] 'uncomment-region)
(global-set-key [f9] 'compile)
(global-set-key [(control g)] 'goto-line)

;; ruby
(autoload 'ruby-mode "ruby-mode" "Load ruby-mode")
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rhtml$" . ruby-mode))
(add-hook 'ruby-mode-hook 'turn-on-font-lock)

;; Clavier et affichage français (utilise l'ISO 8859)
(prefer-coding-system 'utf-8)


;; coupe automatiquement en 80 colonnes !
(add-hook 'text-mode-hook 'turn-on-auto-fill)

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
		       ("\\.java$". java-mode)
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
;(transient-mark-mode 1)
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


;; dico en français
(setq ispell-dictionary "francais")




;; ========== Prevent Emacs from making backup files ==========
(setq make-backup-files nil) 


;; Set emacs background colour
(set-background-color "black")
(set-foreground-color "white")
;; Set cursor and mouse-pointer colours
(set-cursor-color "red")
(set-mouse-color "goldenrod")

;;##########################################################
;; Gestion du calendrier

;; on efface toutes les autres jours feries
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





