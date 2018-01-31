(in-package #:cstab)
(named-readtables:in-readtable rutilsx-readtable)


(defun make-simple-array (seq)
  (make-array (length seq) :element-type 'octet :initial-contents seq))

(deftest jenkins-hash ()
  (should be = 2013190661 2606614173 1810425290
          (jenkins-hash (make-simple-array #(#x73 #x75 #x64 #x64 #x69 #x76
                                             #x69 #x73 #x69 #x6F #x6E #x69))))
  (should be = 1051933682 2295921533 555313088
          (jenkins-hash (make-simple-array #(#x68 #x65 #x6c #x6c #x6f))))
  (should be = 1584301389 4045571276 2289236702
          (jenkins-hash (make-simple-array #()))))
