$( document ).ready(function() {
	/*
	$('#category_name').blur(function(){
		submitForm();
	});
	*/

	$('#category_name').get(0).onblur= submitForm;
	//$("#spinner").hide();
/*	$("#spinner").bind("ajaxSend", function() {
	$(this).show();
	}).bind("ajaxStop", function() {
	$(this).hide();
	alert("scoop");
	}).bind("ajaxError", function() {
	$(this).hide();
	});*/
	//$("form[data-remote]").bind('ajax:before', toggleSpinner());
	//$("form[data-remote]").bind('ajax:complete', toggleSpinner());
	
});

function submitForm(){
	$(this).parents("form").submit();
	console.log($(this));
}

function toggleSpinner(){
	$("#spinner").toggle();
}

$(function() {
	$("form").bind("ajax:beforeSend", function(){
		$("#spinner").show();
	});
	$("form").bind("ajax:complete", function(){
		$("#spinner").hide();
	});
});