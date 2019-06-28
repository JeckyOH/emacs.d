;;;Before installing cc mode, you need to install several dependencies:;
;;;ycmd server : github.com / Valloric / ycmd
;;;1. brew install cmake;
;;;2. clone ycmd repo,
;;;jump into it and build it using./ build.py-- clang - completer;
;;;ripgrep : https: // github.com/BurntSushi/ripgrep#installation
;;;1. brew install ripgrep;
;;;universal - ctags : https: // github.com/universal-ctags/ctags
;;;1. brew install-- HEAD universal - ctags / universal - ctags / universal -
;;;ctags;
;;;clang - format;
;;;1. brew install clang-format

(when (maybe-require-package 'ycmd)
  (set-variable 'ycmd-server-command '("python3" "-u" "/Users/jecky/ycmd/ycmd"))
  (set-variable 'ycmd-global-config (expand-file-name "~/.ycm_global_config.py"))
  (set-variable 'ycmd-extra-conf-whitelist '("~/work/*"))
  (set-variable 'ycmd-startup-timeout 5)
  (add-hook 'c++-mode-hook 'ycmd-mode)

  (when (maybe-require-package 'company-ycmd)
    (after-load 'company
      (add-hook 'c++-mode-hook
                (lambda () (sanityinc/local-push-company-backend 'company-ycmd)))
      (add-hook 'c++-mode-hook 'company-ycmd-setup)))

  (when (maybe-require-package 'flycheck-ycmd)
    (after-load 'flycheck
      (add-hook 'c-mode-common-hook 'flycheck-ycmd-setup)))

  (require 'ycmd-eldoc)
  (add-hook 'ycmd-mode-hook 'ycmd-eldoc-setup))

(defun jecky-ccmode-hook ()
  (local-set-key (kbd "M-.") 'counsel-etags-find-tag-at-point) ; Go to definition
  (local-set-key (kbd "M-*") 'pop-tag-mark) ; Return from whence you came
  (local-set-key (kbd "M-t") 'counsel-etags-grep-symbol-at-point)
  )

(when (maybe-require-package 'counsel-etags)
  (add-hook 'c-mode-common-hook 'jecky-ccmode-hook)
  (eval-after-load 'counsel-etags
    '(progn
       ;; Ignore files above 800kb
       (setq counsel-etags-max-file-size 1024)
       ;; counsel-etags-ignore-directories does NOT support wildcast
       (add-to-list 'counsel-etags-ignore-directories "build")
       (add-to-list 'counsel-etags-ignore-directories "clarifai")
       (add-to-list 'counsel-etags-ignore-directories "bazel-cache")
       (add-to-list 'counsel-etags-ignore-directories "sdk/models")
       (add-to-list 'counsel-etags-ignore-directories "go")
       (add-to-list 'counsel-etags-ignore-directories "datasets")
       (add-to-list 'counsel-etags-ignore-directories "conf")
       (add-to-list 'counsel-etags-ignore-directories "infra")
       (add-to-list 'counsel-etags-ignore-directories "java")
       (add-to-list 'counsel-etags-ignore-directories "js")
       (add-to-list 'counsel-etags-ignore-directories "py")
       (add-to-list 'counsel-etags-ignore-directories "third_party")
       ;; counsel-etags-ignore-filenames supports wildcast
       (add-to-list 'counsel-etags-ignore-filenames "TAGS")
       (add-to-list 'counsel-etags-ignore-filenames "bazel-*")
       (add-to-list 'counsel-etags-ignore-filenames "*.model")
       (add-to-list 'counsel-etags-ignore-filenames "*.db")
       (add-to-list 'counsel-etags-ignore-filenames ".clang-format")))
  ;; Don't ask before rereading the TAGS files if they have changed
  (setq tags-revert-without-query t)
  ;; Don't warn when TAGS files are large
  (setq large-file-warning-threshold nil)
  ;; How many seconds to wait before rerunning tags for auto-update
  (setq counsel-etags-update-interval 180)

  ;; Sete up auto-update
  (add-hook
   'prog-mode-hook
   (lambda () (add-hook 'after-save-hook
                   (lambda ()
                     (counsel-etags-virtual-update-tags))))
   )
  )

(when (maybe-require-package 'clang-format)
  (add-hook
   'c-mode-common-hook
   (lambda ()
     (local-set-key (kbd "C-c C-r") 'clang-format-region)
     (local-set-key (kbd "C-c C-f") 'clang-format-buffer)))
  (setq clang-format-style-option "google"))

(when (maybe-require-package 'modern-cpp-font-lock)
  (add-hook 'c++-mode-hook #'modern-c++-font-lock-mode))

(when (maybe-require-package 'google-c-style)
  (add-hook 'c-mode-common-hook 'google-set-c-style)
  (add-hook 'c-mode-common-hook 'google-make-newline-indent))
(defun indent_hook ()
  (setq c-basic-offset 4)
  (setq tab-width 4)
  (setq-default indent-tabs-mode nil))

(add-hook 'c-mode-common-hook 'indent_hook)

(add-hook 'c-mode-common-hook 'hs-minor-mode)

(provide 'init-ccmode)
