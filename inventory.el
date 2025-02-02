;;; inventory.el --- Manage inventory in org mode    -*- lexical-binding: t; -*-
;;; Commentary:
;; Copyright (C) 2025  Tara Druffel


;; Author: Taradruffel
;; Version: 20250202.1129

;; Author: Tara Druffel <taradruffel@localhost>
;; Keywords: Inventory
;;; Code:

;; Define a customizable variable for the inventory Org file
(defgroup inventory nil
  "Customize settings for the inventory management system."
  :prefix "inventory-"
  :group 'applications)

(defcustom inventory-org-file "~/org/inventory.org"
  "Path to the Org file used for inventory management."
  :type 'file
  :group 'inventory)

(defun inventory-add-new-item (main-category item-name min-stock max-stock initial-stock)
  "Add a new ITEM-NAME under MAIN-CATEGORY with specified MIN-STOCK, MAX-STOCK, and INITIAL-STOCK."
  (interactive
   (list
    (read-string "Enter main category name: ")
    (read-string "Enter item name: ")
    (read-number "Enter minimum stock level: ")
    (read-number "Enter maximum stock level: ")
    (read-number "Enter initial stock count: ")))
  (with-current-buffer (find-file-noselect inventory-org-file)
    (org-mode)
    (goto-char (point-min))
    ;; Search for the main category
    (if (re-search-forward (format "^* %s$" (regexp-quote main-category)) nil t)
        (progn
          ;; Move to the end of the main category
          (goto-char (org-end-of-subtree t t))
          ;; Insert the new item
          (unless (bolp)
            (insert "\n"))
          (insert (format "** %s\n" item-name))
          (insert "   :PROPERTIES:\n")
          (insert (format "   :MINIMUM: %d\n" min-stock))
          (insert (format "   :MAX_STOCK: %d\n" max-stock))
          (insert "   :END:\n")
          (insert (format "- Current stock: %d\n" initial-stock))
          ;; Save the buffer to write changes to the file
          (save-buffer)
          (message "Item '%s' added under '%s' in %s." item-name main-category inventory-org-file))
      (message "Main category '%s' not found in %s." main-category inventory-org-file))))

(defun inventory-update-stock-count (main-category item-name new-count)
  "Update the current stock count of ITEM-NAME under MAIN-CATEGORY to NEW-COUNT."
  (interactive
   (list
    (read-string "Enter main category name: ")
    (read-string "Enter item name to update: ")
    (read-number "Enter new stock count: ")))
  (with-current-buffer (find-file-noselect inventory-org-file)
    (org-mode)
    (goto-char (point-min))
    ;; Search for the main category
    (if (re-search-forward (format "^* %s$" (regexp-quote main-category)) nil t)
        (let ((main-end (org-end-of-subtree t t)))
          ;; Search for the specific item within the main category
          (if (re-search-forward (format "^** %s$" (regexp-quote item-name)) main-end t)
              (let ((item-end (org-end-of-subtree t t)))
                ;; Search for the current stock line within the item
                (if (re-search-forward "^- Current stock: \\([0-9]+\\)$" item-end t)
                    (progn
                      (replace-match (format "- Current stock: %d" new-count))
                      (save-buffer)
                      (message "Updated '%s' stock to %d." item-name new-count))
                  (message "Current stock line not found for item '%s' under '%s'." item-name main-category)))
            (message "Item '%s' not found under main category '%s'." item-name main-category)))
      (message "Main category '%s' not found in %s." main-category inventory-org-file))))

(defun inventory-add-new-main-category (category min-stock max-stock initial-stock)
  "Add a new MAIN CATEGORY to the inventory with specified MIN-STOCK, MAX-STOCK, and INITIAL-STOCK for its first item."
  (interactive
   (list
    (read-string "Enter main category name: ")
    (read-number "Enter minimum stock level: ")
    (read-number "Enter maximum stock level: ")
    (read-number "Enter initial stock count for the first item: ")))
  (with-current-buffer (find-file-noselect inventory-org-file)
    (org-mode)
    (goto-char (point-max))
    ;; Ensure there's a newline before adding a new entry
    (unless (bolp)
      (insert "\n"))
    ;; Insert the new main category and its first item
    (insert (format "* %s\n" category))
    (insert "** Default Item\n")
    (insert "   :PROPERTIES:\n")
    (insert (format "   :MINIMUM: %d\n" min-stock))
    (insert (format "   :MAX_STOCK: %d\n" max-stock))
    (insert "   :END:\n")
    (insert (format "- Current stock: %d\n" initial-stock))
    ;; Save the buffer to write changes to the file
    (save-buffer))
  (message "Main category '%s' added successfully to %s." category inventory-org-file))

(defun inventory-check-stock-levels ()
  "Check stock levels in the inventory org file and display alerts in a temporary buffer if any item is at or below its minimum."
  (interactive)
  (with-current-buffer (find-file-noselect inventory-org-file)
    (org-mode)
    (goto-char (point-min))
    (let (alerts)  ;; Initialize alerts as an empty list
      ;; Iterate through each main category
      (while (re-search-forward "^* \\(.+\\)$" nil t)
        (let ((main-category (match-string 1))
              min max current)
          ;; Define the end of the main category's subtree
          (let ((main-end (org-end-of-subtree t t)))
            ;; Iterate through each item within the main category
            (save-excursion
              (goto-char (match-end 0))
              (while (re-search-forward "^** \\(.+\\)$" main-end t)
                (let ((item-name (match-string 1)))
                  ;; Retrieve :MINIMUM:
                  (if (re-search-forward "^   :MINIMUM: \\([0-9]+\\)" main-end t)
                      (setq min (string-to-number (match-string 1)))
                    (setq min 0)) ;; Default if not found
                  ;; Retrieve :MAX_STOCK:
                  (if (re-search-forward "^   :MAX_STOCK: \\([0-9]+\\)" main-end t)
                      (setq max (string-to-number (match-string 1)))
                    (setq max nil)) ;; Not used here
                  ;; Retrieve Current stock
                  (if (re-search-forward "^- Current stock: \\([0-9]+\\)$" main-end t)
                      (setq current (string-to-number (match-string 1)))
                    (setq current 0)) ;; Default if not found
                  ;; Check if current stock is at or below minimum
                  (when (and (numberp current) (numberp min) (<= current min))
                    (push (format "Stock alert: %s > %s has only %d items left, at or below the minimum of %d."
                                  main-category item-name current min) alerts))))))))
      ;; Display alerts in a temporary buffer
      (if alerts
          (let ((buffer (get-buffer-create "*Stock Alerts*")))
            (with-current-buffer buffer
              (read-only-mode -1)  ;; Disable read-only to allow writing
              (erase-buffer)        ;; Clear previous contents
              (insert (format "Stock Alerts for %s:\n\n" (file-name-nondirectory inventory-org-file)))
              (dolist (alert (reverse alerts))
                (insert (format "- %s\n" alert)))
              (read-only-mode 1))    ;; Re-enable read-only
            (display-buffer buffer))
        (message "All stock levels are above their minimums.")))))

(provide 'inventory)
;;; inventory.el ends here
