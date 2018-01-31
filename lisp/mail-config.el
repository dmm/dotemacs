;;; smtpmail config

(require 'smtpmail)

(setq smtpmail-starttls-credentials '(("smtp.mattlimech.com" 587 nil nil))
      smtpmail-smtp-server "smtp.mattlimech.com"
      smtpmail-default-smtp-server "smtp.mattlimech.com"
      send-mail-function 'smtpmail-send-it
					;      message-send-mail-function 'smtpmail-send-it
      smtpmail-smtp-service 587
      smtpmail-auth-credentials '(("smtp.mattlimech.com"
				   587
				   "dmm"
				   nil)))

(setq user-mail-address "dmm@mattli.us")

(setq smtpmail-debug-info t)
