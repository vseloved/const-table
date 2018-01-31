(in-package #:cstab)
(named-readtables:in-readtable rutilsx-readtable)


(defun acyclic? (m es)
  "Check if a graph ES (represented as an edges alist)
    with M vertexes is acyclic."
  (when (notany ^(= (car %) (cdr %)) es)
    (let ((subsets (make-array m :initial-element nil))
          (i -1))
      (loop :for (v1 . v2) :in es :do
        (when (and (? subsets v1)
                   (eql (? subsets v1)
                        (? subsets v2)))
          (return-from acyclic? nil))
        (cond-it
          ((? subsets v1)
           (when-let (s2 (? subsets v2))
             (dotimes (v m)
               (when (eql s2 (? subsets v))
                 (:= (? subsets v) it))))
           (:= (? subsets v2) it))
          ((? subsets v2)
           (:= (? subsets v1) it))
          (t
           (:= (? subsets v1)
               (:= (? subsets v2)
                   (:+ i))))))
      t)))

(defun sorted-cons (x)
  "Sort a cons cell X in ascending order."
  (if (< (car x) (cdr x))
      x
      (cons (cdr x) (car x))))

(defun calc-g (m es)
  "Calculate the table for the function g for the graph ES
   (represented as an edges alist) with M vertexes."
  (let ((h (pairs->ht (mapindex ^(pair (sorted-cons %%) %)
                                es)
                      :test 'equalp))
        (gr #h())
        (g #h())
        (visited #h()))
    (dotimes (v m)
      (:= (? g v) 0))
    (loop :for (u . v) :in es :do
      (push v (? gr u))
      (push u (? gr v)))
    (dotable (v _ gr)
      (unless (? visited v)
        (assign v g h gr visited)))
    ;; sanity check
    (let ((f #h()))
      (loop :for (b . c) :in es :do
        (:+ (get# (mod (+ (? g b) (? g c))
                       (tally h))
                  f 0)))
      (dotimes (i (tally f))
        (assert (= (get# i f 1) 1)
                () "Calculated function G is not a bijection!")))
    g))

(defun assign (u g h gr visited)
  "The edge assignment step of the MPH algorithm."
  (:= (? visited u) t)
  (dolist (v (? gr u))
    (unless (? visited v)
      (:= (? g v) (mod (- (? h (sorted-cons (cons u v)))
                          (? g u))
                       (tally h)))
      (assign v g h gr visited))))
