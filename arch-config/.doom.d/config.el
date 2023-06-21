;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "exu"
      user-mail-address "mrc@frm01.net")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
(setq doom-font (font-spec :family "monospace" :size 11.0 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "sans" :size 12.0))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-palenight)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Enables the minimap by default. Use SPC-t-m to toggle
;(minimap-mode 1)

(setq
 projectile-project-search-path '("~/GitProjects/"))

;; autoload magit
;(require 'magit-gitflow)
;(add-hook 'magit-mode-hook 'turn-on-magit-gitflow)

(setq hl-todo-keyword-faces
      '(("TODO"   . "#EACD4B")
        ("FIXME"   . "#F43633")
        ("NOTE"           . "#8ED34E")
        ("DEPRECATED"     . "#7F7F7F")
        ("HACK"           . "#7D5587")
        ("REVIEW"         . "#3DADC6")
        ("OHGODTHEHORROR"   . "#FC7702")))

;; Less delay for company to show up
(setq company-idle-delay 0)

;; Set tab width to 4 spaces
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)

;; work around emacs hanging when opening any python requirements.txt file
;; see issue https://github.com/doomemacs/doomemacs/issues/5998
(advice-add #'pip-requirements-fetch-packages :override #'ignore)

;; Enable nimlangserver for nim files
(add-hook 'nim-mode-hook #'lsp)

;; Disable formatter for php
(setq-hook! 'php-mode-hook +format-with :none)

; auto-virtualenv package configuration
(use-package! auto-virtualenv
  :init
  :config
  (add-hook! 'python-mode-hook 'auto-virtualenv-set-virtualenv)
  (add-hook! 'projectile-after-switch-project-hook 'auto-virtualenv-set-virtualenv)  ;; If using projectile
  )
