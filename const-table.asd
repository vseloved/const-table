(in-package #:asdf-user)

(defsystem #:const-table
  :version (:read-file-line "version.txt" :at 0)
  :description
  "Constant tables are constant access time space-efficient immutable
   data structures based on minimal perfect hashing."
  :author "Vsevolod Dyomkin <vseloved@gmail.com>"
  :maintainer "Vsevolod Dyomkin <vseloved@gmail.com>"
  :depends-on (#:rutilsx #:babel #:bit-smasher
               #+dev #:should-test)
  :serial t
  :components
  ((:module "src" :serial t
    :components ((:file "package")
                 (:file "hash")
                 (:file "graph")
                 (:file "core")
                 (:file "user")))
   #+dev
   (:module "test" :serial t
    :components ((:file "hash-test")
                 (:file "graph-test")
                 (:file "core-test")))))
