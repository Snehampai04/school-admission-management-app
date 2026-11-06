\# School Admission Management App



\## Project Overview

A Flutter-based School Admission Management Application developed using Firebase, Cloud Firestore, and BLoC architecture.



The application allows parents to register, submit student admission applications, make or skip registration fee payments, and book entrance examination slots. Administrators can manage applications, examination slots, scores, course assignments, and admission completion.



\## Technologies Used

\- Flutter and Dart

\- Firebase Authentication

\- Cloud Firestore

\- Flutter BLoC

\- GoRouter

\- Equatable



\## User Roles



\### Parent

\- Register and log in.

\- Submit student admission applications.

\- View submitted applications.

\- Pay or skip the registration fee.

\- Book available examination slots.

\- View examination booking details and results.

\- View assigned course and admission status.



\### Admin / Admission Team

\- Log in to the admin dashboard.

\- View and manage applications.

\- Approve or reject applications.

\- Create and manage examination slots.

\- View examination bookings.

\- Enter examination scores.

\- Assign courses.

\- Complete admissions.



\## Key Features

\- Firebase authentication and session management.

\- Role-based navigation.

\- Firestore database integration.

\- Examination slot booking with capacity validation.

\- Prevention of duplicate bookings.

\- Mock registration fee payment.

\- Examination score and result management.

\- Course assignment and admission completion.



\## Project Architecture

The application follows a feature-based structure with BLoC state management.



\## How to Run



1\. Clone the repository.

2\. Open the project folder.

3\. Run:



```bash

flutter pub get

```



4\. Configure Firebase for your environment.

5\. Run:



```bash

flutter run

```



\## Build APK



```bash

flutter build apk --release

```



APK location:



`build/app/outputs/flutter-apk/app-release.apk`



\## Testing

\- Flutter Analyze: No issues found.

\- Flutter Tests: All 12 tests passed.

\- Manual Android testing: Completed successfully.



\## Payment Note

The application uses mock registration fee payment functionality. It does not process real financial transactions.



\## Future Improvements

\- Real payment gateway integration.

\- Push notifications.

\- Enhanced reporting and analytics.

\- iOS deployment.

