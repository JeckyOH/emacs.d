;;; init-python.el --- Python editing -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq auto-mode-alist
      (append '(("SConstruct\\'" . python-mode)
                ("SConscript\\'" . python-mode))
              auto-mode-alist))

(require-package 'pip-requirements)

(when (maybe-require-package 'anaconda-mode)
  (after-load 'python
    (add-hook 'python-mode-hook 'anaconda-mode)
    (add-hook 'python-mode-hook 'anaconda-eldoc-mode))
  (after-load 'anaconda-mode
    (define-key anaconda-mode-map (kbd "M-?") nil))
  (when (maybe-require-package 'company-anaconda)
    (after-load 'company
      (after-load 'python
        (push 'company-anaconda company-backends)))))

(when (maybe-require-package 'py-isort)
  (setq py-isort-options '("-sp /Users/jecky/work/clarifai/.isort.cfg -y"))
  (after-load 'python
    (add-hook 'python-mode-hook '(lambda () (add-hook 'before-save-hook 'py-isort-before-save)))))

;; Here we add auto-removal of python imports.
(defcustom python-autoflake-path (executable-find "autoflake")
  "Autoflake executable path. Allows working with a virtualenv without actually adding support
for it."
  :group 'python
  :type 'string)

(defcustom python-yapf-path (executable-find "yapf")
  "yapf executable path. Allows working with a virtualenv without actually adding support
for it."
  :group 'python
  :type 'string)


(defun python-remove-unused-imports ()
  "Use Autoflake to remove unused function. This also runs yapf afterwards in order to make sure that the file is properly formatted after imports are removed. This has to be applied as after-save-hook as it applies inplace.
$ autoflake --remove-all-unused-imports --remove-unused-variables -i unused_imports.py
$ yapf -i unused_imports.py
"
  (interactive)
  (when (eq major-mode 'python-mode)
    (shell-command (format "%s --expand-star-imports --remove-all-unused-imports -i %s"
                           python-autoflake-path
                           (shell-quote-argument (buffer-file-name))))
    (shell-command (format "%s -i %s"
                           python-yapf-path
                           (shell-quote-argument (buffer-file-name))))
    (revert-buffer t t t))
  nil)

(eval-after-load 'python
  '(if python-autoflake-path
       (add-hook 'after-save-hook 'python-remove-unused-imports)
     (message "Unable to find autoflake. Configure `python-autoflake-path`")))

;; ===========================================================================
;; pylint with flymake
;; ===========================================================================
;; Configure flymake for Python
(setq pylint (concat (getenv "HOME") "/virtualenv/v1/bin/pylint"))

;; (setq pylint "/opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin/epylint")
(when (load "flymake" t)
  (defun flymake-pylint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list pylint (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pylint-init)))

;; Set as a minor mode for Python
(add-hook 'python-mode-hook '(lambda () (flymake-mode)))

;; Configure to wait a bit longer after edits before starting
(setq-default flymake-no-changes-timeout '3)

;; ;; Keymaps to navigate to the errors
(add-hook 'python-mode-hook '(lambda () (define-key python-mode-map "\C-cn" 'flymake-goto-next-error)))
(add-hook 'python-mode-hook '(lambda () (define-key python-mode-map "\C-cp" 'flymake-goto-prev-error)))

;; To avoid having to mouse hover for the error message, these functions make flymake error messages
;; appear in the minibuffer
;; (defun show-fly-err-at-point ()
;;   "If the cursor is sitting on a flymake error, display the message in the minibuffer"
;;   (require 'cl)
;;   (interactive)
;;   (let ((line-no (line-number-at-pos)))
;;     (dolist (elem flymake-err-info)
;;       (if (eq (car elem) line-no)
;;           (let ((err (car (second elem))))
;;             (message "%s" (flymake-ler-text err)))))))
(defun show-fly-err-at-point ()
  "Return the flymake error at point, or nil if there is none."
  (mapconcat #'flymake-diagnostic-text (flymake-diagnostics (point)) "\n"))

(add-hook 'post-command-hook 'show-fly-err-at-point)
;; ===========================================================================

(provide 'init-python)
;;; init-python.el ends here
