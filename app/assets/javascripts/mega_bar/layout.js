$(document).ready(function() {
  /* Activating Best In Place */
  $('#layout_section_layout_ids').change(function() { 
    alert('hey');
    $.get( "/mega-bar/template_sections_for_layout/3", function( data ) {
      
      $('#layout_section_template_section_id  > option').each(function() {
     
        if(jQuery.inArray(parseInt(jQuery(this).val()), data ) == -1){
          jQuery(this).remove();
        }
      });
    })
    .fail(function() {
      alert( "error" );
    });
  });
});
