import * as v2 from "firebase-functions/v2";
import * as admin from "firebase-admin";

export const profileOG = v2.https.onRequest(async (req, res) => {
  try {
    const username = req.path.split("/").pop();

    if (!username) {
      res.status(400).send("Bad request: missing username");
      return;
    }

    const snapshot = await admin
      .firestore()
      .collection("profiles")
      .doc(username)
      .get();

    if (!snapshot.exists) {
      res.status(404).send("Profile not found");
      return;
    }

    const profile = snapshot.data() as Profile;
    const desc = `View ${profile.username}'s profile on Golympians!`;

    res.set("Cache-Control", "public, max-age=600, s-maxage=600");
    res.send(`
<!DOCTYPE html>
<html>
<head>
  <title>${username} | Golympians</title>
  <meta property="og:title" content="${username} on Golympians" />
  <meta property="og:description" content="${desc}" />
  <meta property="og:image" content="${profile.photo_url}" />
  <meta property="og:type" content="profile" />
  <meta property="og:url" content="https://golympians.com/profiles/${username}" />
</head>
<body>
  <script>
    window.location.href = "/app/profile/${username}";
  </script>
</body>
</html>
`);
  } catch (error) {
    console.error("Error creating embed for profile!", error);
    res.status(500).send("Internal Server Error");
  }
});

export type Profile = {
  nickname: string;
  photo_path: string;
  photo_url: string;
  username: string;
  followers: string[];
  following: string[];
};
