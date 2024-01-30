# MonotoneCamApp

MonotoneCamApp is an iOS application developed using SwiftUI, designed to capture and process photos in monochrome. This simple yet powerful app allows users to take artistic monochrome photographs with their iOS device (iPhone or iPad) and save them directly to the camera roll.

## Features

1. **Real-Time Camera Preview**: Upon launching the app, users are presented with a live camera view, enabling them to frame their shots perfectly.
2. **Countdown Timer and Capture**: Features a shutter button that, when pressed, initiates a 3-second countdown followed by the automatic capture of a photo.
3. **Monochrome Photo Processing**: Automatically applies a monochrome filter to the captured photo, creating a unique aesthetic.
4. **Photo Saving**: The processed monochrome photo is saved directly to the device's camera roll.
5. **Photo Preview and Exit**: After a photo is captured, users can preview the monochrome photo and use an exit button to return to the main camera view.

## Screen Layout

The app consists of two main screens:
1. **Camera View Screen**: The primary screen after launching the app. It displays the camera's live preview and a shutter button. Pressing the shutter button leads to a 3-second countdown and then transitions to the photo preview screen.
2. **Photo Preview Screen**: Displays the captured monochrome photo and an exit button, which returns the user to the Camera View Screen.

## Setup

This project is developed with SwiftUI and requires Xcode 14.0 or later for building and running on iOS devices.

1. Clone the repository to your local machine.
2. Open `MonotoneCamApp.xcodeproj` with Xcode 14.0 or later.
3. Build and run the application on your iOS device.

## Usage

Launch the app to access the camera view. Use the shutter button to initiate the capture process with a 3-second countdown. The app captures a photo, applies a monochrome filter, and then displays it on the preview screen. The processed photo is saved to your camera roll, and you can return to the camera view by pressing the exit button on the preview screen.

## Requirements

- iOS 14.0 or later
- Xcode 14.0 or later

## License

This project is available under the MIT License. See the LICENSE file for more information.
