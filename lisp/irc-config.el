(when (featurep 'irc)
  (require 'rcirc)

  ;; Don't print /away messages.
  (defun rcirc-handler-301 (process cmd sender args)
    "/away message handler.")

  ;; Turn on spell checking.
  (add-hook 'rcirc-mode-hook (lambda ()
			       (flyspell-mode 1)))

  ;; Keep input line at bottom.
  (add-hook 'rcirc-mode-hook
	    (lambda ()
	      (set (make-local-variable 'scroll-conservatively)
		   8192)))

  ;; Adjust the colours of one of the faces.
  (set-face-foreground 'rcirc-my-nick "red" nil)


  ;; Change user info
  (setq rcirc-default-nick "davem")
  (setq rcirc-default-user-name "davem")
  (setq rcirc-default-user-full-name "David Mattli")


  ;; Include date in time stamp.
  (setq rcirc-time-format "%Y-%m-%d %H:%M ")

  ;; Join these channels at startup.
  (setq rcirc-startup-channels-alist
	'(("\\.oftc\\.net$" "#debian #xbox-linux")))

  (setq rcirc-server "irc.debian.net")
  
  (setq rcirc-authinfo '(("oftc" nickserv "dmm" "pr87bx"))))