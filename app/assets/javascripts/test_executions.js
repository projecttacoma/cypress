
var ready;
ready = function() {
  // switch view to selected test execution
  $("#view_execution").click(function(event) {
    window.location.href = $("#select_execution").val();
  });

  $("#submit-upload").click(function(event) {
    event.preventDefault();
    $("#new_test_execution").submit();
  });
}

$(document).on('page:change page:load', ready);


function show_error_popup_and_jump(href) {
  if ($(href)) {
    $('button.error-popup-btn').popover('hide'); /* hide all error popovers before showing the new one */

    var scroll_time = 300;      /* (milisec) time it takes to scroll from one error popover to another */
    var height_buffer = 20;     /* number of pixels between the xml_nav_bar and the error after done scrolling */

    var height_of_xmlnav_div = $('.xml-nav').outerHeight();
    var height_of_error_div = $(href).siblings('.error').outerHeight();
    var pixels_down_page = height_of_xmlnav_div + height_buffer + height_of_error_div; /* number of pixels down the page the error will apear after scrolling */

    /* scroll to error popover */
    $('html,body').animate({ scrollTop: $(href).offset().top - pixels_down_page }, { duration: scroll_time, easing: 'swing'}).promise().done(function() {
      $('button.' + href.replace('#', '')).popover('toggle');           /* show popover for button with matching error id class */

      var $list_item = $('li.' + href.replace('#', ''));
      if ($list_item.length) {
        $list_item.effect( "highlight", {}, 2000 ); /* temporarily highlight the error if there are a list of errors in the popover */
      }
    });
  }
}
