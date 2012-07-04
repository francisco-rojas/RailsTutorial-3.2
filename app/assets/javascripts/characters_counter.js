$(document).ready(function() {
	display_character_count();
	
	$("#micropost_content").bind("keyup", function() {
		display_character_count();
	});
	
	function calculate_characters_left() {
    	var maxValue = 140;
    	var charsEntered = $("#micropost_content").val().length;
    	var leftChars = maxValue - charsEntered;
    	return leftChars;
	}
	
	function display_character_count(){
		var leftChars = calculate_characters_left();
		if (leftChars < 0) {
			$("#submit_button").attr('disabled', 'disabled')
			$("#chars_left").html("<label id=\"chars_left\" class=\"no_space_left\">" + leftChars + " characters left" + "</label>");
		} else {
			$("#chars_left").html("<label id=\"chars_left\">" + leftChars + " characters left" + "</label>");
			$("#submit_button").removeAttr('disabled');
		}
	}
});

