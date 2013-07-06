//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require cocoon
//= require twitter/bootstrap
//= require jquery.stickytableheaders.js

$(function() {
  $('.topbar').dropdown();
  $('.alert-message').alert();
  $('a[data-original-title]').popover();
  $('div.date input').datepicker({
    dateFormat: "yy-mm-dd"
  });
});
