(in-package #:cstab)
(named-readtables:in-readtable rutilsx-readtable)


(deftest acyclic? ()
  (should be true (acyclic? 3 '((0 . 1) (1 . 2))))
  (should be null (acyclic? 2 '((0 . 1) (1 . 0))))
  (should be null (acyclic? 2 '((0 . 1) (1 . 1))))
  (should be true (acyclic? 7 '((0 . 1) (0 . 2) (1 . 3) (1 . 4) (2 . 5) (5 . 6))))
  (should be null (acyclic? 7 '((0 . 1) (0 . 2) (1 . 3) (1 . 4) (2 . 5) (5 . 6)
                                (4 . 6))))
  (should be null (acyclic? 6 '((1 . 2) (2 . 3) (2 . 4) (4 . 5) (0 . 3) (4 . 0)
                                (5 . 0)))))
