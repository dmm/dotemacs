 ;;; Configuration for gnus

(require 'gnus)

(setq gnus-select-method '(nntp "news.kc.sbcglobal.net"))

(setq gnus-secondary-select-methods
      '(
	(nnimap "localhost"
		(nnimap-address "localhost")
		(remove-prefix "INBOX.")
		(nnimap-authinfo-file "/home/dmm/.imap-authinfo"))))

(setq nnimap-split-inbox
        '("INBOX"))

(setq nnimap-split-predicate "UNDELETED")

(setq nnimap-split-crosspost nil)

(setq nnimap-split-rule
      '(("INBOX.bitc-dev"
	 "To:.*\\(bitc-dev@bitc-lang.org\\|bitc-dev@coyotos.org\\)")
	("INBOX.openbsd-misc"
	 "\\(\\(C\\|c\\)\\(C\\|c\\)\\|\\(T\\|t\\)\\(O\\|o\\)\\)\\:.*misc@.*openbsd.org.*")
        ("INBOX.openbsd-tech"
	 "\\(\\(C\\|c\\)\\(C\\|c\\)\\|\\(T\\|t\\)\\(O\\|o\\)\\)\\:.*tech@.*openbsd.org")
	("INBOX.cells-devel"
	 "\\(\\(C\\|c\\)\\(C\\|c\\)\\|\\(T\\|t\\)\\(O\\|o\\)\\)\\:.*cells-devel@common-lisp.net")
	("INBOX.cells-gtk-devel"
	 "\\(\\(C\\|c\\)\\(C\\|c\\)\\|\\(T\\|t\\)\\(O\\|o\\)\\)\\:.*cells-gtk-devel@common-lisp.net")
	("INBOX.gpsd-users"
	 "\\(\\(C\\|c\\)\\(C\\|c\\)\\|\\(T\\|t\\)\\(O\\|o\\)\\)\\:.*gpsd-users@\\(berlios.de\\|lists.berlios.de\\)")
	("INBOX.openbsd-ports"
	 "\\(\\(C\\|c\\)\\(C\\|c\\)\\|\\(T\\|t\\)\\(O\\|o\\)\\)\\:.*ports@openbsd.org")))


(setq nnimap-expunge-on-close "never")
(setq gnus-permanently-visible-groups "i") ;Always display subscribed groups with e in name ;)


