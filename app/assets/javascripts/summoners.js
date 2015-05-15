// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

$( document ).ready(function() {
	$( "#5_mot_played_li" ).click(function() {
		hide_all_div_menu();
		set_visible($("#div_most_champ_played"));
		$("#5_mot_played_li").addClass("active");
	});
	$( "#adc_li" ).click(function() {
		hide_all_div_menu();
		set_visible($("#div_most_adc_played"));
		$("#adc_li").addClass("active");
	});
	$( "#support_li" ).click(function() {
		hide_all_div_menu();
		set_visible($("#div_most_support_played"));
		$("#support_li").addClass("active");
	});
	$( "#mid_li" ).click(function() {
		hide_all_div_menu();
		set_visible($("#div_most_mid_played"));
		$("#mid_li").addClass("active");
	});
	$( "#top_li" ).click(function() {
		hide_all_div_menu();
		set_visible($("#div_most_top_played"));
		$("#top_li").addClass("active");
	});
	$( "#jungle_li" ).click(function() {
		hide_all_div_menu();
		set_visible($("#div_most_jungle_played"));
		$("#jungle_li").addClass("active");
	});
});

function set_visible(element){
	element.show( "slow", function() {
    // Animation complete.
});
}

function hide_all_div_menu(){
	$("#div_most_champ_played").hide();
	$("#5_mot_played_li").removeClass("active");
	$("#div_most_adc_played").hide();
	$("#adc_li").removeClass("active");
	$("#div_most_support_played").hide();
	$("#support_li").removeClass("active");
	$("#div_most_mid_played").hide();
	$("#mid_li").removeClass("active");
	$("#div_most_top_played").hide();
	$("#top_li").removeClass("active");
	$("#div_most_jungle_played").hide();
	$("#jungle_li").removeClass("active");
}