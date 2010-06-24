;; cc-mode settings


(defconst kde-cpp-style
  '((c-tab-always-indent        . t)
    (indent-tabs-mode           . nil)
    (c-comment-only-line-offset . 4)
    (c-hanging-braces-alist     . ((substatement-open after)
                                   (brace-list-open)))
    (c-hanging-colons-alist     . ((member-init-intro before)
                                   (inher-intro)
                                   (case-label after)
                                   (label after)
                                   (access-label after)))
    (c-cleanup-list             . (scope-operator
                                   empty-defun-braces
                                   defun-close-semi))
    (c-offsets-alist            . ((arglist-close . c-lineup-arglist)
                                   (substatement-open . 0)
                                   (case-label        . 4)
                                   (block-open        . 0)
                                   (knr-argdecl-intro . -)))
    (c-echo-syntactic-information-p . t)
    )
  "kde pim style")

(defun KNF-c-style ()
  "OpenBSD KNF C-style."
  (interactive)
  (local-set-key "\C-c\C-c" 'compile)
  (c-set-style "bsd")
  (setq fill-column 80)
  (setq c-basic-offset 8)
  (c-set-offset 'arglist-cont '*)
  (c-set-offset 'arglist-cont-nonempty '*)
  (c-set-offset 'statement-cont '4) )
(add-hook 'c-mode-common-hook 'KNF-c-style)
