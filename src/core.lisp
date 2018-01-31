(in-package #:cstab)
(named-readtables:in-readtable rutilsx-readtable)

(declaim (optimize (speed 3) (safety 1)))


(defstruct const-table
  (data nil :type simple-vector)
  (gs nil :type (simple-array octet))
  (meta nil :type (simple-array quad)))

(defparameter *g-scale* 2)

(defun build-const-table (tab &key (ratio 200))
  "Create a new const-table from an alist or a hash-table TAB
   with an average number of keys per bucket RATIO."
  (declare (type quad ratio))
  (with ((count (tally tab))
         (mod (ceiling (the quad count) ratio))
         (buckets #h())
         (descs (make-array mod))
         (data (make-array count))
         (gs (make-array (* *g-scale* count) :element-type 'octet))
         (rez (make-const-table
               :data data
               :gs gs
               :meta (make-array (1+ (* 2 mod)) :element-type 'quad)))
         (off 0)
         (cc 0)
         (pct (ceiling mod 100)))
    (dotable (k _ tab)
      (with ((bytes (%bytes k))
             (bucket-key (mod (jenkins-hash bytes) mod))
             (bucket (getsethash bucket-key buckets #h(equalp))))
        (when-it (? bucket bytes)
          (warn "Duplicate bytes when adding key ~A to perfect hash-table.
Same bytes for key(s): ~{~A ~}"
                k it))
        (push k (? bucket bytes))))
    (dotable (bucket-key vals buckets)
      (block 1bucket
        (when (zerop (rem (:+ cc) pct)) (princ "."))
        (let ((m (* *g-scale* (tally vals))))
          (loop
            (with ((seed (random #xffffffff))
                   (es (loop :for bytes :being :the :hash-keys :of vals
                             :collect (with ((b c (jenkins-hash2 bytes seed m)))
                                        (cons b c)))))
              (when (acyclic? m es)
                (return-from 1bucket
                  (:= (? descs bucket-key) (list seed
                                                 (calc-g m es))))))))))
    (dotimes (bucket-key (length descs))
      (with (((seed g) (? descs bucket-key))
             (meta-key (* 2 bucket-key))
             (goff (* *g-scale* off)))
        (:= (? rez 'meta meta-key) off
            (? rez 'meta (1+ meta-key)) seed)
        (dotable (off2 val g)
          (:= (aref gs (+ goff off2)) val)))
      (:+ off (tally (? buckets bucket-key))))
    ;; add final offset to avoid unnecessary boundary checks in CINDEX
    (:= (? rez 'meta (* 2 (length descs))) off)
    (dotable (k v tab)
      (:= (svref data (csindex (%bytes k) rez)) v))
    rez))

(defun csindex (bytes cstab)
  "Get an expected index of a KEY in const-table CSTAB.
   NB. If a key is not present in the table, an index is still calculated,
   while other means should be used to check for key's presence."
  (with ((gs (const-table-gs cstab))
         (meta (const-table-meta cstab))
         (mod (ash (1- (length meta)) -1))
         (hash (ash (mod (jenkins-hash bytes) mod) 1))
         (off (aref meta hash))
         (seed (aref meta (1+ hash)))
         (mod2 (- (aref meta (+ 2 hash)) off))
         (b c (jenkins-hash2 bytes seed (ash mod2 1)))  ; (* *g-scale* mod2)
         (goff (ash off 1)))
    (+ off (mod (+ (aref gs (+ goff b))
                   (aref gs (+ goff c)))
                mod2))))
    
(defun csget (key cstab)
  "Retrieve a KEY from a cosntant-table CSTAB."
  (svref (const-table-data cstab)
         (csindex (%bytes key) cstab)))

(defun %bytes (k)
  "Transform key K into a simple-array of octets."
  (typecase k
    (string (babel:string-to-octets k))
    (bit-vector (bitsmash:bits->octets k))
    (integer (bitsmash:int->octets k))
    (otherwise (bytes k))))

  
