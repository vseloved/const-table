(in-package #:cstab)
(named-readtables:in-readtable rutilsx-readtable)

(abbr make-cstab make-const-table)
(abbr build-cstab build-const-table)

(abbr cstab-data const-table-data)
(abbr cstab-meta const-table-meta)
(abbr cstab-gs const-table-gs)


(defgeneric bytes (k)
  (:documentation
   "Transform key K into a simple-array of octets.
    Called from internal function %BYTES for unknown key types."))
