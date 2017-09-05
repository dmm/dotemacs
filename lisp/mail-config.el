;;; smtpmail config

(require 'smtpmail)

(setq smtpmail-starttls-credentials '(("mattlimech.com" 587 nil nil))
      smtpmail-smtp-server "mattlimech.com"
      smtpmail-default-smtp-server "mattlimech.com"
      send-mail-function 'smtpmail-send-it
					;      message-send-mail-function 'smtpmail-send-it
      smtpmail-smtp-service 587
      smtpmail-auth-credentials '(("mattlimech.com"
				   587
				   "dmm"
				   nil)))

(setq user-mail-address "dmm@mattli.us")

(setq smtpmail-debug-info t) 
