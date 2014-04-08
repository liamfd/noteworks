

//sets the stuff for users/profile
function submitForm(){
  $(this).parents("form").submit();
  console.log("submitting");
}

function toggleSpinner(){
  $("#spinner").toggle();
}

$(function() {
  $('#groupModal').bind('opened', function() {
    //this could also go in a ajaxComplete global call
    console.log("groupModal opening");

    //console.log("myModal opened");
    //if ( $(".edit_form").length !== 0 ){
    //  if ($(".edit_form").find("#work_group_name").length !== 0){
    //    $(".edit_form").find('#work_group_name').get(0).onblur= submitForm;
    //  }
    //}

    $("#spinner").hide();

    $("form").bind("ajax:beforeSend", function(){
      $("#spinner").show();
      $("#response").hide();
    });
    $("form").bind("ajax:success", function(evt, data, status, xhr){
      $("#response").html("Saved!").show().fadeOut("slow");
    });
    $("form").bind("ajax:complete", function(){
      $("#spinner").hide();
    });
    $("form").bind("ajax:error", function(xhr, ajaxOptions, thrownError){
      //find a way to get the actual error being returned by the rails controller
      $("#response").html("Error: Something's gone wrong.").show().fadeOut("slow");
      $("#spinner").hide();
    });
  });
});