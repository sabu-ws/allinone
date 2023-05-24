$(document).ready(function(){
    $('tr').click(function() {
        var href = $(this).find("a").attr("href");
        if(href) {
            window.location = href;
        }
    });
    if(document.getElementById('table_browser').rows.length === 1){
        fold=document.getElementById('empty_folder').textContent = "This folder is empty";
        document.getElementById('div_ef').style.visibility = "visible";
    }
    $("#linkd").val(window.parent.location.pathname);
});

$(function(){
    $('#input_btn').change(function(){
       $('#sendd').submit();
       console.log("alert");
       document.getElementById("prompt_btn").style.backgroundColor = "#93c47d";
    }); 
});

$(function(){
    $('#input_btn2').change(function(){
       $('#sendd').submit();
       console.log("alert");
       document.getElementById("prompt_btn2").style.backgroundColor = "#93c47d";
    }); 
});


function ret() {
    var url = window.parent.location.href;
    if(url.substr(url.length - 1) == "/"){
        url=url.slice(0,-1)
    }
    const splitUrl = url.split("/");
    if(splitUrl[3] == "info"){
        var tret = location.pathname.substring(5);
        url=location.protocol+"//"+document.domain + ':' + location.port+"/browser"+tret;
    }
    if(url.slice(url.lastIndexOf('/')) != '/browser'){
        var to = url.lastIndexOf('/');
        to = to == -1 ? url.length : to + 1;
        url = url.substring(0, to -1 );
        window.location=url;
    }
}
