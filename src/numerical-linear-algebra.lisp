;;; -*- mode: lisp -*-

;;; Time-stamp: <2009-06-09 18:56:51 tony>
;;; Creation:   <2009-02-05 11:18:51 tony>
;;; File:       numerical.linear.algebra.lisp
;;; Author:     AJ Rossini <blindglobe@gmail.com>
;;; Copyright:  (c)2009--, AJ Rossini.  BSD, LLGPL, or GPLv2, depending
;;;             on how it arrives.  
;;; Purpose:    Lispy interface to factorization/decomposition,

;;; What is this talk of 'release'? Klingons do not make software
;;; 'releases'.  Our software 'escapes', leaving a bloody trail of
;;; designers and quality assurance people in its wake.

(in-package :lisp-matrix)

;;; Matrix Factorization for stable processing

;; current factorization types, only worried about "high-level"
;; descriptions, not further ramifications (size/spce considerations).

;; we have: SVD, LU, QR, Cholesky.
;; note that some are "special case only" factorizations.

(defclass matrix-factorized-results ()
  ((results
    :initarg :results
    :initform nil
    :reader results)
   (factorization-type
    :initarg :type
    :initform nil
    :reader factorization-type)))

(defgeneric factorized-matrix (a)
  (:documentation "Return the matrix (and not the structure).  The
    latter is the standard result from factorization routine. ")
  (:method ((a matrix-factorized-results))
    (ecase (factorization-type a)
      (:qr )
      (:lu )
      (:cholesky)
      (:svd)))
  (:method ((a matrix-like))
    (warn "Returning same matrix, assuming prior factorization.")))

(defgeneric factorize (a &key by)
  (:documentation "matrix decomposition, M -> SVD/LU/AtA etc.  
    FIXME: do we want a default type?   If BY is NIL then return A untouched.")
  (:method ((a data-frame-like) &key by)
    (factorize (data-frame-like->matrix-like a) :by by))
  (:method ((a matrix-like) &key (by :qr)) ;; is this the right way to get :qr as default?
    (make-instance 'matrix-factorized-results
		   :results (ecase by
			      (:qr (geqrf a))
			      (:lu (getrf a))
			      (:cholesky (potrf a))
			      (:svd (gesvf a))
			      (nil a))
		   :type by)))

(defgeneric invert (a &optional by)
  (:documentation "compute inverse of A using the appropriate factorization.")
  (:method ((a factorized-matrix-results) &optional by)
    (unless (equal by (factorization-by a))
      (warn "method to factor BY does not match FACTORIZATION-TYPE."))
    (let ((results (ecase (factorization-type a)
		     (:qr (geqri a) )
		     (:lu ( a))
		     (:cholesky (potri a))
		     (:svd (gesvi a))
		     (:otherwise
		      (error
		       "Unimplemented or not a proper factorized-matrix type."
		       (factor-type a))))))
      results))
  (:method ((a matrix-like) &optional by)
    (if (not by) (setf by :qr))
    (let ((results (ecase by
		     (:qr (minv-qr a) )
		     (:lu (minv-lu a))
		     (:cholesky (potri a))
		     (:svd (gesvi a))
		     (:otherwise
		      (error
		       "Unimplemented or not a proper factorized-matrix type."
		       (factor-type a))))))
      results)))


;;; [W|G]LS solutions

;; gelsy
;; gels

(defgeneric least-squares (y x &key w)
  (:documentation "Compute the (weighted/generalized) least-squares solution B to W(Y-XB)")
  (:method ((y vector-like) (x matrix-like) &key (w matrix-like) )
    (error "implement me!")))

;;; Eigensystems

(defgeneric eigensystems (x)
  (:documentation "Compute the eigenvectors and values of X.")
  (:method ((x matrix-like))
    (error "implement me!")))


;;; Optimization: should we put this someowhere else?  It is similar
;;; to Least Squares, which is one method for optimization, but is
;;; also similar to root-finding

(defgeneric optimize (f data params &key method maximize-p)
  (:documentation "given a function F, F(DATA,PARAMS), compute the
  PARAM values that optimize F for DATA, using METHOD, and maximize or
  minimize according to MAXIMIZE-P.")
  (:method ((f function) (data matrix-like) (params vector-like)
	    &key method maximize-p)
    (error "implement me!"))
  (:method ((f function) (data array) (params vector)
	    &key method maximize-p)
    (error "implement me!")))

(defgeneric root-find (f data params &key method)
  (:documentation "given a function F, F(DATA,PARAMS), compute PARAM
  such that with DATA, we use METHOD to solve F(DATA,PARAM)=0.")
  (:method ((f function) (data matrix-like) (params vector-like)
	    &key method)
    (error "implement me!"))
  (:method ((f function) (data array) (params vector)
	    &key method)
    (error "implement me!")))
