#ifndef FIREBASE_OPTIONS_H
#define FIREBASE_OPTIONS_H

#include "firebase/app.h"
#include "firebase/auth.h"
#include "firebase/firestore.h"

namespace firebase {
namespace app {
namespace options {
// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const char* const api_key = "YOUR_API_KEY";
const char* const auth_domain = "YOUR_PROJECT_ID.firebaseapp.com";
const char* const project_id = "YOUR_PROJECT_ID";
const char* const storage_bucket = "YOUR_PROJECT_ID.appspot.com";
const char* const messaging_sender_id = "YOUR_MESSAGING_SENDER_ID";
const char* const app_id = "YOUR_APP_ID";
}  // namespace options
}  // namespace app
}  // namespace firebase

#endif  // FIREBASE_OPTIONS_H
