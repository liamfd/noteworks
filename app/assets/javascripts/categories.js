$( document ).ready(function() {
	$('#category_name').get(0).onblur= submitForm;
	$("#spinner").hide();
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