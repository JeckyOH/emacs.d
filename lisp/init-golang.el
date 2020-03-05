;; based on the assumption that the following repos are installed and
;; available on exec-path
;;
;; - github.com/nsf/gocode
;; - golang.org/x/tools/cmd/goimports
;; - github.com/rogpeppe/godef
;; - github.com/golang/lint

(defun ja-gomode-hook ()
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
           "go generate && go build -v && go test -v --coverprofile=cover.out && go vet"))
  (flycheck-mode)
  ;; Key bindings specific to go-mode
  (local-set-key (kbd "M-.") 'godef-jump)         ; Go to definition
  (local-set-key (kbd "M-*") 'pop-tag-mark)       ; Return from whence you came
  (local-set-key (kbd "M-p") 'compile)            ; Invoke compiler
  (local-set-key (kbd "M-P") 'recompile)          ; Redo most recent compile cmd
  (local-set-key (kbd "M-]") 'next-error)         ; Go to next error (or msg)
  (local-set-key (kbd "M-[") 'previous-error)     ; Go to previous error or msg
  )

(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "GOPATH"))

(when (maybe-require-package 'go-mode)
  (add-hook 'go-mode-hook 'ja-gomode-hook)

  (when (maybe-require-package 'go-eldoc)
    (add-hook 'go-mode-hook 'go-eldoc-setup))

  (when (maybe-require-package 'company-go)
    (after-load 'company
      (after-load 'go-mode
        (push 'company-go company-backends))))
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook #'gofmt-before-save)
  (add-to-list 'load-path (concat "/Users/jecky/work/clarifai/go"  "/src/golang.org/x/lint/misc/emacs"))
  (require 'golint)
  (when (maybe-require-package 'dap-mode)
    (dap-mode 1)
    (dap-ui-mode 1)
    ;; enables mouse hover support
    (dap-tooltip-mode 1)
    ;; use tooltips for mouse hover
    ;; if it is not enabled `dap-mode' will use the minibuffer.
    (tooltip-mode 1)
    (require 'dap-go)
    (add-hook 'dap-stopped-hook
              (lambda (arg) (call-interactively #'dap-hydra)))
    (dap-register-debug-template "Go Remote Attach Configuration"
                                 (list :type "go"
                                       :request "lauch"
                                       :name "Attach Executable"
                                       :mode "remote"
                                       :program "/Users/jecky/work/clarifai/go/src/clarifai/api"
                                       :remotePath "/home/ubuntu/work/clarifai/go/src/clarifai/api"))
    ))

(provide 'init-golang)
