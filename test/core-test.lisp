(in-package #:cstab)
(named-readtables:in-readtable rutilsx-readtable)


(deftest build-cst ()
  (with ((ht (pairs->ht (loop :repeat 1000
                              :collect (pair (princ-to-string
                                              (random most-positive-fixnum))
                                             (random most-positive-fixnum)))
                        :test 'equal))
         (cst (build-cst ht)))
    (dotable (k v ht)
      (should be = v (cst-get k cst)))))
