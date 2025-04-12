# golden_bowl_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application. This project aims to provide a smoother experience for a restaurant owner to manage their hierarchical sturcturs and mainly focusing on greater experience for the customers 

This app has some functionalities such as menu view.
Here are a few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 🍲 OrdersPage - Golden Bowl Admin App

This Flutter screen allows admins to view and manage customer orders from the **Golden Bowl** backend API. It fetches order data, displays it in a user-friendly UI, and allows updating order statuses (Confirm or Cancel).

---

## 🚀 Features

- Fetch orders from REST API (`https://golden-bowl-server.vercel.app/orders`)
- Display each order with:
  - Order ID
  - Items
  - Total price
  - Status (with color indicators)
- Update order status to:
  - ✅ `completed`
  - ❌ `canceled`
- Re-fetches order list after each status update
- Responsive UI with loading and error handling

---

## 📦 Dependencies

- [`http`](https://pub.dev/packages/http): For making network requests.
- [`flutter/material.dart`](https://api.flutter.dev/flutter/material/material-library.html): Flutter's core UI toolkit.

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.14.0
```

## 🛠️ How It Works

    On screen load, it fetches orders from the API.

    Displays each order in a styled card with all relevant info.

    If an order is pending, shows Confirm and Cancel buttons.

    Updates the order status on button tap and shows a Snackbar.

    Reloads the updated order list automatically.

## 🧪 Sample API Response

[
  {
    "_id": "12345",
    "items": [
      { "name": "Chicken Biryani" },
      { "name": "Mango Lassi" }
    ],
    "totalPrice": 12.99,
    "status": "pending"
  }
]

## 📂 File Structure

lib/

└── orders.dart  # Main OrdersPage UI & logic


## 🧑‍💻 Author

Golden Bowl Flutter Dev Team


## 📜 License

This project is licensed for educational or internal business use only. Contact the owner for reuse or distribution.
