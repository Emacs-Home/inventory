
# Inventory Management in Org Mode

**Inventory Management in Org Mode** is an Emacs package that helps you efficiently track and manage household items such as groceries, medications, and other consumables using Org Mode.

## Features

- **Hierarchical Structure**: Organize your inventory into main categories and items.
- **Stock Tracking**:
  - **Current Stock**: Keep track of the number of items you have.
  - **Minimum Stock**: Set thresholds to receive warnings when stock is low.
  - **Maximum Stock**: Define target levels for restocking.

## Installation

You can install the package using `use-package`. Add the following to your Emacs configuration (`init.el`):

```elisp
(use-package inventory-management
  :load-path "~/.emacs.d/lisp/"  ;; Adjust the path to where you saved inventory-management.el
  :ensure nil
  :custom
  (my-inventory-org-file "~/Documents/inventory.org")  ;; Set your inventory Org file path
  :functions
  (my-inventory-add-new-main-category
   my-inventory-add-new-item
   my-inventory-update-stock-count
   my-inventory-check-stock-levels))
```

## Configuration

Customize the path to your inventory Org file through Emacs' Customize interface:

1. Press `M-x`, type `customize-group`, and press `Enter`.
2. Enter `my-inventory` and press `Enter`.
3. Set the **My Inventory Org File** to your desired path (e.g., `~/Documents/inventory.org`).
4. Click **Apply and Save**.

## Usage

### Available Functions

- **Add a New Main Category**
  
  ```elisp
  M-x my-inventory-add-new-main-category
  ```
  
  Prompts for:
  - Category name
  - Minimum stock level
  - Maximum stock level
  - Initial stock count

- **Add a New Item to an Existing Category**
  
  ```elisp
  M-x my-inventory-add-new-item
  ```
  
  Prompts for:
  - Main category name
  - Item name
  - Minimum stock level
  - Maximum stock level
  - Initial stock count

- **Update Stock Count for an Item**
  
  ```elisp
  M-x my-inventory-update-stock-count
  ```
  
  Prompts for:
  - Main category name
  - Item name
  - New stock count

- **Check Stock Levels**
  
  ```elisp
  M-x my-inventory-check-stock-levels
  ```
  
  Displays a temporary buffer `*Stock Alerts*` with items that are at or below their minimum stock levels.

## Org File Structure

Organize your `inventory.org` file as follows:

```org
* Groceries
** Milk
   :PROPERTIES:
   :MINIMUM: 2
   :MAX_STOCK: 5
   :END:
- Current stock: 3

** Bread
   :PROPERTIES:
   :MINIMUM: 1
   :MAX_STOCK: 3
   :END:
- Current stock: 1

* Medication
** Painkillers
   :PROPERTIES:
   :MINIMUM: 1
   :MAX_STOCK: 6
   :END:
- Current stock: 4
```

**Structure Details**:

- **Main Categories**: Single asterisk `*` (e.g., `* Groceries`).
- **Items**: Double asterisks `**` (e.g., `** Milk`).
- **Properties Drawer**: Contains `:MINIMUM:` and `:MAX_STOCK:`.
- **Current Stock**: Listed as a bullet point (e.g., `- Current stock: 3`).

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for enhancements or bug fixes.

