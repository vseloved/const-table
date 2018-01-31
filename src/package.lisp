(cl:defpackage #:const-table
  (:nicknames #:cstab)
  (:use :common-lisp #:rutilsx
        #+dev #:should-test)
  (:export #:const-table
           #:make-const-table
           #:build-const-table
           #:const-table-mod
           #:const-table-data
           #:const-table-meta

           #:cstab
           #:make-cstab
           #:build-cstab
           #:cstab-mod
           #:cstab-data
           #:cstab-meta
           
           #:csget
           #:csindex

           #:bytes

           #:jenkins-hash))
