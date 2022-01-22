;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Anirudh H M"
      user-mail-address "anihm136@gmail.com")

(setq display-line-numbers-type 'relative)

(setq org-directory nil)

;; Utility variables

(defconst ani/org-directory "~/storage/shared/Documents/org/"
  "The default directory for org files.")

(defvar dark-themes '(doom-one doom-gruvbox doom-solarized-dark doom-spacegrey doom-monokai-pro doom-tomorrow-night)
  "Set of dark themes to choose from.")

(defvar light-themes '(doom-gruvbox-light doom-solarized-light doom-flatwhite)
  "Set of light themes to choose from.")

;; Eager loading
(setq-default tab-width 2
              standard-indent 2
              load-prefer-newer t
              org-download-image-dir "./images"
              org-download-heading-lvl 'nil
              ispell-dictionary "en-custom"
              ispell-personal-dictionary (expand-file-name ".ispell_personal" doom-private-dir))

(custom-set-faces! '(font-lock-comment-face :slant italic))

(use-package! evil-escape
  :config
  (setq evil-escape-key-sequence "fd"
        evil-escape-delay 0.3))

(use-package! aggressive-indent
  :config
  (aggressive-indent-global-mode))

(use-package! doom-modeline
  :config
  (setq doom-modeline-indent-info t
        doom-modeline-unicode-fallback t
        doom-modeline-buffer-file-name-style 'truncate-upto-root))

;; Deferred loading
(use-package! org
  :defer t
  :config
  (setq org-ellipsis " ▾ "
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        org-refile-allow-creating-parent-nodes 'confirm
        org-catch-invisible-edits 'smart
        org-list-demote-modify-bullet '(("+" . "*") ("-" . "+") ("*" . "-") ("1." . "a."))
        org-startup-folded 'content
        org-log-done 'time
        org-log-into-drawer t
        org-log-state-notes-insert-after-drawers nil
        org-attach-id-dir ".attach/"
        org-attach-dir-relative t
        org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAITING(w)" "RECURRING(a)" "|" "DONE(d)" "CANCELLED(c)")
                            (sequence "REFILE(f)" "READ(r)" "PROJECT(p)" "|"))
        org-capture-templates
        `(("i" "Inbox" entry
           (file ,(concat ani/org-directory "GTD/" "inbox.org"))
           "* REFILE %i%?")
          ("l" "Org protocol" entry
           (file ,(concat ani/org-directory "GTD/" "inbox.org"))
           "* READ [[%:link][%:description]]\n %i"
           :immediate-finish t)
          ("k" "Clipboard link" entry
           (file ,(concat ani/org-directory "GTD/" "inbox.org"))
           "* READ %(org-cliplink-capture)\n" :immediate-finish t))))

(add-hook! 'org-mode-hook 'org-fragtog-mode)
(add-hook! 'org-mode-hook 'org-appear-mode)
(add-hook! 'org-mode-hook '+org-pretty-mode)

(map! :map org-mode-map
      :i "C-c b" (lambda () (interactive) (org-emphasize ?*))
      :i "C-c i" (lambda () (interactive) (org-emphasize ?/))
      :i "C-c m" (lambda () (interactive) (progn (insert "\\(\\)") (backward-char 2))))

(use-package! org-agenda
  :defer t
  :init
  (defalias '+org--restart-mode-h #'ignore)
  (setq
   org-agenda-files '("~/storage/shared/Documents/org/GTD")
   org-refile-targets `((,(concat ani/org-directory "GTD/" "projects.org") :maxlevel . 3)
                        (,(concat ani/org-directory "GTD/" "tasks.org") :maxlevel . 2)
                        (,(concat ani/org-directory "GTD/" "reading.org") :level . 1)
                        (,(concat ani/org-directory "GTD/" "someday.org") :level . 1))
   gtd/next-action-head "Next actions:"
   gtd/project-todos-head "Projects:"
   gtd/task-todos-head "Tasks:"
   gtd/waiting-head  "Waiting on:"
   gtd/inbox-head  "Dump:"
   gtd/recurring-head  "Recurring tasks:"
   org-agenda-custom-commands
   `(("g" "GTD view"
      ((agenda "" ((org-agenda-span 1) (org-agenda-start-on-weekday nil)))
       (todo "" ((org-agenda-files '(,(concat ani/org-directory "GTD/" "inbox.org"))) (org-agenda-overriding-header gtd/inbox-head)))
       (org-ql-search-block '(todo "NEXT")
                            ((org-ql-block-header gtd/next-action-head)))
       (org-ql-search-block '(or (todo "REFILE")
                                 (and (todo "PROJECT")
                                      (not (children (todo "PROJECT")))))
                            ((org-ql-block-header gtd/project-todos-head) (org-agenda-files '(,(concat ani/org-directory "GTD/" "projects.org")))))
       (org-ql-search-block '(todo "REFILE" "TODO")
                            ((org-ql-block-header gtd/task-todos-head) (org-agenda-files '(,(concat ani/org-directory "GTD/" "tasks.org")))))
       (org-ql-search-block '(todo "RECURRING")
                            ((org-ql-block-header gtd/recurring-head)))
       (org-ql-search-block '(todo "WAITING")
                            ((org-ql-block-header gtd/waiting-head)))))
     ("r" "Reading list"
      ((org-ql-search-block '(todo "READ")
                            ((org-agenda-files '(,(concat ani/org-directory "GTD/" "reading.org")))))))
     ("p" "Stuck projects"
      ((org-ql-search-block '(and (todo "PROJECT")
                                  (not (children (todo "PROJECT" "NEXT"))))))))))

(use-package! org-roam
  :defer t
  :custom-face
  (org-roam-link ((t (:inherit org-link :foreground "#009600"))))
  :config
  (setq org-roam-directory (concat ani/org-directory "notes/")
        org-roam-db-location (concat org-roam-directory "org-roam.db")
        org-roam-completion-fuzzy-match t
        org-roam-capture-templates
        '(("d" "default" plain "%?" :target
           (file+head "${slug}.org" "#+title: ${title}\n")
           :unnarrowed t))
        org-roam-buffer-width 0.25))

(use-package! company
  :defer t
  :config
  (setq company-frontends '(company-pseudo-tooltip-unless-just-one-frontend
                            company-preview-if-just-one-frontend
                            company-echo-metadata-frontend)))

(use-package! org-download
  :config
  (setq
   org-download-method 'directory
   org-download-timestamp "%Y%m%d-%H%M%S_"
   org-download-link-format "[[file:%s]]\n"
   org-download-link-format-function
   (lambda (filename)
     (format (concat (unless (image-type-from-file-name filename)
                       (concat (+org-attach-icon-for filename)
                               " "))
                     org-download-link-format)
             (org-link-escape (file-relative-name filename))))
   org-image-actual-width 400))

(add-hook! 'prog-mode-hook (lambda ()(modify-syntax-entry ?_ "w")))

(add-hook! 'after-init-hook '+ani/my-init-func)

(defun +ani/evil-unimpaired-paste-above ()
  "Linewise paste above."
  (interactive)
  (let ((register (if evil-this-register
                      evil-this-register
                    ?\")))
    (when (not (member 'evil-yank-line-handler (get-text-property 0 'yank-handler (evil-get-register register))))
      (evil-insert-newline-above))
    (evil-paste-before 1 register)))

(defun +ani/evil-unimpaired-paste-below ()
  "Linewise paste below."
  (interactive)
  (let ((register (if evil-this-register
                      evil-this-register
                    ?\")))
    (when (not (member 'evil-yank-line-handler (get-text-property 0 'yank-handler (evil-get-register register))))
      (evil-insert-newline-below))
    (evil-paste-after 1 register)))

(defun +ani/my-init-func ()
  "Function to run on init."
  (global-subword-mode t)
  (+ani/set-random-theme)
  (setq-default uniquify-buffer-name-style 'forward
                window-combination-resize t
                x-stretch-cursor t)
  (setq company-idle-delay nil
        inhibit-compacting-font-caches t
        evil-want-fine-undo t
        evil-vsplit-window-right t
        evil-split-window-below t
        +evil-want-o/O-to-continue-comments nil
        evil-respect-visual-line-mode nil
        doom-fallback-buffer-name "► Doom"
        +doom-dashboard-name "► Doom"
        alert-default-style 'libnotify)
  (map! :nv "C-a" 'evil-numbers/inc-at-pt
        :nv "C-S-x" 'evil-numbers/dec-at-pt
        :v "g C-a" 'evil-numbers/inc-at-pt-incremental
        :v "g C-S-x" 'evil-numbers/dec-at-pt-incremental
        :nv "M-j" 'drag-stuff-down
        :nv "M-k" 'drag-stuff-up
        :v "o" "$"
        :n "]p" '+ani/evil-unimpaired-paste-below
        :n "[p" '+ani/evil-unimpaired-paste-above
        :desc "Paste in insert mode"
        :i "C-v" "C-r +"
        :desc "Set random theme"
        :n "<f12>" '+ani/set-random-theme
        :n "S-<f12>" (λ! () (+ani/set-random-theme 't))))


(defun +ani/set-random-theme (&optional light)
  "Set the theme to a random dark theme.
If LIGHT is non-nil, use a random light theme instead."
  (interactive)
  (random t)
  (let ((themes (if light light-themes dark-themes)))
    (load-theme (nth (random (length themes)) themes) t))
  (princ (cdr custom-enabled-themes)))
