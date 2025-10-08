;;; init.el --- Gruvbox Fall Theme Emacs Configuration
;;; Commentary:
;; Fast, beautiful Emacs setup with Gruvbox fall colors
;; Optimized for speed with IDE-like features

;;; Code:

;==========================================================
;   PERFORMANCE OPTIMIZATION
;==========================================================

;; Suppress compilation warnings
(setq native-comp-async-report-warnings-errors nil)
(setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))
(setq warning-minimum-level :error)

;; Increase garbage collection threshold for faster startup
(setq gc-cons-threshold (* 50 1000 1000))

;; Reduce startup time
(setq package-enable-at-startup nil)

;; Restore after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1000 1000))))

;==========================================================
;   PACKAGE MANAGEMENT
;==========================================================

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; Install use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;==========================================================
;   THEME - GRUVBOX FALL
;==========================================================

(use-package gruvbox-theme
  :config
  (load-theme 'gruvbox-dark-hard t)

  ;; Custom fall colors
  (custom-theme-set-faces
   'gruvbox-dark-hard
   '(mode-line ((t (:background "#3c3836" :foreground "#fabd2f" :box (:line-width 3 :color "#d65d0e")))))
   '(mode-line-inactive ((t (:background "#282828" :foreground "#928374"))))
   '(line-number-current-line ((t (:foreground "#fabd2f" :background "#3c3836" :weight bold))))
   '(hl-line ((t (:background "#3c3836"))))
   '(region ((t (:background "#504945"))))
   '(fringe ((t (:background "#282828"))))))

;==========================================================
;   UI IMPROVEMENTS
;==========================================================

;; Clean UI
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)

;; Line numbers
(global-display-line-numbers-mode t)
(setq display-line-numbers-type t)  ; Changed from 'relative to t
(setq display-line-numbers-width-start t)

;; Disable line numbers in certain modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                vterm-mode-hook
                shell-mode-hook
                eshell-mode-hook
                treemacs-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Better scrolling
(setq scroll-margin 8
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;; Font
(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 110)
(set-face-attribute 'fixed-pitch nil :font "JetBrainsMono Nerd Font" :height 110)
(set-face-attribute 'variable-pitch nil :font "JetBrainsMono Nerd Font" :height 110)

;; Cursor
(setq-default cursor-type 'box)
(blink-cursor-mode 1)

;; Highlight current line
(global-hl-line-mode t)

;; Show matching parentheses
(show-paren-mode 1)
(setq show-paren-delay 0)

;==========================================================
;   VIM KEYBINDINGS - EVIL MODE
;==========================================================

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-d-scroll t)
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  ;; Set initial state for modes
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode))

;==========================================================
;   WHICH-KEY - KEY HELPER
;==========================================================

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3)
  (setq which-key-popup-type 'side-window)
  (setq which-key-side-window-location 'bottom)
  (set-face-attribute 'which-key-local-map-description-face nil :foreground "#fabd2f"))

;==========================================================
;   TREEMACS - FILE EXPLORER
;==========================================================

(use-package treemacs
  :defer t
  :config
  (setq treemacs-width 35
        treemacs-follow-mode t
        treemacs-filewatch-mode t
        treemacs-fringe-indicator-mode 'always
        treemacs-git-mode 'deferred
        treemacs-show-hidden-files t
        treemacs-indentation 2
        treemacs-indent-guide-style 'line)

  ;; Gruvbox fall colors for treemacs
  (custom-set-faces
   '(treemacs-root-face ((t (:foreground "#fabd2f" :weight bold :height 1.2))))
   '(treemacs-directory-face ((t (:foreground "#83a598"))))
   '(treemacs-file-face ((t (:foreground "#ebdbb2"))))
   '(treemacs-git-modified-face ((t (:foreground "#d65d0e"))))
   '(treemacs-git-added-face ((t (:foreground "#b8bb26"))))
   '(treemacs-git-untracked-face ((t (:foreground "#928374")))))

  :bind
  (:map global-map
        ("C-c t t" . treemacs)
        ("C-c t f" . treemacs-find-file)
        ("C-c t s" . treemacs-select-window)))

(use-package treemacs-evil
  :after (treemacs evil))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-magit
  :after (treemacs magit))

;; Auto-open treemacs
(add-hook 'emacs-startup-hook 'treemacs)

;==========================================================
;   PROJECTILE - PROJECT MANAGEMENT
;==========================================================

(use-package projectile
  :diminish projectile-mode
  :config
  (projectile-mode)
  (setq projectile-completion-system 'ivy)
  (setq projectile-project-search-path '("~/projects/" "~/work/"))
  :bind-keymap
  ("C-c p" . projectile-command-map))

;==========================================================
;   IVY/COUNSEL - IMPROVED FILE SEARCHING
;==========================================================

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-height 15)
  (setq ivy-wrap t)

  ;; Fall colors for ivy
  (custom-set-faces
   '(ivy-current-match ((t (:background "#3c3836" :foreground "#fabd2f" :weight bold))))
   '(ivy-minibuffer-match-face-1 ((t (:foreground "#d65d0e"))))
   '(ivy-minibuffer-match-face-2 ((t (:foreground "#fe8019" :weight bold))))
   '(ivy-minibuffer-match-face-3 ((t (:foreground "#fabd2f" :weight bold))))
   '(ivy-minibuffer-match-face-4 ((t (:foreground "#b8bb26" :weight bold))))))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         ("C-c f" . counsel-fzf)
         ("C-c r" . counsel-rg)
         :map minibuffer-local-map
         ("C-r" . counsel-minibuffer-history)))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

;==========================================================
;   COMPANY - FAST AUTOCOMPLETE
;==========================================================

(use-package company
  :diminish company-mode
  :hook (prog-mode . company-mode)
  :config
  ;; Optimized for speed
  (setq company-idle-delay 0.1)  ; Fast but not instant
  (setq company-minimum-prefix-length 2)
  (setq company-tooltip-limit 10)
  (setq company-show-quick-access t)
  (setq company-tooltip-align-annotations t)
  (setq company-require-match nil)
  (setq company-dabbrev-downcase nil)
  (setq company-dabbrev-ignore-case nil)

  ;; Better performance
  (setq company-backends
        '((company-capf company-files company-keywords)
          (company-dabbrev-code company-dabbrev)))

  ;; Gruvbox fall colors
  (custom-set-faces
   '(company-tooltip ((t (:background "#3c3836" :foreground "#ebdbb2"))))
   '(company-tooltip-selection ((t (:background "#504945" :foreground "#fabd2f"))))
   '(company-tooltip-common ((t (:foreground "#d65d0e" :weight bold))))
   '(company-tooltip-annotation ((t (:foreground "#83a598"))))
   '(company-scrollbar-bg ((t (:background "#3c3836"))))
   '(company-scrollbar-fg ((t (:background "#928374")))))

  :bind
  (:map company-active-map
        ("C-n" . company-select-next)
        ("C-p" . company-select-previous)
        ("C-j" . company-select-next)
        ("C-k" . company-select-previous)
        ("TAB" . company-complete-selection)
        ("<tab>" . company-complete-selection)))

;==========================================================
;   LSP MODE - JAVA SUPPORT
;==========================================================

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((java-mode . lsp-deferred)
         (lsp-mode . lsp-enable-which-key-integration))
  :init
  ;; Performance tuning
  (setq lsp-keymap-prefix "C-c l"
        lsp-idle-delay 0.2
        lsp-completion-provider :none  ; Use company
        lsp-headerline-breadcrumb-enable nil
        lsp-lens-enable nil
        lsp-signature-auto-activate nil
        lsp-signature-render-documentation nil
        lsp-enable-symbol-highlighting nil
        lsp-modeline-code-actions-enable nil
        lsp-modeline-diagnostics-enable nil
        lsp-log-io nil
        lsp-enable-folding nil
        lsp-enable-text-document-color nil
        read-process-output-max (* 1024 1024))
  :config
  ;; Fall theme colors for LSP
  (custom-set-faces
   '(lsp-face-highlight-textual ((t (:background "#3c3836"))))
   '(lsp-face-highlight-read ((t (:background "#3c3836" :underline t))))
   '(lsp-face-highlight-write ((t (:background "#504945" :weight bold))))))

(use-package lsp-ui
  :after lsp-mode
  :commands lsp-ui-mode
  :config
  ;; Minimal UI for speed
  (setq lsp-ui-doc-enable nil
        lsp-ui-doc-delay 0.5
        lsp-ui-sideline-enable nil
        lsp-ui-peek-enable t))

(use-package lsp-java
  :after lsp-mode
  :config
  (setq lsp-java-format-enabled t
        lsp-java-save-actions-organize-imports t
        lsp-java-completion-enabled t))

;==========================================================
;   SYNTAX CHECKING - FLYCHECK
;==========================================================

(use-package flycheck
  :init (global-flycheck-mode)
  :config
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (setq flycheck-display-errors-delay 0.3)

  ;; Fall colors
  (custom-set-faces
   '(flycheck-error ((t (:underline (:color "#fb4934" :style wave)))))
   '(flycheck-warning ((t (:underline (:color "#fabd2f" :style wave)))))
   '(flycheck-info ((t (:underline (:color "#83a598" :style wave)))))))

;==========================================================
;   VTERM - TERMINAL
;==========================================================

(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000)
  (setq vterm-shell "/bin/bash")
  (setq vterm-kill-buffer-on-exit t)

  :bind
  ("C-c v" . vterm))

;==========================================================
;   BETTER SYNTAX HIGHLIGHTING
;==========================================================

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)
  :config
  ;; Gruvbox fall colors for delimiters
  (custom-set-faces
   '(rainbow-delimiters-depth-1-face ((t (:foreground "#fe8019"))))
   '(rainbow-delimiters-depth-2-face ((t (:foreground "#fabd2f"))))
   '(rainbow-delimiters-depth-3-face ((t (:foreground "#b8bb26"))))
   '(rainbow-delimiters-depth-4-face ((t (:foreground "#83a598"))))
   '(rainbow-delimiters-depth-5-face ((t (:foreground "#d3869b"))))
   '(rainbow-delimiters-depth-6-face ((t (:foreground "#8ec07c"))))
   '(rainbow-delimiters-depth-7-face ((t (:foreground "#d65d0e"))))
   '(rainbow-delimiters-depth-8-face ((t (:foreground "#d79921"))))
   '(rainbow-delimiters-depth-9-face ((t (:foreground "#cc241d"))))))

(use-package highlight-indent-guides
  :hook (prog-mode . highlight-indent-guides-mode)
  :config
  (setq highlight-indent-guides-method 'character)
  (setq highlight-indent-guides-character ?\┊)
  (setq highlight-indent-guides-responsive 'top)
  (custom-set-faces
   '(highlight-indent-guides-character-face ((t (:foreground "#3c3836"))))
   '(highlight-indent-guides-top-character-face ((t (:foreground "#d65d0e"))))))

;==========================================================
;   MODELINE - DOOM MODELINE
;==========================================================

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 32)
  (setq doom-modeline-bar-width 4)
  (setq doom-modeline-buffer-file-name-style 'truncate-upto-project)
  (setq doom-modeline-icon t)
  (setq doom-modeline-major-mode-icon t)
  (setq doom-modeline-major-mode-color-icon t)
  (setq doom-modeline-buffer-state-icon t)
  (setq doom-modeline-buffer-modification-icon t)
  (setq doom-modeline-time-icon t)
  (setq doom-modeline-lsp t)

  ;; Fall theme colors
  (custom-set-faces
   '(doom-modeline-bar ((t (:background "#d65d0e"))))
   '(doom-modeline-project-dir ((t (:foreground "#fabd2f" :weight bold))))
   '(doom-modeline-buffer-file ((t (:foreground "#ebdbb2"))))
   '(doom-modeline-buffer-modified ((t (:foreground "#fe8019" :weight bold))))
   '(doom-modeline-lsp-success ((t (:foreground "#b8bb26"))))
   '(doom-modeline-lsp-warning ((t (:foreground "#fabd2f"))))))

(use-package all-the-icons
  :if (display-graphic-p))

;==========================================================
;   GIT INTEGRATION
;==========================================================

(use-package magit
  :commands magit-status
  :bind ("C-c g" . magit-status))

(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :config
  (custom-set-faces
   '(git-gutter:modified ((t (:foreground "#d65d0e" :weight bold))))
   '(git-gutter:added ((t (:foreground "#b8bb26" :weight bold))))
   '(git-gutter:deleted ((t (:foreground "#fb4934" :weight bold))))))

;==========================================================
;   EDITOR IMPROVEMENTS
;==========================================================

;; Better undo
(use-package undo-tree
  :config
  (global-undo-tree-mode)
  (setq undo-tree-auto-save-history nil))

;; Smart parentheses
(use-package smartparens
  :hook (prog-mode . smartparens-mode)
  :config
  (require 'smartparens-config))

;; Multiple cursors
(use-package multiple-cursors
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

;; Better search
(use-package anzu
  :config
  (global-anzu-mode +1)
  (custom-set-faces
   '(anzu-mode-line ((t (:foreground "#fabd2f" :weight bold))))))
   
   
;==========================================================
;   ORG MODE CONFIGURATION
;==========================================================

(use-package org
  :ensure t
  :hook (org-mode . visual-line-mode)
  :config
  ;; Automatisch .org-Dateien im Org-Mode öffnen
  (add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

  ;; Schönere Darstellung
  (setq org-hide-emphasis-markers t)     ; *fett* -> fett ohne Sternchen
  (setq org-startup-indented t)          ; Einrückung für Unterpunkte
  (setq org-startup-folded 'content)     ; Überschriften standardmäßig eingeklappt
  (setq org-ellipsis " ▼ ")              ; hübscher Pfeil statt "..."
  (setq org-pretty-entities t)           ; z. B. λ statt \lambda

  ;; Schriftarten (passend zu deiner Gruvbox-Ästhetik)
  (custom-set-faces
   '(org-level-1 ((t (:foreground "#fabd2f" :height 1.3 :weight bold))))
   '(org-level-2 ((t (:foreground "#fe8019" :height 1.2 :weight bold))))
   '(org-level-3 ((t (:foreground "#b8bb26" :height 1.1))))
   '(org-level-4 ((t (:foreground "#83a598"))))
   '(org-document-title ((t (:foreground "#d3869b" :height 1.4 :weight bold))))
   '(org-link ((t (:foreground "#83a598" :underline t))))
   '(org-block ((t (:background "#3c3836" :extend t))))
   '(org-block-begin-line ((t (:foreground "#928374" :background "#3c3836"))))
   '(org-block-end-line ((t (:foreground "#928374" :background "#3c3836"))))))


   

;==========================================================
;   KEYBINDINGS
;==========================================================

;; General leader key setup
(use-package general
  :config
  (general-create-definer leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (leader-keys
    "f" '(:ignore t :which-key "files")
    "ff" '(counsel-find-file :which-key "find file")
    "fr" '(counsel-recentf :which-key "recent files")
    "fs" '(save-buffer :which-key "save file")

    "b" '(:ignore t :which-key "buffers")
    "bb" '(counsel-switch-buffer :which-key "switch buffer")
    "bk" '(kill-buffer :which-key "kill buffer")
    "bd" '(kill-this-buffer :which-key "kill this buffer")

    "w" '(:ignore t :which-key "window")
    "wv" '(split-window-right :which-key "split vertical")
    "ws" '(split-window-below :which-key "split horizontal")
    "wd" '(delete-window :which-key "delete window")
    "wo" '(delete-other-windows :which-key "delete other")

    "t" '(:ignore t :which-key "treemacs")
    "tt" '(treemacs :which-key "toggle treemacs")
    "tf" '(treemacs-find-file :which-key "find in treemacs")

    "p" '(:ignore t :which-key "project")
    "pf" '(projectile-find-file :which-key "find file")
    "pp" '(projectile-switch-project :which-key "switch project")
    "ps" '(counsel-rg :which-key "search project")

    "g" '(:ignore t :which-key "git")
    "gg" '(magit-status :which-key "magit status")

    "v" '(vterm :which-key "terminal")))

;==========================================================
;   FINAL TOUCHES
;==========================================================

;; Better defaults
(setq-default
 tab-width 4
 indent-tabs-mode nil
 fill-column 100)

;; Auto-revert files
(global-auto-revert-mode 1)

;; Remember cursor position
(save-place-mode 1)

;; Save history
(savehist-mode 1)

;; Better backup
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))
(setq auto-save-file-name-transforms `((".*" "~/.emacs.d/auto-save-list/" t)))

;; Delete trailing whitespace on save
(add-hook 'before-save-hook 'delete-trailing-whitespace)


;; Welcome message
(setq initial-scratch-message
      "


                    ╔════════════════════════════╗
                    ║   Gruvbox Fall Theme 🍂    ║
                    ║     Press SPC for help     ║
                    ╚════════════════════════════╝


")

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(gnome-dark-style general anzu multiple-cursors smartparens undo-tree git-gutter all-the-icons doom-modeline highlight-indent-guides rainbow-delimiters vterm flycheck lsp-java lsp-ui lsp-mode company ivy-rich counsel ivy treemacs-magit treemacs-projectile treemacs-evil treemacs which-key evil-commentary evil-collection evil gruvbox-theme)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(anzu-mode-line ((t (:foreground "#fabd2f" :weight bold))))
 '(company-tooltip ((t (:background "#3c3836" :foreground "#ebdbb2"))))
 '(company-tooltip-annotation ((t (:foreground "#83a598"))))
 '(company-tooltip-common ((t (:foreground "#d65d0e" :weight bold))))
 '(company-tooltip-scrollbar-thumb ((t (:background "#928374"))))
 '(company-tooltip-scrollbar-track ((t (:background "#3c3836"))))
 '(company-tooltip-selection ((t (:background "#504945" :foreground "#fabd2f"))))
 '(doom-modeline-bar ((t (:background "#d65d0e"))))
 '(doom-modeline-buffer-file ((t (:foreground "#ebdbb2"))))
 '(doom-modeline-buffer-modified ((t (:foreground "#fe8019" :weight bold))))
 '(doom-modeline-lsp-success ((t (:foreground "#b8bb26"))))
 '(doom-modeline-lsp-warning ((t (:foreground "#fabd2f"))))
 '(doom-modeline-project-dir ((t (:foreground "#fabd2f" :weight bold))))
 '(flycheck-error ((t (:underline (:color "#fb4934" :style wave)))))
 '(flycheck-info ((t (:underline (:color "#83a598" :style wave)))))
 '(flycheck-warning ((t (:underline (:color "#fabd2f" :style wave)))))
 '(git-gutter:added ((t (:foreground "#b8bb26" :weight bold))))
 '(git-gutter:deleted ((t (:foreground "#fb4934" :weight bold))))
 '(git-gutter:modified ((t (:foreground "#d65d0e" :weight bold))))
 '(highlight-indent-guides-character-face ((t (:foreground "#3c3836"))))
 '(highlight-indent-guides-top-character-face ((t (:foreground "#d65d0e"))))
 '(ivy-current-match ((t (:background "#3c3836" :foreground "#fabd2f" :weight bold))))
 '(ivy-minibuffer-match-face-1 ((t (:foreground "#d65d0e"))))
 '(ivy-minibuffer-match-face-2 ((t (:foreground "#fe8019" :weight bold))))
 '(ivy-minibuffer-match-face-3 ((t (:foreground "#fabd2f" :weight bold))))
 '(ivy-minibuffer-match-face-4 ((t (:foreground "#b8bb26" :weight bold))))
 '(lsp-face-highlight-read ((t (:background "#3c3836" :underline t))))
 '(lsp-face-highlight-textual ((t (:background "#3c3836"))))
 '(lsp-face-highlight-write ((t (:background "#504945" :weight bold))))
 '(rainbow-delimiters-depth-1-face ((t (:foreground "#fe8019"))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "#fabd2f"))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "#b8bb26"))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground "#83a598"))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "#d3869b"))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "#8ec07c"))))
 '(rainbow-delimiters-depth-7-face ((t (:foreground "#d65d0e"))))
 '(rainbow-delimiters-depth-8-face ((t (:foreground "#d79921"))))
 '(rainbow-delimiters-depth-9-face ((t (:foreground "#cc241d"))))
 '(treemacs-directory-face ((t (:foreground "#83a598"))))
 '(treemacs-file-face ((t (:foreground "#ebdbb2"))))
 '(treemacs-git-added-face ((t (:foreground "#b8bb26"))))
 '(treemacs-git-modified-face ((t (:foreground "#d65d0e"))))
 '(treemacs-git-untracked-face ((t (:foreground "#928374"))))
 '(treemacs-root-face ((t (:foreground "#fabd2f" :weight bold :height 1.2)))))
