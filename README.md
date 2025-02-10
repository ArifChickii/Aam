# AAM Marketplace

AAM Marketplace is an iOS marketplace application where users can add, browse, purchase, and manage products such as clothes and other fashion items. The app provides a full-featured user experience, including product listings, detailed product views, cart and checkout processes, user authentication, and profile management.

> **Note:**  
> This project integrates advanced functionalities such as payment processing and push notifications. Detailed implementations for payment and push notifications are provided below.

---

## Table of Contents

- [Features](#features)
- [Payment Functionality](#payment-functionality)
- [Push Notification Functionality](#push-notification-functionality)
- [Other Functionalities](#other-functionalities)
- [Installation & Setup](#installation--setup)
- [How to Add the README File](#how-to-add-the-readme-file)
- [Contact](#contact)
- [License](#license)

---

## Features

- **Marketplace**  
  Users can browse, add, and purchase products such as clothes and accessories.
  
- **User Authentication**  
  Secure login and registration via email, Google, and Apple authentication.  
  Includes email linking and social authentication.

- **Product Management**  
  Add, fetch, update, and delete products. Detailed product views with images, description, pricing, and more.

- **Cart & Order**  
  Users can add products to a cart, view a detailed cart, and complete orders with order calculation logic.

- **Shipping Addresses**  
  Management of multiple shipping addresses with default address selection.

- **Profile & Settings**  
  Users can update their profile, view settings, and log out.

- **Push Notifications**  
  In-app push notifications are configured and ready to test.  
  *Push notifications are triggered when a user taps the like button on a product.*

- **Payment Processing**  
  Complete payment functionality is implemented including payment intent creation, merchant and purchaser creation, and order creation in Firebase.

---

## Payment Functionality

The payment flow is built into the app with the following major steps:

1. **Create Payment Intent (App Side):**  
   The process starts by creating a payment intent on the app. This is the entry point for all payment-related actions.  
   *Note: You need to update the payment functionality starting from the “create payment intent” step, as this is the point where payment processing is initiated.*

2. **Create Merchant & Purchaser:**  
   Once the payment intent is created, the app proceeds to create a merchant and a purchaser.  
   This involves securely storing and processing payment-related information in Firebase.

3. **Order Creation in Firebase:**  
   After successful payment processing, the order is created and stored in Firebase.  
   The order includes details such as products purchased, payment details, and shipping information.

All these payment steps are fully integrated into the app. To update the functionality, start from the create payment intent logic on the app side.

---

## Push Notification Functionality

The push notification functionality is designed to notify product sellers when their product is liked or unliked. The key points are:

1. **Configuration:**  
   - All Firebase push notification configurations are completed.
   - The app is configured to request notification permissions from the user.
   - Device FCM tokens are stored in Firestore under the respective user’s document.

2. **Triggering Notifications:**  
   - When a user taps the like button on a product, the app triggers a push notification.
   - The notification (with appropriate message such as “_John has liked your product T-Shirt_”) is sent to the seller of that product.
   - Similarly, when a product is unliked, a corresponding notification is sent.

3. **Implementation Details:**  
   - All code and API calls for sending push notifications are implemented.
   - **Important:** The backend API for sending push notifications still needs to be developed. Once developed, you only need to replace the base URL in the app and handle the API response.
   - The logic for displaying notifications (reading from Firestore and showing a list in the notifications screen) is also fully implemented and ready to be tested.

---

## Other Functionalities

Apart from the two major areas above, the following modules are complete and fully functional:

- **Home Screen:**  
  Displays product listings with full filtering and search options.

- **Add Product:**  
  Allows users to add new products to the marketplace.

- **Product Detail:**  
  Detailed view for each product.

- **Cart:**  
  Add-to-cart functionality and complete cart management.

- **Settings & Profile:**  
  Manage user profile, update settings, and handle logout operations.

- **Authentication:**  
  All authentication flows, including email linking, social login, and notification permissions.

- **Shipping Address Management:**  
  Add, update, and delete shipping addresses.

- **Order Calculations:**  
  Integrated logic for calculating order totals and processing orders.

---

## Installation & Setup

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/AAM-Marketplace.git
   cd AAM-Marketplace
## Contact Info

If you have any questions or need further assistance, please feel free to contact:
Email: arifnaveed1997@gmail.com
WhatsApp: +923135438268


