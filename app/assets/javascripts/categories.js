var test_data;
var test_xhr;
var test_obj;
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
	$("form").bind("ajax:success", function(evt, data, status, xhr){
		test_data = data;
		updateObject(data);
	});
	$("form").bind("ajax:complete", function(){
		$("#spinner").hide();
	});
});

function updateObject(data){
	console.log("updating");
	obj = $("#category-"+data.id);
	test_obj = obj;
	obj.children("a").text(data.name);
	obj.children("a").css("color",data.color);
}