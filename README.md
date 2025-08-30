Chat UI Application
Project Overview
This project is a mobile-first chat application UI built using Flutter. The primary goal was to create a robust and user-friendly messaging interface that handles common mobile UI challenges, specifically the screen resizing that occurs when the virtual keyboard appears.

Key Features & Accomplishments
Responsive UI: The application's layout dynamically adjusts to the presence of the virtual keyboard, preventing screen overflow errors and ensuring a smooth user experience.

Dynamic Message Display: The user interface efficiently displays a list of messages using a ListView.builder, which is a memory-efficient solution for handling potentially long lists of chat messages.

Custom Message Bubbles: The UI includes custom-styled chat bubbles that are aligned to the left or right based on the sender, providing a familiar and intuitive chat aesthetic.

Auto-Scroll Functionality: New messages are automatically scrolled into view, allowing the user to always see the latest content in the conversation.

How to Run the Application
This project is a standard Flutter application. To run it on your local machine, follow these steps:

Clone the Repository:

git clone [your_repository_url]

Navigate to the Project Directory:

cd [your_project_directory]

Get Dependencies:
Make sure you have Flutter installed and configured. Then, run the following command to install the project dependencies:

flutter pub get

Run the Application:
Launch the app on an emulator, simulator, or a connected physical device:

flutter run

Project Structure
lib/main.dart: The main entry point of the application, containing the core UI logic for the chat screen.