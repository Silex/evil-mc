;;; emc-region.el --- Visual region

;;; Commentary:

;; This file contains functions for creating a visual region for a fake cursor

(require 'emc-common)

;;; Code:

(defun emc-put-region-property (region &rest properties)
  "Return a new region that has one or more PROPERTIES
set to the specified values."
  (apply 'emc-put-object-property (cons region properties)))

(defun emc-get-region-property (region name)
  "Return the value of the property with NAME from REGION."
  (when region (emc-get-object-property region name)))

(defun emc-get-region-overlay (region)
  "Return the overlay from REGION."
  (emc-get-region-property region :overlay))

(defun emc-get-region-mark (region)
  "Return the mark from REGION."
  (emc-get-region-property region :mark))

(defun emc-get-region-point (region)
  "Return the point from REGION."
  (emc-get-region-property region :point))

(defun emc-get-region-visible-mark (region)
  "Return REGION's visible mark."
  (let ((overlay (get-region-overlay region)))
    (when overlay (overlay-get overlay mark))))

(defun emc-get-region-visible-point (region)
  "Return REGION's visible point."
  (let ((overlay (get-region-overlay region)))
    (when overlay (overlay-get overlay point))))

(defun emc-get-region-type (region)
  "Return the type from REGION."
  (emc-get-region-property region :type))

(defun emc-line-region-p (region)
  "True if REGION is of type line."
  (eq (emc-get-region-type region) 'line))

(defun emc-char-region-p (region)
  "True if REGION is of type char."
  (eq (emc-get-region-type region) 'char))

(defun emc-put-region-overlay (region overlay)
  "Return a new region with the overlay set to OVERLAY."
  (emc-put-region-property region :overlay overlay))

(defun emc-put-region-mark (region mark)
  "Return a new region with the mark set to MARK."
  (emc-put-region-property region :mark mark))

(defun emc-put-region-point (region point)
  "Return a new region with the point set to POINT."
  (emc-put-region-property region :point point))

(defun emc-put-region-type (region type)
  "Return a new region with the type set to TYPE."
  (emc-put-region-property region :type type))

(defun emc-get-pos-at-bol (pos)
  "Get the position at the beginning of the line with POS."
  (save-excursion (goto-char pos) (point-at-bol)))

(defun emc-get-pos-at-eol (pos)
  "Get the position at the end of the line with POS."
  (save-excursion (goto-char pos) (point-at-eol)))

(defun emc-calculate-region-bounds (prev-mark prev-point point)
  "Calculate new region bounds based on PREV-MARK PREV-POINT and current POINT."
  (let ((mark (or prev-mark prev-point)))
    (cond ((and (<= mark prev-point) (< point mark)) (setq mark (1+ mark)))
          ((and (< prev-point mark) (<= mark point)) (setq mark (1- mark))))
    (cond ((< mark point) (cons mark (1+ point)))
          ((< point mark) (cons mark point))
          (t (cons point (1+ (point)))))))

(defun emc-make-region-overlay (start end)
  "Make a visual region overlay from START to END."
  (let ((overlay (make-overlay start end nil nil nil)))
    (overlay-put overlay 'face 'emc-region-face)
    (overlay-put overlay 'priority 99)
    overlay))

(defun emc-char-region-overlay (mark point)
  "Make an overlay for a visual region of type char from MARK to POINT."
  (let* ((start (if (< mark point) mark point))
         (end (if (< mark point) point mark))
         (overlay (emc-make-region-overlay start end)))
    (overlay-put overlay 'mark mark)
    (overlay-put overlay 'point point)
    overlay))

(defun emc-line-region-overlay (mark point)
  "Make an overlay for a visual region of type line from MARK to POINT."
  (let* ((start-pos (if (< mark point) mark point))
         (end-pos (if (< mark point) point mark))
         (start-line (line-number-at-pos start-pos))
         (end-line (line-number-at-pos end-pos))
         (start (emc-get-pos-at-bol start-pos))
         (end (emc-get-pos-at-eol end-pos))
         (overlay (emc-make-region-overlay start end)))
    (overlay-put overlay 'mark (if (< mark point) start end))
    (overlay-put overlay 'point (if (< mark point) end start))
    overlay))

(defun emc-get-region-overlay (region)
  "Creates an overlay for REGION."
  (let ((mark (emc-get-region-mark region))
        (point (emc-get-region-point region)))
    (cond ((emc-char-region-p region)
           (emc-char-region-overlay mark point))
          ((emc-line-region-p region)
           (emc-line-region-overlay mark point)))))

;; TODO left here

(provide 'emc-region)

;;; emc-region.el ends here