require('./setup')
const { v4: uuidv4 } = require('uuid');

const { getStorage } = require('firebase-admin/storage');
const functions = require('firebase-functions');
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const { storage } = require('firebase-admin');
const app = express();

const storageRef = getStorage().bucket();

app.use(cors({
    origin: true,
}));
app.use(express.json())
function getRobotData(request, response) {
    let bucketName = "gs://tlapixki.appspot.com"
    // // I am using async/await here
   app.get("/download", async (req, res) => {

   // You have to wait till the file is downloaded
      await storage.bucket(bucketName).file("robot-data.json").download({destination: './robot-data.json'});
   // Send the file to the client
       //storageRef.download('./robot-data.json')
       //response.json({
       //    'Status Get': 'OK'
       //})


    });

}

function postRobotData(request, response) {
    const tmpFileName = 'file-' + new Date().toISOString() + '.json';

    fs.writeFile(
        '/tmp/' + tmpFileName,
        JSON.stringify(request.body),
        errWrite => {
            if (errWrite) {
                response.json({ status: 'error writing file' });
                return;
            }
            storageRef.upload('/tmp/' + tmpFileName, {
                    public: true,
                    destination: `robot-data.json`,
                    metadata: {
                        firebaseStorageDownloadTokens: uuidv4(),
                    }
                });
            response.json({
                "Status Post": "OK"
            })
        }
    );

}

app.get('/robot-data', getRobotData);
app.post('/robot-data', postRobotData);

exports.api = functions.https.onRequest(app);

