var test_data;
var test_xhr;
var test_obj;
$( document ).ready(function() {
	//change this in some way so it's only the edit
	
	//$('#category_name').get(0).onblur= submitForm;
	//$("#spinner").hide();
	console.log("There is JS");
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
		console.log("myModal opened");
		$('#category_name').get(0).onblur= submitForm;
		$("#spinner").hide();

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
});

function updateObject(data){
	console.log("updating");
	obj = $("#category-"+data.id);
	test_obj = obj;
	obj.children("a").text(data.name);
	obj.children("a").css("color",data.color);
}