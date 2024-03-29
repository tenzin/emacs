;; emacs init.el

;;
;;(setq inhibit-startup-message -1)  ; Disable startup message
;;(scroll-bar-mode -1)               ; Disable visible scrollbar
;;(tool-bar-mode -1)                 ; Disable the toolbar
;;(tooltip-mode -1)                  ; Disable tooltip
;;(set-fringe-mode 10)               ; Give some breathing room
(menu-bar-mode -1)                 ; Disable menu bar

(set-face-attribute 'default nil :font "Fira Code Retina" :height 130)

;;(load-theme 'tango-dark)

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
;;(use-package doom-modeline
;;  :ensure t
;;  :init (doom-modeline-mode 1)
;;  :custom ((doom-modeline-height 15)))

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
;; (setq org-clock-sound "~/emacsthings/chime.wav")

;; Following GTD implemetation from : https://emacs.cafe/emacs/orgmode/gtd/2017/06/30/orgmode-gtd.html

;; Set to the location of your Org files on your local system
(setq org-directory "~/gtd")


(setq org-capture-templates '(("t" "Todo [inbox]" entry
                               (file+headline "~/gtd/inbox.org" "Tasks")
                               "* TODO %? \nEntered on: %U\n %i" :empty-lines 1)
                              ("T" "Tickler" entry
                               (file+headline "~/gtd/tickler.org" "Tickler")
                               "* %i%? \nEntered on: %U\n %i" :empty-lines 1)))

(setq org-refile-targets '(("~/gtd/gtd.org" :maxlevel . 3)
                           ("~/gtd/someday.org" :level . 1)
                           ("~/gtd/tickler.org" :maxlevel . 2)))



;; define key to enable line wrap in orgmode
;; From https://superuser.com/questions/299886/linewrap-in-org-mode-of-emacs#:~:text=Org%20mode%20does%20not%20wrap,that%20instead%20of%20line%20wrapping.
;; (define-key org-mode-map "\M-q" 'toggle-truncate-lines) ; Does not seem to work. Need to explore further (TODO)

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
                      ("@OFFICE" . ?o) ("@HOME" . ?h) ("@WIFE" . ?w) ("@PHONE" . ?p) ("@COMPUTER" . ?c)
                      (:endgroup . nil)
                      ("WRITING" . ?w) ("READING" . ?r) ("BICYCLE" . ?b)))


;; set refile options to show when refiling [C-c C-w]
(setq org-refile-targets '(("~/gtd/gtd.org" :maxlevel . 3)
                           ("~/gtd/someday.org" :level . 1)
                           ("~/gtd/tickler.org" :maxlevel . 2)))


;; org-agenda custom commands
(setq org-agenda-custom-commands 
      '(("h" "At Home" tags-todo "@HOME"
         ((org-agenda-overriding-header "Things to do at Home")
          (org-agenda-skip-function #'my-org-agenda-skip-all-siblings-but-first)))
	("c" "At Computer" tags-todo "@COMPUTER"
	 ((org-agenda-overriding-header "Things to do on a computer")
	  (org-agenda-skip-function #'my-org-agenda-skip-all-siblings-but-first)))))

;; only show the first todo (next to do) from projects using org-agenda-custom-commands
(defun my-org-agenda-skip-all-siblings-but-first ()
  "Skip all but the first non-done entry."
  (let (should-skip-entry)
    (unless (org-current-is-todo)
      (setq should-skip-entry t))
    (save-excursion
      (while (and (not should-skip-entry) (org-goto-sibling t))
        (when (org-current-is-todo)
          (setq should-skip-entry t))))
    (when should-skip-entry
      (or (outline-next-heading)
          (goto-char (point-max))))))
		  
(defun org-current-is-todo ()
  (string= "TODO" (org-get-todo-state)))

;; Make emacs show org-agenda menu on startup - Does not look helpful - hence commented for now
;;(add-hook 'after-init-hook 'org-agenda)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files '("~/gtd/inbox.org" "~/gtd/gtd.org" "~/gtd/tickler.org"))
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
