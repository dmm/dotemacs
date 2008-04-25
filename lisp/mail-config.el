;;; smtpmail config

(require 'smtpmail)

(setq smtpmail-starttls-credentials '(("smtp.umr.edu" 587 nil nil))
      smtpmail-smtp-server "smtp.umr.edu"
      smtpmail-default-smtp-server "smtp.umr.edu"
      send-mail-function 'smtpmail-send-it
      message-send-mail-function 'smtpmail-send-it
      smtpmail-smtp-service 587
      smtpmail-auth-credentials '(("smtp.umr.edu"
				   587
				   "dmmyq5"
				   nil)))

(setq user-mail-address "david.mattli@umr.edu")

