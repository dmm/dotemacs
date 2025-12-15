(use-package org2blog
  :config
  (setq org2blog/wp-blog-alist
        '(("mattliblog"
           :url "https://blog.mattli.us/xmlrpc.php"
           :username "dmm")))
  (setq org2blog/wp-image-upload t)
)
