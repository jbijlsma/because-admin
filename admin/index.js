const admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.cert("./serviceAccountKey.json"),
  databaseURL: "https://<project-id>.firebaseio.com/",
});

const uid = "dI7YPjR8M3d5Y17xOTRPqcuAjWw2";

admin
  .auth()
  .setCustomUserClaims(uid, { waiverAdmin: true })
  .then(() => {
    // The new custom claims will propagate to the user's ID token the
    // next time a new one is issued.
    console.log(`waiverAdmin claim added to ${uid}`);

    admin
      .auth()
      .getUser(uid)
      .then((user) => {
        console.log(user.customClaims);
      });
  });
