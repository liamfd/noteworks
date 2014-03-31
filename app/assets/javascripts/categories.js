$( document ).ready(function() {
	/*
	$('#category_name').blur(function(){
		submitForm();
	});
	*/
	$ ('#category_name').get(0).onblur= submitForm;
  
});

function submitForm(){
	$(this).parents("form").submit();
	console.log($(this));
}