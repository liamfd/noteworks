var test_data;
var test_xhr;
var test_obj;
var test_ajaxOptions;
var test_error;
$( document ).ready(function() {
	$('#category_list').bind("ajax:success", function(evt, data, status, xhr){
	//	alert('hello');
    });
});

function submitForm(){
	$(this).parents("form").submit();
	console.log($(this));
}

function toggleSpinner(){
	$("#spinner").toggle();
}

$(function() {

	$('#myModal').bind('opened', function() {
		//this could also go in a ajaxComplete global call

		//console.log("myModal opened");

		$(".edit_form").find('#category_name').get(0).onblur= submitForm;
		$(".edit_form").find('#category_color').get(0).onblur= submitForm;
		$("#spinner").hide();

		$("form").bind("ajax:beforeSend", function(){
			$("#spinner").show();
			$("#response").hide();
		});
		$("form").bind("ajax:success", function(evt, data, status, xhr){
			$("#response").html("Saved!").show().fadeOut("slow");
			test_data = data;
			updateObject(data);
		});
		$("form").bind("ajax:complete", function(){
			$("#spinner").hide();
		});
		$("form").bind("ajax:error", function(xhr, ajaxOptions, thrownError){
			//find a way to get the actual error being returned by the rails controller
			$("#response").html("Error: Repeated name.").show().fadeOut("slow");
			$("#spinner").hide();
			test_xhr = xhr;
			test_ajaxOptions = ajaxOptions;
			test_error = thrownError;
		});
	});
});

function updateObject(data){
	console.log("updating");
	obj = $("#category-"+data.id);
	test_obj = obj;
	obj.children("a.edit-link").text(data.name);
	obj.children("a.edit-link").css("color",data.color);
}