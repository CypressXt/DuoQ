function refresh_team(url, element){
	$(element).addClass('disabled'); 
	$(element).text('refreshing...');
	setTimeout(
		function(){
			document.location=url;
		}, 
		1000);
}