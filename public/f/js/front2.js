$(document).ready(function () {
  console.log('ready started here!');
  $.ajaxSetup({ cache: false });
  init_js_components($('body')[0]);
});


function init_js_components(elem) {
  let $m = $(elem);
  console.log('init_js_components started');
  let svg_arrow_str = '<svg width="100%" height="100%" viewBox="0 0 11 20"><path style="fill:none;stroke-width: 1px;stroke: #000;" d="M9.554,1.001l-8.607,8.607l8.607,8.606"/></svg>';


  $m.find('.synchronized_2_sliders').not(".synchronized_2_sliders_init_done").addClass('synchronized_2_sliders_init_done').each(function (e, item) {
    let slidesPerPage = 6; //globaly define number of elements per page
    let $d = $(item);
    $d.attr('sync_slider_id', 0);
    $d.attr('sync_slidesPerPage', slidesPerPage);
    let sync_slider_id = parseInt($d.attr('sync_slider_id'));
    let $lg_slider = $d.children('.sync_large_slider');
    let $sm_slider = $d.children('.sync_small_slider');



    $lg_slider.owlCarousel({
      items: 1,
      slideSpeed: 200,
      nav: true,
      loop: false,
      // loop: true,
      dots: false,
      autoplay: false,

      responsiveRefreshRate: 200,
      // navText: [, '<svg width="100%" height="100%" viewBox="0 0 11 20" version="1.1"><path style="fill:none;stroke-width: 1px;stroke: #000;" d="M1.054,18.214l8.606,-8.606l-8.606,-8.607"/></svg>'],
      // navText: ['<img src="/f/pics/slider/arr-violet_left.png"/>', '<img src="/f/pics/slider/arr-violet_left.png" />']
      navText: [svg_arrow_str, svg_arrow_str]
    }).on('changed.owl.carousel', syncPosition);

    $sm_slider.on('initialized.owl.carousel', function() { $(this).closest('.synchronized_2_sliders').children('.sync_small_slider').find(".owl-item").eq(0).addClass("current"); }).owlCarousel({
      items: slidesPerPage,
      nav: true,
      loop: false,
      // loop: true,
      dots: false,
      autoplay: false,
      smartSpeed: 100,
      slideSpeed: 200,
      slideBy: slidesPerPage, //alternatively you can slide by 1, this way the active slide will stick to the first item in the second carousel
      responsiveRefreshRate: 100,
      // navText: ['<svg width="100%" height="100%" viewBox="0 0 11 20"><path style="fill:none;stroke-width: 1px;stroke: #000;" d="M9.554,1.001l-8.607,8.607l8.607,8.606"/></svg>', '<svg width="100%" height="100%" viewBox="0 0 11 20" version="1.1"><path style="fill:none;stroke-width: 1px;stroke: #000;" d="M1.054,18.214l8.606,-8.606l-8.606,-8.607"/></svg>']
      // navText: ['<img src="/f/pics/slider/arr-violet_left.png"/>', '<img src="/f/pics/slider/arr-violet_left.png" />']
      navText: [svg_arrow_str, svg_arrow_str]
    }).on('changed.owl.carousel', syncPosition2);

    $sm_slider.on("click", ".owl-item", function(e) {
      let $t = $(this);
      e.preventDefault();
      let number = $t.index();
      $t.closest('.synchronized_2_sliders').children('.sync_large_slider').data('owl.carousel').to(number, 300, true);
    });
  });

  $m.find('.catalog_item_img_block2').not(".owl_prod_list_slider_init_done").addClass('owl_prod_list_slider_init_done').each(function (e, item) {
    $(item).find('.owl_prod_list_slider').owlCarousel({
      items: 1,
      slideSpeed: 200,
      nav: false,
      loop: false,
      // loop: true,
      dots: true,
      autoplay: false,
      responsiveRefreshRate: 500,
      // navText: ['<svg width="100%" height="100%" viewBox="0 0 11 20"><path style="fill:none;stroke-width: 1px;stroke: #000;" d="M9.554,1.001l-8.607,8.607l8.607,8.606"/></svg>', '<svg width="100%" height="100%" viewBox="0 0 11 20" version="1.1"><path style="fill:none;stroke-width: 1px;stroke: #000;" d="M1.054,18.214l8.606,-8.606l-8.606,-8.607"/></svg>'],
      // navText: ['<img src="/f/pics/slider/arr-violet_left.png"/>', '<img src="/f/pics/slider/arr-violet_left.png" />']
    });
  });

  $m.find('.select2_simple_multiple').not(".select2_simple_multiple_init_done").addClass('select2_simple_multiple_init_done').each(function (e, item) {
    $(item).select2({
      theme: "bootstrap",
      maximumSelectionSize: 6,
      containerCssClass: ':all:',
      templateResult: function (data, container) {
        if (data.element) {
          $(container).attr('style', $(data.element).attr("style"));
        }
        return data.text;
      }
    });
  });

  $m.find('.select2_multiple_with_no_results').not(".select2_multiple_with_no_results_init_done").addClass('select2_multiple_with_no_results_init_done').each(function (e, item) {
    $(item).select2({
      theme: "bootstrap",
      maximumSelectionSize: 6,
      containerCssClass: ':all:',
      tags: true,
      templateResult: function (d, c) {
        if (d.element) {
          $(c).attr('style', $(d.element).attr("style"));
          if ($(d.element).attr('status')) $(c).attr('status', $(d.element).attr("status"));
          // console.log('TMP STOP 23231123. d=', d, 'status=', $(d.element).attr("status"), 'c=', c);
        }
        return d.text;
      },
      templateSelection: function (d, c) {
        if ($(d.element).attr('status')) $(c).attr('status', $(d.element).attr("status"));
        // console.log('TMP STOP 345345434. d=', d, 'status=', $(d.element).attr("status"), 'c=', c);
        return d.text;
      },
      createTag: function (params) { let t = $.trim(params.term); if (t === '') return null; return { id: t, text: t, newTag: true }; }
    });
  });

  $m.find('.date_picker').not(".date_picker_init_done").addClass('date_picker_init_done').each(function (e, item) {
    $(item).datetimepicker({ format: 'YYYY-MM-DD', viewMode: 'years' });
  });

  $m.find('.date_time_picker').not(".date_time_picker_init_done").addClass('date_time_picker_init_done').each(function (e, item) {
    $(item).datetimepicker({
      // inline: true,
      // useStrict: true,
      collapse: true,
      format: 'YYYY-MM-DD HH:mm',
      sideBySide: true
    });
  });




  console.log('init_js_components end');
}



function syncPosition(el) {
  // let $d = $(el).closest('.synchronized_2_sliders');
  let $d = $(el.currentTarget).closest('.synchronized_2_sliders');
  let sync_slider_id = parseInt($d.attr('sync_slider_id'));
  let $lg_slider = $d.children('.sync_large_slider');
  let $sm_slider = $d.children('.sync_small_slider');

  console.log('syncPosition el=', el , ' d=', $d);
  console.log('syncPosition sm_slider=', $sm_slider , ' lg_slider=', $lg_slider);
  if (!(sync_slider_id == 1)) {
    // this line of loop will be turned off.
    var current = el.item.index;

    // var count = el.item.count - 1;
    // var current = Math.round(el.item.index - (el.item.count / 2) - .5);
    // if (current < 0) { current = count; }
    // if (current > count) { current = 0; }

    // console.log('syncPosition count=', count, ' current2=', current);

    console.log('started syncPosition current=', current);

    if (!(sync_slider_id > 0)) {
      $d.attr('sync_slider_id', 1);
      var onscreen = $sm_slider.find('.owl-item.active').length - 1;
      var start = $sm_slider.find('.owl-item.active').first().index();
      var end = $sm_slider.find('.owl-item.active').last().index();
      console.log('syncPosition onscreen=', onscreen, ' start=', start, ' end', end);
      if (current > end  ) { $sm_slider.data('owl.carousel').to(current, 100, true); }
      if (current < start) { $sm_slider.data('owl.carousel').to(current - onscreen, 100, true); }
      console.log('END syncPosition current=', current);
      $d.attr('sync_slider_id', 0);
    }
    $sm_slider.find(".owl-item").removeClass("current").eq(current).addClass("current");
  }
}

function fill_coords_from_gmaps_str(elem) {
  let $d = $(elem).closest('.fill_coords_main_block');
  let cur_lat = parseFloat($.trim($d.find('.fill_coords_lat').val()));
  let cur_lng = parseFloat($.trim($d.find('.fill_coords_lng').val()));
  let str = prompt('Set new lat and lng', cur_lat + ', ' + cur_lng);
  if (str) {
    let err_str = '';
    if (str.length > 3) {
      let arr = str.split(',');
      if (arr.length === 2) {
        let new_lat = parseFloat($.trim(arr[0]));
        let new_lng = parseFloat($.trim(arr[1]));
        if ((new_lat > -90) && (new_lat < 90)) {
          if ((new_lng > -180) && (new_lat < 180)) {
            $d.find('.fill_coords_lat').val(new_lat);
            $d.find('.fill_coords_lng').val(new_lng);
            return false;
          } else {
            err_str = 'Lng must be [-180..180]';
          }
        } else {
          err_str = 'Lat must be [-90..90]';
        }
      } else {
        err_str = 'In string must be at least one [,]';
      }
    } else {
      err_str = 'Wrong input';
    }
    if (err_str.length > 0) {
      alert(err_str);
      return fill_coords_from_gmaps_str(elem);
    }
  }
  return false;
}

function syncPosition2(el) {
  // let $d = $(el).closest('.synchronized_2_sliders');
  let $d = $(el.currentTarget).closest('.synchronized_2_sliders');
  let sync_slider_id = parseInt($d.attr('sync_slider_id'));
  let $lg_slider = $d.children('.sync_large_slider');
  let $sm_slider = $d.children('.sync_small_slider');
  console.log('syncPosition2 el=', el, ' d=', $d);
  if (!(sync_slider_id == 2)) {
    if (!(sync_slider_id > 0)) {
      $d.attr('sync_slider_id', 2);
      var number = el.item.index;
      console.log('started syncPosition2 number=', number);
      $lg_slider.data('owl.carousel').to(number, 100, true);
      console.log('END syncPosition2 number=', number);
      $d.attr('sync_slider_id', 0);
    }
  }
}

