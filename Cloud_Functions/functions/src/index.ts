/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as admin from "firebase-admin";
admin.initializeApp();

export * from "./handlers/onUserWorkoutCreate";
export * from "./handlers/onActivitySetUpdate";
export * from "./handlers/onActivityCreated";
export * from "./scheduled/scheduledInsightCreation";
