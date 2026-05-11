importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyCwZYDuc3L9eTTsWdRxLno34nI205v7Eas",
  authDomain: "anythingz-96d30.firebaseapp.com",
  projectId: "anythingz-96d30",
  storageBucket: "anythingz-96d30.firebasestorage.app",
  messagingSenderId: "639107211605",
  appId: "1:639107211605:web:926dac89ef9790ede74fdc",
  measurementId: "G-XYK8MCZMD1"
});
// databaseURL: "https://ammart-8885e-default-rtdb.firebaseio.com",

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});