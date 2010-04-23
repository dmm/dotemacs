 ;;; Configuration for gnus

(require 'gnus)

(setq gnus-select-method '(nntp "news.kc.sbcglobal.net"))


(setq gnus-secondary-select-methods
      '(
	(nnimap "mattli.us"
		(nnimap-address "mattli.us")
;		(remove-prefix "INBOX.")
;		(nnimap-authinfo-file "/home/dmm/.imap-authinfo")
		)))

(setq nnmail-split-methods
      '(("bitc-dev"
	 "To:.*\\(bitc-dev@bitc-lang.org\\|bitc-dev@coyotos.org\\)")
	("openbsd-misc"
	 "\\(\\(C\\|c\\)\\(C\\|c\\)\\|\\(T\\|t\\)\\(O\\|o\\)\\)\\:.*misc@.*openbsd.org.*")
        ("openbsd-tech"
	 "\\(\\(C\\|c\\)\\(C\\|c\\)\\|\\(T\\|t\\)\\(O\\|o\\)\\)\\:.*tech@.*openbsd.org")
	("cells-devel"
	 "\\(\\(C\\|c\\)\\(C\\|c\\)\\|\\(T\\|t\\)\\(O\\|o\\)\\)\\:.*cells-devel@common-lisp.net")
	("cells-gtk-devel"
	 "\\(\\(C\\|c\\)\\(C\\|c\\)\\|\\(T\\|t\\)\\(O\\|o\\)\\)\\:.*cells-gtk-devel@common-lisp.net")
	("gpsd-users"
	 "\\(\\(C\\|c\\)\\(C\\|c\\)\\|\\(T\\|t\\)\\(O\\|o\\)\\)\\:.*gpsd-users@\\(berlios.de\\|lists.berlios.de\\)")
	("openbsd-ports"
	 "\\(\\(C\\|c\\)\\(C\\|c\\)\\|\\(T\\|t\\)\\(O\\|o\\)\\)\\:.*ports@openbsd.org.*")
	("misc"
	 "")))

(setq nnimap-expunge-on-close "never")
(setq gnus-permanently-visible-groups "e") ;Always display subscribed groups with e in name ;)


