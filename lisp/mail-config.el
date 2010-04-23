;;; smtpmail config

(require 'smtpmail)

(setq smtpmail-starttls-credentials '(("mattli.us" 465 nil nil))
      smtpmail-smtp-server "mattli.us"
      smtpmail-default-smtp-server "mattli.us"
      send-mail-function 'smtpmail-send-it
      message-send-mail-function 'smtpmail-send-it
      smtpmail-smtp-service 587
      smtpmail-auth-credentials '(("mattli.us"
				   465
				   "dmm"
				   nil)))

(setq user-mail-address "dmm@mattli.us")

