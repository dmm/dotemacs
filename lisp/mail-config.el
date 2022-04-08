;;; smtpmail config

(require 'smtpmail)

(setq smtpmail-starttls-credentials '(("home.mattli.us" 587 nil nil))
      smtpmail-smtp-server "home.mattli.us"
      send-mail-function 'smtpmail-send-it
					;      message-send-mail-function 'smtpmail-send-it
      smtpmail-smtp-service 587
      smtpmail-auth-credentials '(("home.mattli.us"
				   587
				   "dmm@mattli.us"
				   nil)))

(setq user-mail-address "dmm@mattli.us")

(setq smtpmail-debug-info t)
