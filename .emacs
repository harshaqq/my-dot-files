(let ((gc-cons-threshold most-positive-fixnum))
  (require 'use-package)

  (setq inhibit-splash-screen t)
  (setq inhibit-startup-message t)
  (setq create-lockfiles nil)

  (set-language-environment "UTF-8")
  (set-default-coding-systems 'utf-8)
  (prefer-coding-system 'utf-8)

  (fringe-mode '(nil . 0))
  (linum-mode 0)
  (blink-cursor-mode 0)

  (setq backup-directory-alist `((".*" . ,temporary-file-directory)))
  (setq auto-save-file-name-transforms `((".*" ,temporary-file-directory)))

  ;; (setq resize-mini-windows nil)
  ;; (setq max-mini-window-height 1)

  (setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
  (setq mouse-wheel-progressive-speed nil)
  (setq mouse-wheel-follow-mouse 't)
  (setq scroll-step 1)

  (setq abbrev-file-name (expand-file-name "abbrev_defs" user-emacs-directory))
  (setq-default abbrev-mode t)
  (setq save-abbrevs 'silent)

  (when (display-graphic-p)
    (scroll-bar-mode 0)
    (menu-bar-mode -1)
    (tool-bar-mode -1))

  (use-package files
    :config
    (add-hook 'minibuffer-setup-hook (lambda ()
				       (setq gc-cons-threshold most-positive-fixnum)))
    (add-hook 'minibuffer-exit-hook (lambda ()
				      (setq gc-cons-threshold 800000))))

  (use-package paren
    :custom
    (show-paren-style 'parenthesis)
    :config
    (show-paren-mode 1))

  (use-package time
    :custom
    (display-time-24hr-format t)
    (display-time-use-mail-icon t)
    (display-time-day-and-date nil)
    (display-time-world-list '(("Asia/Calcutta" "Bengaluru")
			       ("America/New_York" "New York")
			       ("America/Los_Angeles" "Seatle")))
    :config
    (display-time-mode))

  (use-package battery
    :config
    (display-battery-mode))

  (setq user-mail-address (shell-command-to-string "git config --global user.email"))
  (setq user-full-name (shell-command-to-string "git config --global user.name"))

  (defun exwm/setup-keys ()
    (exwm-input-set-key (kbd "s-r") 'exwm/start-program)
    (exwm-input-set-key (kbd "s-R") 'exwm-reset)
    (exwm-input-set-key (kbd "s-w") 'exwm-workspace-switch)
    (exwm-input-set-key (kbd "s-h") 'windmove-left)
    (exwm-input-set-key (kbd "s-l") 'windmove-right)
    (exwm-input-set-key (kbd "s-j") 'windmove-up)
    (exwm-input-set-key (kbd "s-k") 'windmove-down)
    (exwm-input-set-key (kbd "s-b") 'ibuffer-list-buffers)
    (exwm-input-set-key (kbd "s-f") 'find-file)
    (exwm-input-set-key (kbd "s-D") 'kill-this-buffer)
    (exwm-input-set-key (kbd "s-O") 'exwm-layout-toggle-fullscreen)
    (exwm-input-set-key (kbd "s-a") 'async-shell-command)
    (exwm-input-set-key (kbd "s-z") 'exwm/lock-screen)
    (exwm-input-set-key (kbd "s-E") 'eww)
    (exwm-input-set-key (kbd "s-c") 'calendar)
    (exwm-input-set-key (kbd "s-t") 'display-time-world))

  (defun exwm/setup-output-devices ()
    ;; This sets displaylink monitor to output, since hotplug is not supported
    (let ((xrandr-output-regexp "Provider \\([0-9]\\)"))
      (with-temp-buffer
	(call-process "xrandr" nil t nil "--listproviders")
	(goto-char (point-min))
	(while (re-search-forward xrandr-output-regexp nil 'noerror)
	  (if (> (string-to-number (match-string 1)) 0)
	      (call-process
	       "xrandr" nil nil nil
	       "--setprovideroutputsource" (match-string 1) "0")))))
    ;; This sets connected monitor to workspace plist
    (let ((xrandr-output-regexp "\n\\([^ ]+\\) connected ")
	  output-index
	  output-plist)
      (with-temp-buffer
	(setq output-index 0)
	(setq output-plist ())
	(call-process "xrandr" nil t nil)
	(goto-char (point-min))
	(while (re-search-forward xrandr-output-regexp nil 'noerror)
	  (setq output-plist (plist-put output-plist output-index (match-string 1)))
	  (setq output-index (+ output-index 1)))
	(setq exwm-randr-workspace-monitor-plist output-plist))))

  (defun exwm/start-dropbox-service ()
    "Start dropbox service if it's not running"
    (require 'subr-x)
    (if (string-empty-p (shell-command-to-string "dropbox running"))
	(start-process-shell-command "dropbox" nil "dropbox start")))

  (defun exwm/monitor-only-builtin ()
    "Switch to laptop display"
    (interactive)
    (start-process-shell-command
     "xrandr"
     nil
     "xrandr --output eDP-1 --auto --output HDMI-1 --off --output DVI-I-1-1 --off"))

  (defun exwm/monitor-only-main ()
    "Switch to main monitor"
    (interactive)
    (start-process-shell-command
     "xrandr"
     nil
     "xrandr --output eDP-1 --off --output DVI-I-1-1 --off --output HDMI-1 --auto"))

  (defun exwm/monitor-builtin-and-main ()
    "Both laptop and main monitor"
    (interactive)
    (start-process-shell-command
     "xrandr"
     nil
     "xrandr --output DVI-I-1-1 --off --output eDP-1 --left-of HDMI-1 --auto"))

  (defun exwm/monitor-only-secondary ()
    "Use only secondary monitor"
    (interactive)
    (start-process-shell-command
     "xrandr"
     nil
     "xrandr --output eDP-1 --off --output HDMI-1 --off --output DVI-I-1-1 --auto"))

  (defun exwm/monitor-main-and-secondary ()
    "Use main and secondary monitor"
    (interactive)
    (start-process-shell-command
     "xrandr"
     nil
     "xrandr --output eDP-1 --off --output HDMI-1 --left-of DVI-I-1-1 --auto"))

  (defun exwm/monitor-all ()
    "Use all monitors"
    (interactive)
    (start-process-shell-command
     "xrandr"
     nil
     (concat
      "xrandr --output DVI-I-1-1 --mode 1920x1080 --pos 1920x0 --rotate normal "
      "--output eDP-1 --mode 1366x768 --pos 0x1080 --rotate normal "
      "--output HDMI-1 --mode 1920x1080 --pos 0x0 --rotate normal")))

  (defun exwm/update-title ()
    (when (or (not exwm-instance-name)
	      (string-prefix-p "sun-awt-X11-" exwm-instance-name)
	      (string= "gimp" exwm-instance-name))
      (exwm-workspace-rename-buffer exwm-title)))

  (defun exwm/update-class ()
    (unless (or (string-prefix-p "sun-awt-X11-" exwm-instance-name)
		(string= "gimp" exwm-instance-name))
      (exwm-workspace-rename-buffer exwm-class-name)))


  (defun exwm/start-program (command)
    (interactive
     (list (read-shell-command "$ ")))
    (start-process-shell-command command nil command))

  (defun exwm/lock-screen ()
    (interactive)
    (start-process-shell-command "loginctl" nil "loginctl lock-session $XDG_SESSION_ID"))

  (defun exwm/screen-shot ()
    (interactive)
    (start-process-shell-command "scrot" nil "scrot /tmp/screen-%F-%T.png"))

  (defun exwm/update-font-size-on-workspace-switch ()
    (if (= 0 exwm-workspace-current-index)
	(set-frame-font "Hack-15"))
    (if (= 1 exwm-workspace-current-index)
	(set-frame-font "Hack-13"))
    (if (= 2 exwm-workspace-current-index)
	(set-frame-font "Hack-14")))

  (use-package gnutls
    :demand t
    :custom
    (gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))

  (use-package package
    :demand t
    :custom
    (package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
			("melpa" . "https://melpa.org/packages/")))
    :config
    (package-initialize))
 
  (use-package windmove
    :demand t
    :config
    (windmove-default-keybindings 'meta))

  (use-package winner
    :demand t
    :init
    (winner-mode))

  (use-package calendar
    :demand t
    :custom
    (calendar-latitude 12.9)
    (calendar-longitude 77.5)
    (calendar-location-name "Bengaluru, IN"))

  (use-package savehist
    :demand t
    :custom
    (savehist-file (expand-file-name "savehist" user-emacs-directory))
    (savehist-additional-variables '(search ring regexp-search-ring))
    (savehist-autosave-interval 60)
    (history-length 1000)
    :config
    (savehist-mode))

  (use-package saveplace
    :demand t
    :custom
    (save-place-file (expand-file-name "places" user-emacs-directory))
    :config
    (setq-default save-place t))

  (use-package simple
    :demand t
    :bind
    (("M-x" . (lambda ()
		(interactive)
		(call-interactively
		 (intern
		  (ido-completing-read
		   "M-x "
		   (all-completions "" obarray 'commandp))))))))

  (defun ido-bookmark-jump (bname)
    "*Switch to bookmark interactively using `ido'."
    (interactive (list (ido-completing-read "Bookmark: " (bookmark-all-names) nil t)))
    (bookmark-jump bname))

  (use-package ido
    :demand t
    :bind (("C-x r b" . ido-bookmark-jump)
	   ("C-x b" . ido-switch-buffer))
    :custom
    (ido-enable-prefix nil)
    (ido-use-virtual-buffers t)
    (ido-enable-flex-matching t)
    (ido-create-new-buffer 'always)
    :config
    (ido-mode 1))

  (use-package ibuffer
    :bind (("C-x C-b" . ibuffer-list-buffers))
    :demand t
    :config
    (add-hook 'ibuffer-mode-hook #'ibuffer-auto-mode))

  (use-package recentf
    :demand t
    :custom
    (recentf-save-file (expand-file-name "recentf" user-emacs-directory))
    (recentf-auto-cleanup 300)
    :config
    (add-to-list 'recentf-exclude "COMMIT_EDITMSG\\'")
    (add-to-list 'recentf-exclude ".*elpa.*autoloads\.el$")
    :init
    (recentf-mode t))

  (use-package hippie-exp
    :demand t
    :bind
    (("M-SPC" . hippie-expand)))

  (use-package exwm
    :demand t
    :ensure t
    :init
    (exwm-enable)
    :bind
    (("<XF86Calculator>" . calc)
     ("<XF86Launch5>" . delete-other-windows)
     ("<XF86Launch6>" . split-window-vertically)
     ("<XF86Launch7>" . split-window-horizontally)
     ("<Scroll_Lock>" . scroll-lock-mode)
     ("<XF86Search>"  . occur)
     ("<XF86Mail>"    . gnus)
     ("<XF86Home>"    . ibuffer-list-buffers)
     ("<XF86Favorites>" . bookmark-set)
     ("<XF86Launch8>" . exwm-workspace-move-window)
     ("<XF86Launch9>" . exwm-workspace-switch))
    :custom
    (exwm-input-global-keys
     `(
       ([s-R]   . exwm-reset)
       ([s-w]   . exwm-workspace-switch)
       ([s-f1]  . exwm/monitor-only-builtin)
       ([s-f2]  . exwm/monitor-only-main)
       ([s-f3]  . exwm/monitor-builtin-and-main)
       ([s-f4]  . exwm/monitor-main-and-secondary)
       ([s-f5]  . exwm/monitor-only-secondary)
       ([s-f6]  . exwm/monitor-all)
       ([print] . exwm/screen-shot)
       ([home]  . beginning-of-buffer)
       ([end]   . end-of-buffer)
       ([s-tab] . ido-switch-buffer)
       ([?\s-w] . exwm-workspace-switch)
       ,@(mapcar (lambda (i)
                   `(,(kbd (format "s-%d" i)) .
		     (lambda ()
                       (interactive)
                       (exwm-workspace-switch-create ,i))))
		 (number-sequence 0 9))))
    (exwm-workspace-number 3)
    ;; (exwm-workspace-minibuffer-position nil)
    (mouse-autoselect-window t)
    (focus-follows-mouse t)
    :config
    (add-hook 'exwm-floating-setup-hook #'exwm-layout-hide-mode-line)
    (add-hook 'exwm-floating-exit-hook #'exwm-layout-show-mode-line)
    (add-hook 'exwm-init-hook #'exwm/setup-output-devices)
    (add-hook 'exwm-init-hook #'exwm/setup-keys)
    (add-hook 'exwm-init-hook #'exwm/start-dropbox-service)
    (add-hook 'exwm-update-class-hook #'exwm/update-class)
    (add-hook 'exwm-update-title-hook #'exwm/update-title)

    (require 'exwm-randr)
    (exwm-randr-enable))

  (use-package elisp-mode
    :defer t
    :config
    (add-hook 'emacs-lisp-mode-hook (lambda ()
				      (push '(">=" . ?≥) prettify-symbols-alist)
				      (push '("<=" . ?≤) prettify-symbols-alist)
				      (push '("defun" . ?ƒ) prettify-symbols-alist)
				      (push '("/=" . ?≠) prettify-symbols-alist)
				      (push '("nil" . ?∅) prettify-symbols-alist)
				      (push '("not" . ?¬) prettify-symbols-alist)
				      (prettify-symbols-mode)
				      (flymake-mode))))

  (use-package conf-mode
    :defer t
    :mode (("\\.*rc$" . conf-mode)
	   ("\\Dockerfile\\'" . conf-mode)))

  (use-package typescript-mode
    :defer t
    :ensure t
    :mode "\\.ts\\'")

  (use-package csharp-mode
    :defer t
    :ensure t
    :mode "\\.cs\\'")

  (use-package fsharp-mode
    :defer t
    :ensure t
    :mode "\\.fs\\'")

  (use-package mhtml-mode
    :defer t
    :mode "\\.html\\'")

  (use-package custom
    :demand t
    :custom
    (custom-file (concat user-emacs-directory "custom.el"))
    :config
    (when (file-exists-p custom-file)
      (load custom-file)))

  (use-package eshell
    :defer t
    :config
    (defun /eshell/color-filter (string)
      (let ((case-fold-search nil)
            (lines (split-string string "\n")))
	(cl-loop for line in lines
		 do (progn
                      (cond ((string-match "\\[DEBUG\\]" line)
                             (put-text-property 0 (length line) 'font-lock-face font-lock-comment-face line))
                            ((string-match "\\[INFO\\]" line)
                             (put-text-property 0 (length line) 'font-lock-face compilation-info-face line))
                            ((string-match "\\[WARN\\]" line)
                             (put-text-property 0 (length line) 'font-lock-face compilation-warning-face line))
                            ((string-match "\\[ERROR\\]" line)
                             (put-text-property 0 (length line) 'font-lock-face compilation-error-face line)))))
	(mapconcat 'identity lines "\n")))
    (defun eshell/ff (&rest args)
      "Opens a file in emacs."
      (when (not (null args))
	(mapc #'find-file (mapcar #'expand-file-name (eshell-flatten-list (reverse args))))))


    (defun eshell/h ()
      "Quickly run a previous command."
      (insert (completing-read
               "Run previous command: "
               (delete-dups (ring-elements eshell-history-ring))
               nil
               t)))
    (setenv "PAGER" "cat")
    (add-hook 'eshell-mode-hook (lambda ()
				  (add-to-list 'eshell-output-filter-functions #'eshell-truncate-buffer)))
    (add-hook 'eshell-post-command-hook (lambda ()
  					  (dolist (var '(
							 ("d" "dired $1")
							 ("g" "git $*")
							 ("ag" "ag --vimgrep --color $*")
							 ("ll" "ls -lh")
							 ("la" "ls -lah")
							 ("gst" "git status")
							 ("gl" "git log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all")
  							 ("config" "git --git-dir=$HOME/.cfg/ --work-tree=$HOME $*")))
					    (add-to-list 'eshell-command-aliases-list var)))))

  (use-package epa
    :defer t
    :custom
    (epa-file-encrypt-to user-mail-address)
    (epa-pinentry-mode 'loopback)
    (epa-file-select-keys nil))

  (use-package org-bullets
    :demand t
    :ensure t
    :custom
    (org-bullets-bullet-list '("●" "◇" "✚" "✜" "☯" "◆" "♠"))
    :hook (org-mode . org-bullets-mode))

  (use-package org-crypt
    :demand t)

  (use-package org
    :demand t
    :config
    (global-set-key (kbd "C-c c") 'org-capture)
    (global-set-key (kbd "C-c a") 'org-agenda)
    (org-babel-do-load-languages 'org-babel-load-languages
				 '((js . t)
				   (emacs-lisp . t)
				   (python . t)
				   (shell . t)))
    :custom
    (org-confirm-babel-evaluate nil)
    (org-directory "~/Org")
    (diary-file (expand-file-name "diary" org-directory))
    (org-use-speed-commands t)
    (org-agenda-skip-deadline-if-done t)
    (org-agenda-skip-scheduled-if-done t)
    (org-agenda-skip-timestamp-if-done t)
    (org-agenda-start-on-weekday 1)

    ;; Agenda files
    (org-agenda-files (list
		       (expand-file-name "inbox.org" org-directory)
		       (expand-file-name "gtd.org" org-directory)
		       (expand-file-name "tickler.org" org-directory)))
    ;; Add UTF-8 Symbols
    (org-tag-alist '((:startgrouptag)
		     (:grouptags)
		     ("@work" . ?w)
		     ("@home" . ?h)
		     (:endgrouptag)
		     (:grouptags)
		     ("research" . ?r)
		     ("coding" . ?c)
		     ("emacs" . ?e)
		     (:grouptags)
		     ("crypt" . ?E)
		     (:endgrouptag)
		     (:grouptags)
		     ("WAIT" . ?W)
		     ("STOP" . ?C)
		     (:endgrouptag)))

    (org-use-fast-todo-selection t)
    (org-todo-keywords '((sequence "❢(t)" "☯(p)" "|" "✔(d)")
			 (sequence "⧖(w@)" "|" "✘(c@)")))
    (org-todo-state-tags-triggers '(
				    ;; Moving to wait adds wait
				    ("⧖" ("WAIT" . t))
				    ;; Moving to stop adds stop
				    ("✘" ("STOP" . t))
				    ;; Moving to done removes wait/stop
				    ("✔" ("WAIT") ("STOP"))
				    ;; Moving to todo removes wait/stop
				    ("❢" ("WAIT") ("STOP"))))
    
    (org-crypt-key epa-file-encrypt-to)
    (org-crypt-use-before-save-magic)
    (org-tags-exclude-from-inheritance '("crypt"))
    (org-agenda-include-diary t)

    (org-capture-templates `(
			     ("t" "TODO" entry (file+headline , (expand-file-name "inbox.org" org-directory) "TASKS") "* ❢ %?\n %i\n")
			     ("a" "ARTICLE" plain (file (lambda ()
							  (let* ((title (read-string "Title: "))
								 (slug (replace-regexp-in-string
									"[^a-z]+" "-" (downcase title)))
								 (dir (expand-file-name "articles" org-directory)))
							    (unless (file-exists-p dir)
							      (make-directory dir))
							    (expand-file-name (concat slug ".org") dir)))) "#+TITLE: %^{Title}\n#+DATE: %<%Y-%m-%d>")
			     ;; More is coming here
			     ))
    :init)

  (use-package prog-mode
    :hook (
	   (org-mode . prettify-symbols-mode)
	   (org-mode . (lambda ()
			 (push '("#+BEGIN_SRC" . ?✎) prettify-symbols-alist)
			 (push '("#+begin_src" . ?✎) prettify-symbols-alist)
			 (push '("#+END_SRC" . ?□) prettify-symbols-alist)
			 (push '("#+end_src" . ?□) prettify-symbols-alist)
			 (push '(">=" . ?≥) prettify-symbols-alist)
			 (push '("<=" . ?≤) prettify-symbols-alist)
			 (push '("[X]" . ?☑) prettify-symbols-alist)
			 (push '("[ ]" . ?❍) prettify-symbols-alist)))
	   (prog-mode . display-line-numbers-mode)))
  
  (use-package emms
    :defer t
    :ensure t
    :config
    (require 'emms-player-simple)
    (require 'emms-source-file)
    (require 'emms-source-playlist)
    :custom
    (emms-player-list '(emms-player-mpg321
			emms-player-ogg123
			emms-player-mplayer))
    (emms-playlist-buffer-name "*Music*"))

  (use-package bookmark
    :demand t
    :custom
    (bookmark-default-file (expand-file-name "bookmarks" user-emacs-directory))
    (bookmark-save-flag 1))

  (use-package which-key
    :ensure t
    :config
    (which-key-mode))

  (use-package flymake
    :bind (("M-n" . flymake-goto-next-error)
	   ("M-p" . flymake-goto-prev-error)))

  (use-package symon
    :ensure t
    :config
    (symon-mode))

  (use-package all-the-icons
    :ensure t)

  (use-package all-the-icons-dired
    :ensure t)

  (use-package dired
    :defer t
    :requires all-the-icons-dired
    :config
    (add-hook 'dired-mode-hook (lambda ()
				 (all-the-icons-dired-mode)))
    :custom
    (dired-listing-switches "-alGhvF --group-directories-first")) 

  (use-package doom-modeline
    :ensure t
    :custom
    (doom-modeline-icon t)
    :init
    (doom-modeline-mode 1))
  
  (defun session-restore ()
    "Restore a saved emacs session."
    (interactive)
    (if (saved-session)
	(desktop-read)
      (message "No desktop found.")))

  ;; use session-save to save the desktop manually
  (defun session-save ()
    "Save an emacs session."
    (interactive)
    (if (saved-session)
	(if (y-or-n-p "Overwrite existing desktop? ")
	    (desktop-save-in-desktop-dir)
	  (message "Session not saved."))
      (desktop-save-in-desktop-dir)))  

  (use-package desktop
    :custom
    (desktop-path (list user-emacs-directory))
    (desktop-dirname user-emacs-directory)
    (desktop-base-file-name "emacs-desktop")    
    (desktop-buffers-not-to-save
     (concat "\\("
             "^nn\\.a[0-9]+\\|\\.log\\|(ftp)\\|^tags\\|^TAGS"
             "\\|\\.emacs.*\\|\\.diary\\|\\.newsrc-dribble\\|\\.bbdb"
	     "\\)$"))
    :config
    (add-hook 'desktop-after-read-hook
	      '(lambda ()
		 ;; desktop-remove clears desktop-dirname
		 (setq desktop-dirname-tmp desktop-dirname)
		 (desktop-remove)
		 (setq desktop-dirname desktop-dirname-tmp)))    
    (add-to-list 'desktop-globals-to-save 'register-alist)
    (add-to-list 'desktop-modes-not-to-save 'dired-mode)
    (add-to-list 'desktop-modes-not-to-save 'Info-mode)
    (add-to-list 'desktop-modes-not-to-save 'info-lookup-mode)
    (add-to-list 'desktop-modes-not-to-save 'fundamental-mode)    
    (desktop-save-mode 1))

  (use-package olivetti
    :ensure t
    :hook (org-mode . olivetti-mode))

  (use-package poet-theme
    :ensure t
    :demand t
    :hook (text-mode . variable-pitch-mode)
    :config
    (set-face-attribute 'default nil :family "Iosevka" :height 130)
    (set-face-attribute 'fixed-pitch nil :family "Iosevka")
    (set-face-attribute 'variable-pitch nil :family "Baskerville")
    (load-theme 'poet t))
  
  (use-package dashboard
    :requires all-the-icons
    :ensure t    
    :custom
    (dashboard-banner-logo-title "Welcome to Debian/Emacs")
    (dashboard-startup-banner 'logo)
    (dashboard-center-content t)
    (dashboard-show-shortcuts nil)
    (dashboard-items '((recents . 5)
  		       (bookmarks . 5)
  		       (agenda . 5)
  		       (registers . 5)))
    (dashboard-set-heading-icons t)
    (dashboard-set-file-icons t)
    (dashboard-set-navigator t)
    (dashboard-set-init-info t)
    (dashboard-set-footer nil)
    (show-week-agenda-p t)
    (initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
    :config
    (dashboard-setup-startup-hook)))
