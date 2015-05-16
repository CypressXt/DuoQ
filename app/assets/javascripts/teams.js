function refresh_team(url, element){
	$(element).addClass('disabled'); 
	$(element).text('refreshing...');
	setTimeout(
		function(){
			document.location=url;
		}, 
		1000);
}

function show_matches(element){
	if ($(element).data('pressed')){
		$(element).data("pressed", false);
		$(element).text('show match history');
	}else{
		$(element).data("pressed", true);
		$(element).text('hide match history');
	}
}