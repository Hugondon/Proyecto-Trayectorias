const path = require('path');
const admin = require('firebase-admin/app');
const serviceAccount = require(path.join(__dirname, 'firebase-secret-key.json'));

admin.initializeApp({
    credential: admin.cert(serviceAccount),
    storageBucket: 'gs://tlapixki.appspot.com'
});
