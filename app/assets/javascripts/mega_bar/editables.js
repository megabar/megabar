$(function() {
  $(".edit_area").editable("/mega-bar/model_displays/167", { 
      indicator : "<img src='http://www.appelsiini.net/projects/jeditable/img/indicator.gif'>",
      type   : 'textarea',
      submitdata: { _method: "put" },
      select : true,
      submit : 'OK',
      cancel : 'cancel',
      cssclass : "editable"
  });
 
});