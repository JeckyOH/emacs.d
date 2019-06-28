;;; Install buildifier
;;; go get -u github.com/bazelbuild/buildtools/buildifier

(when (maybe-require-package 'bazel-mode)
  (add-hook 'bazel-mode-hook (lambda () (add-hook 'before-save-hook #'bazel-format nil t))))

(provide 'init-bazelmode)
