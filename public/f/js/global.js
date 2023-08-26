
const js_sleep_in_this_thread = (milliseconds) => { return new Promise(resolve => setTimeout(resolve, milliseconds)); }
function js_sleep(ms) { ms += new Date().getTime(); while (new Date() < ms){}; }

$(document).on('show.bs.modal', '.modal', function () {
    var zIndex = 1040 + (10 * $('.modal:visible').length);
    $(this).css('z-index', zIndex);
    setTimeout(function() {
        $('.modal-backdrop').not('.modal-stack').css('z-index', zIndex - 1).addClass('modal-stack');
    }, 0);
});

$(document).on('hidden.bs.modal', '.modal', function () {
  // console.log('TMP LOG 12331231222 hidden.bs.modal!');
  store_opened_modals_in_url_hash();
  $('.modal:visible').length && $(document.body).addClass('modal-open');
});



$(document).ready(function() {
  var EACH_5_SECONDS_TIMER = setInterval(function() {
    if (!($('body').attr('dev') > 1)) { // Turned off on dev
      $('.modal.show .each_5_seconds_btn[already_runned="0"]').each(function (i) { $(this).click(); });
    }
  } , 5000);
});



function confirm2_success_clicked(elem) {
  let $d = $(elem).closest('.modal');
  let func_name = $d.attr('func_name');
  let params_arr = JSON.parse($d.attr('params_arr'));
  // console.log('confirm2_success_clicked func_name=', func_name, ' params_arr=', params_arr);
  window[func_name](params_arr);
  $d.modal('hide');
}

function confirm2(str, func_name, params_arr) {
  let modal_id = 'modal_auto_id_confirm2_' + func_name;
  if (!($('#' + modal_id).length > 0)) $('body').append($(empty_modal_html(modal_id, 'proj_modal_main confirm2_modal')));
  let $d = $('#' + modal_id);
  $d.attr('func_name', func_name);
  $d.attr('params_arr', JSON.stringify(params_arr));
  $d.find('.modal-title').html('Подтвердите действие');
  var c2_title = '<span class="c2_title">' + str + '</span>';
  var sep = '<div class="horizontal_separator"></div>';
  var btns = '<button class="c2_btn c2_ok_btn" type="button" onclick="confirm2_success_clicked(this)">OK</button><a href="#" class="c2_close" data-dismiss="modal" aria-label="Close">Отмена</a>';
  $d.find('.modal-body').html('<div class="c2_content">' + c2_title + sep + '<div class="btns_block">' + btns + '</div></div>');
  $d.modal('show');
  return false;
}

function event_filters_select2_change(elem) {
  $(elem).closest('form').submit();
}



function empty_modal_html(modal_id, modal_class, params) {
  if (!(params)) params = {};
  return '<div class="modal ' + modal_class + ' empty_modal_html_main fade" id="' + modal_id + '" tabindex="-1" role="dialog" aria-labelledby="change_model_link_id" aria-hidden="true" ><div class="modal-dialog" role="document"><div class="modal-content"><div class="modal-header"><h5 class="modal-title">Loading...</h5><button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button></div><div class="modal-body form_post_outer_block"></div></div></div></div>';
}

function fill_modal_from_url(modal_wnd, url_in, params_in) {
  if (!(params_in)) params_in = {};
  let url = new URL(url_in, document.location.protocol +'//' + document.location.host);
  let m_id = $(modal_wnd).attr('id');
  url.searchParams.set('dialog_wnd_id', m_id);
  url.searchParams.set('r', Math.floor(Math.random() * Math.floor(1000000)));
  $(modal_wnd).children('.modal-dialog').children('.modal-content').children('.modal-body').html('&nbsp;');
  $(modal_wnd).children('.modal-dialog').children('.modal-content').children('.modal-header').children('.modal-title').html('Loading...');
  $.ajax({ url: url.href, type: "GET", dataType: "json", cache: false,
    success: function(res) {
      console.log('fill_modal_from_url href=', url.href,' success res=', res);
      // if (res.redirect) return window.location.href = res.redirect;
      fill_form_post_outer_block($(modal_wnd).children('.modal-dialog').children('.modal-content').children('.modal-body')[0], res);
      // $('#' + m_id).children('.modal-dialog').children('.modal-content').children('.modal-body').html(res.flash_html + res.main_text);
      let wnd_title = res.title || 'No title found in response';
      console.log('fill_modal_from_url params_in=', params_in ,' wnd_title=', wnd_title);
      $('#' + m_id).children('.modal-dialog').children('.modal-content').children('.modal-header').find('.modal-title').html(wnd_title);
      if (res.cart_cnt) { $('#top_menu_cart_cnt').html(res.cart_cnt); }
      init_js_components($('#' + m_id)[0]);
    },
    error: function(res) {
      console.error('fill_modal_from_url fail res=', res);
      try {
        let data = JSON.parse(res.responseText);
        console.log('fill_modal_from_url err data=', data);
        if (data.main_text) {
          $('#' + m_id).children('.modal-dialog').children('.modal-content').children('.modal-body').html(data.flash_html + data.main_text);
          let wnd_title = data.title || 'No title found in response';
          $('#' + m_id).children('.modal-dialog').children('.modal-content').children('.modal-header').find('.modal-title').html(wnd_title);
          return false;
        }
      } catch(error) {
        console.error(error);
      }
      $('#' + m_id).children('.modal-dialog').children('.modal-content').children('.modal-body').html(res.responseText);
    }
  });
}


var MODALS_HASH_DELIMETER = '____';
function check_some_modals_need_close() {
  let new_hash_vals = [];
  let hash_str = window.location.href.split('#')[1];
  if (hash_str) new_hash_vals = hash_str.split(MODALS_HASH_DELIMETER);
  $('.modal[link_name]').each(function (e, item) {
    let $d = $(item);
    let link_name = $d.attr('link_name');
    if ((link_name) && (link_name.length > 0)) {
      if (!(new_hash_vals.indexOf(link_name) >= 0)) {
        $d.modal('hide');
      }
    }
  });
  return false;
}

window.onhashchange = function() { check_some_modals_need_close(); };

function store_opened_modals_in_url_hash() {
  let new_hash_vals = [];
  $('.modal:visible').each(function (e, item) {
    let $d = $(item);
    let link_name = $d.attr('link_name');
    if ((link_name) && (link_name.length > 0)) {
      if (!(new_hash_vals.indexOf(link_name) >= 0)) new_hash_vals.push(link_name);
    }
  });
  set_location_with_new_hash_vals(new_hash_vals);
  return false;
}

function set_location_with_new_hash_vals(new_hash_vals) {
  let new_hash_val = window.location.href.replace(/\#.*$/, '');
  if (new_hash_vals.length > 0) new_hash_val = new_hash_val + '#' + new_hash_vals.join(MODALS_HASH_DELIMETER);
  if(history.pushState) {
    history.pushState(null, null, new_hash_val);
  }else {
    location.hash = new_hash_val;
  }
  return false;
}

function show_in_modal_link(elem, modal_class) {
  event.stopPropagation();
  event.preventDefault();
  let url = $(elem).attr('href');
  let data = $(elem).data();
  let link_name = $(elem).attr('name');
  if (!(data)) data = {};
  let link_url_as_name = url.replace(/[^a-z0-9]/g, '_').replace(/_\d+$/, '');
  let modal_id = 'modal_auto_id_' + link_url_as_name;
  console.log('started show_in_modal_link url=', url, ' modal_id=', modal_id);
  if (!($('#' + modal_id).length > 0)) $('body').append($(empty_modal_html(modal_id, modal_class)));
  let $d = $('#' + modal_id);
  if (!((link_name) && (link_name.length > 0))) link_name = link_url_as_name;
  // if (link_name) {
    $d.attr('link_name', link_name);
    let new_hash_vals = [];
    let hash_str = window.location.href.split('#')[1];
    if (hash_str) new_hash_vals = hash_str.split(MODALS_HASH_DELIMETER);
    if (!(new_hash_vals.indexOf(link_name) >= 0)) new_hash_vals.push(link_name);
    set_location_with_new_hash_vals(new_hash_vals);
  // }
  $d.attr('modal_data', JSON.stringify(data));
  $d.modal('show');
  // $d.draggable({ handle: ".modal-header" });
  fill_modal_from_url($d[0], url, data);
  return false;
}

function form_csrf(elem) { return $(elem).closest('.csrf_container_block').find('input[name="_csrf"]').attr('value'); }


function fill_form_post_outer_block(elem, res) {
  // console.log('started fill_form_post_outer_block. elem=', elem, ' res=', res);
  if (!(elem)) return false;
  $(elem).html("<div class='modal_flash_html_block'>" + res.flash_html + '</div><div class="main_text_block">' + res.main_text + '</div>');
  return true;
}

function form_to_params(form) {
  var result = {};
  var arr = $(form).serializeArray();
  arr.forEach(function(el) {
    result[el['name']] = ((result[el['name']]) ? result[el['name']] + ',' : '') + el['value'];
  });
  return result;
}


function run_ajax_submit_if_modal(elem) {
  if (!($(elem).closest('.modal').length > 0)) return true;
  // console.log('run_ajax_submit_if_modal event=', event);
  let fdata = form_to_params(elem);
  if ((event) && (event.submitter) && (event.submitter.name)) {
    fdata[event.submitter.name] = event.submitter.value;
  }
  fdata['dialog_wnd_id'] = 1;
  let params = [{}];
  let $d = $(elem);
  let modal_id = $d.closest('.modal').attr('id');
  $d.attr('params_arr', JSON.stringify(params));
  // console.log('started run_ajax_submit_if_modal fdata=', fdata);
  let url = new URL($d.attr('action'), document.location.protocol +'//' + document.location.host);

  // console.log('started run_ajax_submit_if_modal url=', url);
  $(elem).attr('form_runned_loading_xhr', 1);
  $.ajax({ url: url.href, type: $d.attr('method'), dataType: "json", data: fdata, cache: false,
    success: function(res) {
      $(elem).attr('form_runned_loading_xhr', 0);
      // console.log('run_ajax_submit_if_modal success res=', res, " this=", this);
      if (res.redirect_to_new_location) {
        let get_params = {};
        // console.log("page 222 started. get_params=", get_params, " res=", res, " this=", this, 'cookie=', this.cookie);
        // document.cookie = this.cookie;
        fill_modal_from_url($("#" + modal_id)[0], res.redirect_to_new_location, get_params);
        return true;
      }
      let modal_wnd = $d.closest('.form_post_outer_block')[0];
      fill_form_post_outer_block(modal_wnd, res);
      init_js_components(modal_wnd);
      let params_arr = JSON.parse($d.attr('params_arr'));
      let func_name = $d.attr('success_func');
      // console.log('run_ajax_submit_if_modal func_name=', func_name, ' params_arr=', params_arr, ' m_id=', m_id);
      window[$d.attr('success_func')](res, modal_id, params_arr);
    },
    error: function(res) {
      $(elem).attr('form_runned_loading_xhr', 0);
      console.error('run_ajax_submit_if_modal fail res=', res);
      try {
        let data = JSON.parse(res.responseText);
        console.log('run_ajax_submit_if_modal err data=', data);
        if (data.main_text) {
          let modal_wnd = $d.closest('.form_post_outer_block')[0];
          fill_form_post_outer_block(modal_wnd, data);
          return false;
        }
      } catch(error) {
        console.error(error);
      }
      $d.closest('.form_post_outer_block').html(res.responseText);
    }
  });
  return false;
}

function refresh_model_items_htmls_in_list(res, modal_id, params) {
  if (!(params)) params = {};
  console.log('started refresh_model_items_htmls_in_list res=', res, ' params=', params);
  // let m = $('#' + modal_id)[0];
  if (!(res.erorrs_found > 0)) {
    let updated_models = JSON.parse('[' + (res.updated_models || "") + ']');
    let need_refresh_page = 0;
    // console.log('updated_models=', updated_models);
    updated_models.forEach(function(el) {
      let $elems = $('.list_item_block[list_item_model="' + el.model_name + '"][list_item_id="' + el.model_id + '"]');
      console.log('model_name=' , el.model_name , 'model_id=', el.model_id ,' elems_size=', $elems.length, 'el=', el);
      if ($elems.length > 0) {
        let row_num = parseInt($elems.attr('item_num'));
        if (el.new_item_html.length > 0) el.list_html = $(el.new_item_html)[0].innerHTML;
        $elems.html(el.list_html);
        if (row_num > 0) $elems.find('.item_num_html').html(row_num);
      } else {
        if ((el.new_item_html) && (el.list_class)) {
          if (el.ins_prepend == true) {
            $('.' + el.list_class).prepend(el.new_item_html);
          } else {
            $('.' + el.list_class).append(el.new_item_html);
          }
        } else {
          console.log('Not found ' + el.model_name + '[' + el.model_id + ']. So need_refresh_page!');
          need_refresh_page = 1;
        }
      }
    });
    if ((need_refresh_page > 0) && (!(params.ignore_refresh > 0))) {
      document.location.href = document.location.href;
      return false;
    }
  } else {
    console.log('refresh_model_items_htmls_in_list errors found=', res.erorrs_found);
  }
}


function refresh_model_items_htmls_in_list_and_close_modal(res, modal_id, params) {
  if (!(res.erorrs_found > 0)) {
    refresh_model_items_htmls_in_list(res, modal_id, params)
    js_sleep_in_this_thread(800).then(() => { $('#' + modal_id).modal('hide'); });
  } else {
    console.log('refresh_model_items_htmls_in_list_and_close_modal errors found=', res.erorrs_found);
  }
}


function set_stars_raiting(elem, ev) {
  // console.log('set_stars_raiting event=', ev, ' elem=', elem, ' src=', ev.srcElement);
  // let item_pressed = ev.path[0];
  let item_pressed = ev.srcElement;
  let $d = $(elem).closest('.stars_rating_block');
  // console.log('set_stars_raiting item_pressed=', item_pressed , ' event=', ev, ' elem=', elem);
  let pressed_val = 0;
  let found_pressed = false;
  $d.find('.stars_rating').find('i').each(function (i) {
    let i_item = this;
    let $r = $(i_item);
    if (found_pressed) {
      $r.attr('tunedoff', 1);
    } else {
      pressed_val = pressed_val + 1;
      $r.attr('tunedoff', 0);
    }
    if (item_pressed == i_item) found_pressed = true;
  });
  $d.find('input[name="rating_val"]').val(pressed_val);
  // console.log('pressed_val=', pressed_val);
  return false;
}

function refresh_messages_in_list (btn) {
  // return false;
  $(btn).attr('already_runned', '1');
  let $frm = $(btn).closest('form');
  let url = new URL($frm.attr('action') + '?dialog_wnd_id=1', document.location.protocol +'//' + document.location.host);

  $.ajax({ url: url.href }).done(function(data) {
    let json_obj = JSON.parse(data.trim());
    // console.log('refresh_messages_in_list success json_obj=', json_obj);
    $frm.find('.messages_list_table').html($(json_obj.main_text).find('.messages_list_table').html());
    $(btn).attr('already_runned', '0');
  }).fail(function(data){
    console.error('refresh_messages_in_list fail load data=', data);
    $(btn).attr('already_runned', '0');
  });
}



