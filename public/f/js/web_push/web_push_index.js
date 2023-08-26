var webpush_workerFileName = '/serviceworker3.js?v=1';

function is_vapid_key_present() { return ($('#webpush_vapid_public_key').length > 0) ? true : false; }

$(document).ready(function () {
  // console.log('ready web_push_index started here!');
  if (is_vapid_key_present()) {
    run_init_webpush_service_worker_and_subscribe();
  }
});



function run_init_webpush_service_worker_and_subscribe() {
  navigator.serviceWorker.register(webpush_workerFileName, {scope: '/'}).then(function (reg) {
    var serviceWorker;
    if (reg.installing) {
      serviceWorker = reg.installing;
      // console.log('Service worker installing');
    } else if (reg.waiting) {
      serviceWorker = reg.waiting;
      // console.log('Service worker installed & waiting');
    } else if (reg.active) {
      serviceWorker = reg.active;
      // console.log('Service worker active');
    }

    if (serviceWorker) {
      // console.log("sw current state", serviceWorker.state);
      if (serviceWorker.state == "activated") {
        //If push subscription wasnt done yet have to do here
        // console.log("sw already activated - Do watever needed here");
        subscribeForPushNotification(reg);
      }
      serviceWorker.addEventListener("statechange", function(e) {
        // console.log("sw statechange : ", e.target.state);
        if (e.target.state == "activated") {
          // use pushManger for subscribing here.
          // console.log("Just now activated. now we can subscribe for push notification")
          subscribeForPushNotification(reg);
        }
      });
    }
  }, function (err) {
    console.error('unsuccessful registration with ', webpush_workerFileName, err);
  });
}

function subscribeForPushNotification(onSubscribed) {
  // console.log("started subscribeForPushNotification reg=", reg);
  // let onSubscribed = null;
  // getSubscription().then((subscription) => {
  //   log_subscription(000002, subscription);
  // });
  // return false;
  if (!window.PushManager) {
    console.warn('Push messaging is not supported in your browser');
  }

  if (!ServiceWorkerRegistration.prototype.showNotification) {
    console.warn('Notifications are not supported in your browser');
    return;
  }

  if (Notification.permission !== 'granted') {
    Notification.requestPermission(function (permission) {
      // If the user accepts, let's create a notification
      if (permission === "granted") {
        console.log('Permission to receive notifications just granted!');
        subscribe(onSubscribed);
      }
    });
    return;
  } else {
    // console.log('Permission to receive notifications granted!');
    subscribe(onSubscribed);
  }
}



function subscribe(onSubscribed) {
  // let onSubscribed = null;
  // console.log('subscribe runned.');
  navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
    const pushManager = serviceWorkerRegistration.pushManager;
    // console.log('serviceWorker ready pushManager=', pushManager);
    pushManager.getSubscription().then((subscription) => {
      log_subscription(111222, subscription);
      // console.log('pushManager subscription=', subscription);
      if (subscription) {
        // refreshSubscription(pushManager, subscription, onSubscribed);
        run_post_request_with_webpush_subscription_info();
      } else {
        pushManagerSubscribe(pushManager, onSubscribed);
      }
    })
  });
}

function refreshSubscription(pushManager, subscription, onSubscribed) {
  // console.log('Refreshing subscription');
  return subscription.unsubscribe().then((bool) => {
    pushManagerSubscribe(pushManager);
  });
}

function pushManagerSubscribe(pushManager, onSubscribed) {
  // console.log('Subscribing started...');
  // return false;

  pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: new Uint8Array($('#webpush_vapid_public_key').attr('value').split(','))
  }).then(onSubscribed).then(() => {
    // console.log('Subcribing finished: success!');
    run_demo_push();
    run_post_request_with_webpush_subscription_info();
  }).catch((e) => {
    if (Notification.permission === 'denied') {
      console.warn('Permission to send notifications denied');
    } else {
      console.error('Unable to subscribe to push', e);
    }
  });
}

function logSubscription(subscription) {
  console.log("Current subscription", subscription.toJSON());
}

function getSubscription() {
  return navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
    return serviceWorkerRegistration.pushManager.getSubscription().catch((error) => {
      console.warn('Error during getSubscription()', error);
    });
  });
}

function get_authenticity_token() { return $('footer input[name="authenticity_token"]').attr('value'); }
function run_demo_push() {
  return false;
  console.log('demo_push started');
  navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
    serviceWorkerRegistration.pushManager.getSubscription().then((subscription) => {
      console.log('runned with subscription=', subscription);
      let fdata = { authenticity_token: get_authenticity_token(), subscription: subscription.toJSON() };
      $.post({ url: '/demo_push', dataType: "json", data: fdata, cache: false,
        success: function(res) {
          console.log('demo_push success res=', res, " this=", this);
        },
        error: function(res) {
          console.error('demo_push fail res=', res);
        }
      });
    });
  });
  return false;
}

function is_subscription_new_and_need_post_for_store(subscription_auth_str) {
  let auth_arr = JSON.parse($('#user_subscriptions_auths').attr('value'));
  // console.log('subscription_auth_str=', subscription_auth_str, ' current auth_arr=', auth_arr);
  let result = true;
  auth_arr.forEach(function(el) {
    if (el == subscription_auth_str) result = false;
  });
  return result;
}

function run_post_request_with_webpush_subscription_info() {
  // return false;
  // console.log('run_post_request_with_webpush_subscription_info');
  navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
    serviceWorkerRegistration.pushManager.getSubscription().then((subscription) => {
      log_subscription(432234, subscription);
      let subs_data = subscription.toJSON();
      // console.log('runned run_post_request_with_webpush_subscription_info with subs_data=', subs_data, 'subscription=', subscription);
      if (is_subscription_new_and_need_post_for_store(subs_data.keys.auth)) {
        let fdata = { authenticity_token: get_authenticity_token(), subscription: subscription.toJSON() };
        $.post({ url: '/profile/subscribe_notifications', dataType: "json", data: fdata, cache: false,
          success: function(res) {
            // console.log('run_post_request_with_webpush_subscription_info success res=', res, " this=", this);
          },
          error: function(res) {
            console.error('run_post_request_with_webpush_subscription_info fail res=', res);
          }
        });
      } else {
        // console.log('key already subscribed.');
      }
    });
  });
  return false;
}


function log_subscription(indx, subscription) {
  // let subs_data = (subscription) ? subscription.toJSON() : {};
  // console.log('runned log_subscription[' + indx + '] subs_data=', subs_data.keys);
}
