(setq user-full-name "Mridul Kapoor")
(setq user-mail-address "mridulkapoor@gmail.com")

(setenv "PATH" (concat "/usr/local/bin:/opt/local/bin:/usr/bin:/bin:/home/mridul/.cabal/bin" (getenv "PATH")))
(require 'cl)


;; package sources
(load "package")
(package-initialize)
(add-to-list 'package-archives
	     '("gnu" . "http://elpa.gnu.org/packages/"))
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

(setq package-archive-enable-alist '(("melpa" deft magit)))

;; for things that don't come with package managers, we'll use a vendor directory
(defvar mridul/vendor-dir (expand-file-name "vendor" user-emacs-directory))
(add-to-list 'load-path mridul/vendor-dir)

(dolist (project (directory-files mridul/vendor-dir t "\\w+"))
  (when (file-directory-p project)
    (add-to-list 'load-path project)))


;; default packages
(defvar mridul/packages '(ac-slime
                          auto-complete
                          autopair
                          elpy
                          exec-path-from-shell
                          feature-mode
                          flycheck
                          gist
                          htmlize
                          jedi
                          magit
                          markdown-mode
                          marmalade
                          org
                          restclient
                          sml-mode
                          solarized-theme
                          sphinx-doc
                          web-mode
                          writegood-mode
                          yaml-mode)
  "Default packages")

;; install default packages at startup
(defun mridul/packages-installed-p ()
  (loop for pkg in mridul/packages
        when (not (package-installed-p pkg)) do (return nil)
        finally (return t)))

(unless (mridul/packages-installed-p)
  (message "%s" "Refreshing package database...")
  (package-refresh-contents)
  (dolist (pkg mridul/packages)
    (when (not (package-installed-p pkg))
      (package-install pkg))))


;; always skip the splash screen
(setq inhibit-splash-screen t
      initial-scratch-message nil
      initial-major-mode 'org-mode)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)

(delete-selection-mode t)
(transient-mark-mode t)
(setq x-select-enable-clipboard t)

(setq-default indicate-empty-lines t)
(when (not indicate-empty-lines)
  (toggle-indicate-empty-lines))

;; no tabs. 4 spaces
(setq indent-tabs-mode nil)
(setq tab-width 2)

;; no irritating backup files
(setq make-backup-files nil)

;; single letter yes/no replies
(defalias 'yes-or-no-p 'y-or-n-p)

;; useful key bindings
(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "C-;") 'comment-or-uncomment-region)
(global-set-key (kbd "M-/") 'hippie-expand)
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-c C-k") 'compile)
(global-set-key (kbd "C-x g") 'magit-status)

;; some org-mode config
(setq org-log-done t
      org-todo-keywords '((sequence "TODO" "INPROGRESS" "DONE"))
      org-todo-keyword-faces '(("INPROGRESS" . (:foreground "blue" :weight bold))))
(add-hook 'org-mode-hook
          (lambda ()
            (flyspell-mode)))
(add-hook 'org-mode-hook
          (lambda ()
            (writegood-mode)))

;; ido-mode
(ido-mode t)
(setq ido-enable-flex-matching t
      ido-use-virtual-buffers t)

;; column-number mode
(setq column-number-mode t)

;; temporary file management
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; auto-complete on
(require 'auto-complete-config)
(ac-config-default)

;; indentation and buffer cleanup
(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (indent-buffer)
  (untabify-buffer)
  (delete-trailing-whitespace))

(defun cleanup-region (beg end)
  "Remove tmux artifacts from region."
  (interactive "r")
  (dolist (re '("\\\\│\·*\n" "\W*│\·*"))
    (replace-regexp re "" nil beg end)))

(global-set-key (kbd "C-x M-t") 'cleanup-region)
(global-set-key (kbd "C-c n") 'cleanup-buffer)

(setq-default show-trailing-whitespace t)

;; flyspell
(setq flyspell-issue-welcome-flag nil)
(if (eq system-type 'darwin)
    (setq-default ispell-program-name "/usr/local/bin/aspell")
  (setq-default ispell-program-name "/usr/bin/aspell"))
(setq-default ispell-list-command "list")

;; markdown mode and previews
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.mdown$" . markdown-mode))
(add-hook 'markdown-mode-hook
          (lambda ()
            (visual-line-mode t)
            (writegood-mode t)
            (flyspell-mode t)))
(setq markdown-command "pandoc --smart -f markdown -t html")
(setq markdown-css-paths `(,(expand-file-name "markdown.css" mridul/vendor-dir)))

(if window-system
    (load-theme 'solarized-light t)
  (load-theme 'wombat t))

;; tex
(load "auctex.el" nil t t)
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-buffer)

;; remove trailing whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; consolas font
;; (add-to-list 'default-frame-alist '(font . 'Consolas ))
;; (set-face-attribute 'default t :font 'Consolas )
(set-default-font "Consolas-13")

;; python elpy mode
(elpy-enable)

;; sphinx-doc for python docstrings
(add-hook 'python-mode-hook (lambda ()
                              (require 'sphinx-doc)
                              (sphinx-doc-mode t)))

;; tramp settings
(setq tramp-default-method "ssh")

;; path and other environment variables from shell
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;; jedi mode settings for python autocomplete
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)
