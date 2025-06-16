# laundry_os

# Laundry POS Flutter App with Sunmi Integration

A Flutter-based Point of Sale (POS) application designed for laundry services, integrated with Sunmi devices for seamless order management, pricing, and receipt printing.

## Features

- Select services: Wash, Iron, or Both
- Add multiple clothing items per order
- Real-time order syncing with Firebase Firestore
- Supports multiple languages (English, Hindi, Arabic)
- Print receipts twice: customer and shop copies using Sunmi printer
- Simple and intuitive UI for quick order processing
- Secure and reliable backend with Firebase

## Tech Stack

- Flutter (Dart)
- Firebase Firestore for backend database
- Sunmi printer integration via `sunmi_printer_plus` package
- State management with Provider (or your chosen method)

## Getting Started

### Prerequisites

- Flutter SDK installed
- Sunmi device for testing printing functionality
- Firebase project set up and connected (includes `firebase_options.dart`)

### Installation

1. Clone the repo:
   ```bash
   git clone https://github.com/yourusername/yourrepo.git
