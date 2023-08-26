var CACHE_VERSION = 'v1';
var CACHE_NAME = CACHE_VERSION + ':sw-cache-';
var WEBPUSH_SERVICE_WORKER_SUBSCRIPTION_AUTH = '';


function onInstall(event) {
  // console.log('[Serviceworker]', "Installing!", event);
  WEBPUSH_SERVICE_WORKER_SUBSCRIPTION = '';
  event.waitUntil(
    caches.open(CACHE_NAME).then(function prefill(cache) {
      return cache.addAll([

        // make sure serviceworker.js is not required by application.js
        // if you want to reference application.js from here
        // '<%#= asset_path "application.js" %>',

        // '<%= asset_path "application.css" %>',

        '/offline.html',

      ]);
    })
  );
}

function onActivate(event) {
  // console.log('[Serviceworker]', "Activating!", event);
  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      return Promise.all(
        cacheNames.filter(function(cacheName) {
          // Return true if you want to remove this cache,
          // but remember that caches are shared across
          // the whole origin
          return cacheName.indexOf(CACHE_VERSION) !== 0;
        }).map(function(cacheName) {
          return caches.delete(cacheName);
        })
      );
    })
  );
}

// Borrowed from https://github.com/TalAter/UpUp
function onFetch(event) {
  event.respondWith(
    // try to return untouched request from network first
    fetch(event.request).catch(function() {
      // if it fails, try to return request from the cache
      return caches.match(event.request).then(function(response) {
        if (response) {
          return response;
        }
        // if not found in cache, return default offline content for navigate requests
        if (event.request.mode === 'navigate' ||
          (event.request.method === 'GET' && event.request.headers.get('accept').includes('text/html'))) {
          // console.log('[Serviceworker]', "Fetching offline content", event);
          return caches.match('/offline.html');
        }
      })
    })
  );
}

self.addEventListener('install', onInstall);
self.addEventListener('activate', onActivate);
self.addEventListener('fetch', onFetch);

self.addEventListener("push", (event) => {
  // console.log('event_push runned.');
  let ev_data = JSON.parse((event.data && event.data.text()) || "{}");
  let title = ev_data.title || "No title in message";
  let body = ev_data.body || "No body in message";
  let tag = ev_data.tag || "push-simple-notification-tag";
  let url = ev_data.url || "";
  let icon = '/pics/smile_192_192.png';
  let msg_data = { body: body, icon: icon, tag: tag, data: { url: url, id: ev_data.id } };
  // console.log('push listener msg_data=', msg_data);
  event.waitUntil(
    self.registration.showNotification(title, msg_data)
  )
});

self.addEventListener('notificationclick', function(event) {
  event.notification.close();
  event.waitUntil(
    clients.openWindow(event.notification.data.url + "?notification_id=" + event.notification.data.id)
  );
});

