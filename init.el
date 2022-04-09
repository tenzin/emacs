;; emacs init.el

(setq inhibit-startup-message -1)  ; Disable startup message
(scroll-bar-mode -1)               ; Disable visible scrollbar
(tool-bar-mode -1)                 ; Disable the toolbar
(tooltip-mode -1)                  ; Disable tooltip
(set-fringe-mode 10)               ; Give some breathing room
(menu-bar-mode -1)                 ; Disable menu bar

(set-face-attribute 'default nil :font "Fira Code Retina" :height 130)

(load-theme 'tango-dark)

;; put all backup files into ~/MyEmacsBackups
(setq backup-directory-alist '(("." . "~/.emacs.d/MyEmacsBackups")))

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("elpa" . "https://elpa.gnu.org/packages")
			 ("org" . "https://orgmode.org/elpa/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-packages)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Enable fido-mode for completion.
(fido-mode 1)

;; Enable icomplete-vertical (Global Emacs minor mode to display icomplete candidates vertically)
;; See https://github.com/oantolin/icomplete-vertical#installation-and-usage
(use-package icomplete-vertical
  :config  
  :hook (icomplete-minibuffer-setup . icomplete-vertical-mode))

(use-package all-the-icons
  :if (display-graphic-p))

;; use doom-modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

;; Temporary fix for doom-modeline hiding orgmode tags
(advice-add #'fit-window-to-buffer :before (lambda (&rest _) (redisplay t)))

;; Line nmber and col number
(column-number-mode)
(global-display-line-numbers-mode t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
		org-agenda-mode-hook
		term-mode-hook
		shell-mode-hook	       
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Package to colourize parenthesis
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; which key
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))


;; ************** orgmode related **************

(use-package org)

;; Set chime sound for to be used with org-timer-set-timer
(setq org-clock-sound "~/emacsthings/chime.wav")

;; define key to enable line wrap in orgmode
;; From https://superuser.com/questions/299886/linewrap-in-org-mode-of-emacs#:~:text=Org%20mode%20does%20not%20wrap,that%20instead%20of%20line%20wrapping.
(define-key org-mode-map "\M-q" 'toggle-truncate-lines) ; Does not seem to work. Need to explore further (TODO)

;; Set orgmode todo states
(setq org-todo-keywords
      '((sequence "TODO(t)" "IN-PROGRESS(p)" "WAITING(w)" "|" "DONE(d)" "DEFERRED(f)" "CANCELLED(c)")))

;; Set orgmode faces for TODO keywords
(setq org-todo-keyword-faces
      '(("TODO" . (:foreground "pink" :weight bold))
	("IN-PROGRESS" . "#E35DBF")
	("CANCELLED" . (:foreground "white" :background "#4d4d4d" :weight bold))
	("WAITING" . (:foreground "#ff39a3" :weight bold))
	("DEFERRED" . "#008080")))

;; set timestamp when you move TODOs to DONE
(setq org-log-done t)

;; override default setting of right-aligning orgmode tags
(setq org-agenda-tags-column 25)

;; Activate key bindings for org-agenda, org-capture etc.
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

;; orgmode tags
(setq org-tag-alist '((:startgroup . nil)
                      ("OFFICE" . ?o) ("HOME" . ?h)
                      (:endgroup . nil)
                      ("COMPUTER" . ?c) ("PHONE" . ?p) ("READING" . ?r) ("BICYCLE" . ?b)))

;; org-capture configs and template
;; (setq org-default-notes-file (concat org-directory "~/orgmode/notes.org"))
(setq org-capture-templates
      '(("t" "TASKS" entry (file+headline "~/orgmode/gtd.org" "Tasks")
	 "* TODO %?\n  Entered on: %U\n %i\n  %a" :empty-lines 1)
	("f" "Financial" entry (file+headline "~/orgmode/gtd.org" "Financial")
	 "* TODO %?\n  Entered on: %U\n %i" :empty-lines 1)
	("r" "Readings" entry (file+headline "~/orgmode/gtd.org" "Readings")
	 "* TODO %?\n  Entered on: %U\n %i" :empty-lines 1)
	("p" "PROJECTS" entry (file+headline "~/orgmode/gtd.org" "Projects")
	 "* TODO %?\n  Entered on: %U\n %i" :empty-lines 1)
	("7" "RBFE 7" entry (file+headline "~/orgmode/gtd.org" "RBFE 7")
	 "* TODO %?\n  Entered on: %U\n %i\n %a" :empty-lines 1)
        ("j" "Journal" entry (file+datetree "~/orgmode/journal.org")
         "* %?\nEntered on: %U\n  %i" :empty-lines 1)
	("n" "Note" entry (file "~/orgmode/notes.org")
         "* %?\nEntered on: %U\n  %i" :empty-lines 1)))

;; Set to the location of your Org files on your local system
(setq org-directory "~/orgmode")
;; Set to the name of the file where new notes will be stored
(setq org-mobile-inbox-for-pull "~/orgmode/from-mobile.org")
;; Set to <your Dropbox root directory>/MobileOrg.
(setq org-mobile-directory "~/Dropbox/Apps/MobileOrg")

;; set refile options to show when refiling [C-c C-w]
(setq org-refile-targets '((org-agenda-files :maxlevel . 9)))

;; Make emacs show org-agenda menu on startup - Does not look helpful - hence commented for now
;;(add-hook 'after-init-hook 'org-agenda)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files '("~/orgmode/gtd.org" "~/orgmode/from-mobile.org"))
 '(org-agenda-todo-list-sublevels nil)
 '(org-enforce-todo-dependencies t)
 '(package-selected-packages
   '(which-key rainbow-delimiters doom-modeline all-the-icons use-package nov icomplete-vertical)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
