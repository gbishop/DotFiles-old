(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(case-fold-search t)
 '(cua-mode t nil (cua-base))
 '(current-language-environment "UTF-8")
 '(default-input-method "rfc1345")
 '(global-font-lock-mode t nil (font-lock))
 '(inhibit-startup-screen t)
 '(mouse-wheel-mode t nil (mwheel))
 '(pc-selection-mode t nil (pc-select))
 '(scroll-bar-mode nil)
 '(show-paren-mode t nil (paren))
 '(tool-bar-mode nil nil (tool-bar)))

;; current buffer name in title bar
(setq frame-title-format "%b - emacs")

(defun set-frame-size-according-to-resolution ()
  (interactive)
  (if window-system
      (progn
        (if (= (x-display-pixel-width) 2800)
            (add-to-list 'default-frame-alist (cons 'left 1400))
          (add-to-list 'default-frame-alist (cons 'left 100)))
        (add-to-list 'default-frame-alist (cons 'top 0))
        ;; for the height, subtract a couple hundred pixels
        ;; from the screen height (for panels, menubars and
        ;; whatnot), then divide by the height of a char to
        ;; get the height we want
        (add-to-list 'default-frame-alist 
                     (cons 'height (/ (- (x-display-pixel-height) 180)
                                      (frame-char-height))))
        (add-to-list 'default-frame-alist
                     (cons 'width 100))
)))

(set-frame-size-according-to-resolution)


;; add my emacs folder
;; (setq load-path (cons "~/misc/emacs" load-path))
(setq load-path (cons "~/.emacs.d" load-path))

; configure python
(setq-default indent-tabs-mode nil) ; changes tabs into spaces.
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)
(setq py-indent-offset 4)

;;;
;; Smart Tab

;; adapted from SebastienRoccaSerra
(defun smart-tab (prefix)
  "Needs `transient-mark-mode' to be on. This smart tab is
minibuffer compliant: it acts as usual in the minibuffer.

In all other buffers: if PREFIX is \\[universal-argument], calls
`smart-indent'. Else if point is at the end of a symbol,
expands it. Else calls `smart-indent'."
  (interactive "P")
  (if (minibufferp)
      (minibuffer-complete)
    (if (smart-tab-must-expand prefix)
        (dabbrev-expand nil)
      (smart-indent))))

(defun python-smart-indent-region (start end)
  "`indent-region-function' for Python.
Shifts all lines by the amount required to indent the first."
  (save-excursion
    (goto-char end)
    (setq end (point-marker))
    (goto-char start)
    (or (bolp) (forward-line 1))
    (let ((prior-indent (current-indentation)))
          (python-indent-line-1 t)
          (let ((delta (- (current-indentation) prior-indent)))
            (forward-line 1)
            (indent-rigidly (point) end delta)))
    (move-marker end nil)))

(defun smart-indent ()
  "Indents region if mark is active, or current line otherwise."
  (interactive)
  (if mark-active
      (indent-region (region-beginning)
                     (region-end))
    (indent-for-tab-command)))

(defun smart-tab-must-expand (&optional prefix)
  "If PREFIX is \\[universal-argument], answers no.
Otherwise, analyses point position and answers."
  (unless (or (consp prefix)
              mark-active)
    (looking-at "\\_>")))

(defun py-outline-level ()
  (let (buffer-invisibility-spec)
    (save-excursion
      (skip-chars-forward "\t ")
      (current-column))))

(defun my-compile ()
  "Use compile to run python programs"
  (interactive)
  (set (make-local-variable 'compilation-scroll-output) nil)
  (compile (concat "python " (buffer-name))))
; make the compile window scroll to follow output 
;(setq compilation-scroll-output t)

; this get called after python mode is enabled
(defun my-python-hook ()
  ; outline uses this regexp to find headers. I match lines with no indent and indented "class"
  ; and "def" lines.
  (setq outline-regexp "[ \t]*\\(def\\|class\\) ")
  ; enable our level computation
  (setq outline-level 'py-outline-level)
  ; turn on outline mode
  (outline-minor-mode t)
  ; bindings
  (local-set-key [backtab] 'python-shift-left)
  (local-set-key [(control down)] 'show-entry)
  (local-set-key [(control up)] 'hide-entry)
  (set (make-local-variable 'indent-region-function) #'python-smart-indent-region)
  ; indent automagically after return
  (define-key python-mode-map "\C-m" 'newline-and-indent)
  ; set things up to use compile mode for running python code
  (local-set-key "\C-c\C-c" 'my-compile)
)
; add my customizations when I visit a python file
(add-hook 'python-mode-hook 'my-python-hook)

(autoload #'espresso-mode "espresso" "Start espresso-mode" t)
(add-to-list 'auto-mode-alist '("\\.js$" . espresso-mode))
(add-to-list 'auto-mode-alist '("\\.json$" . espresso-mode))

; this gets called after javascript mode is enabled
(defun my-javascript-hook ()
  (local-set-key "\C-i" 'smart-tab)
  (set (make-local-variable 'compilation-error-regexp-alist)
       '(("^\\([a-zA-Z.0-9_/-]+\\):\\([0-9]+\\):\\([0-9]+\\)" 1 2 3)))
  (set (make-local-variable 'compile-command)
       (let ((file (file-name-nondirectory buffer-file-name)))
         (concat "jslint-cli " file)))
  (local-set-key "\C-c\C-c" 'compile)
  (set (make-local-variable 'compilation-scroll-output) nil)
)

(add-hook 'espresso-mode-hook 'my-javascript-hook)

; enable flymake mode
(when (load "flymake" t)
  (defun flymake-pylint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "epylint" (list local-file))))
  
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pylint-init)))

; fix file save
(defun my-save-all-buffers ()
  "Save all buffers without asking"
  (interactive)
  (save-some-buffers t))

; Start the server for emacsclient
; (server-start)

; fix clipboard behavior
(setq x-select-enable-clipboard t)
(setq interprogram-past-function 'x-cut-buffer-or-selection-value)

; add javascript
;(autoload 'javascript-mode "javascript" nil t)
;(add-to-list 'auto-mode-alist '("\\.js$" . javascript-mode))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "white" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 113 :width normal :foundry "unknown" :family "DejaVu Sans Mono")))))

; key bindings more like the rest of the world (including CUA turned on above)
(global-set-key (kbd "C-a") 'mark-whole-buffer)
(global-set-key (kbd "C-f") 'isearch-forward)
(define-key isearch-mode-map (kbd "C-f") 'isearch-repeat-forward)
(global-set-key (kbd "C-g") 'goto-line)
(global-set-key (kbd "C-n") 'other-window)
(global-set-key (kbd "C-o") 'find-file)
(global-set-key (kbd "C-x s") 'my-save-all-buffers)
(global-set-key (kbd "C-s") 'my-save-all-buffers)
(global-set-key "\C-z" 'undo)
(global-set-key (kbd "<tab>") 'smart-tab)
(global-set-key (kbd "<esc>") 'keyboard-quit)

(require 'color-theme-solarized)
(color-theme-solarized-light)