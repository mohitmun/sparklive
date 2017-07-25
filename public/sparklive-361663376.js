visitor_id=361663376;sparklive_url = "http://localhost:3000"
refresh_rate = 20000
var mainStyle = '<link href="'+sparklive_url+'/sparklive.css" rel="stylesheet">'
var addStyle = "<style> #sparklive-widget .sparklive-widget-messages>div {margin-left: 0px;}#sparklive-widget .sparklive-widget-messages{margin-bottom: 10px;padding: 20px;}#sparklive-widget .sparklive-widget-input-container{bottom: 0 !important;}</style>";
$('head').append(mainStyle);
$('head').append(addStyle);


var box = '<div id="sparklive-button" class="sparklive-button-float sparklive-animatable"><div class="sparklive-button-title">We&#39;re&nbsp;offline.&nbsp;Leave&nbsp;a&nbsp;message.</div><img class="sparklive-button-icon" src="https://linked.chat:443/static/widget/icons/logo.svg" alt="sparklive-logo"><img class="sparklive-button-icon-close" src="https://linked.chat:443/static/widget/icons/close.svg" alt="Minimize chat" title="Minimize chat"></div><div id="sparklive-widget" class="sparklive-button-float sparklive-animatable"><div class="sparklive-widget-title">Support</div><img class="sparklive-widget-settings-btn" src="https://linked.chat:443/static/widget/icons/settings.svg" alt="Open settings" title="Open settings"><div class="sparklive-widget-settings-container"><form><div><input class="sparklive-widget-input sparklive-widget-input-login-name" name="name" type="text" placeholder="Name" aria-label="Name" value=""></div><div><input class="sparklive-widget-input sparklive-widget-input-login-email" name="email" type="text" placeholder="Email" aria-label="Email" value=""></div><div><input class="sparklive-widget-login-btn" type="button" value="Save"></div></form></div><img class="sparklive-widget-close-btn" src="https://linked.chat:443/static/widget/icons/minimize.svg" alt="Minimize chat" title="Minimize chat"><div class="sparklive-widget-content"><div class="sparklive-widget-messages"></div><div class="sparklive-widget-input-container"><form><div><input class="sparklive-widget-input sparklive-widget-input-name" name="name" type="text" placeholder="Name" aria-label="Name" value="" style="display: none;"></div><div><input class="sparklive-widget-input sparklive-widget-input-email" name="email" type="text" placeholder="Email" aria-label="Email" value="" style="display: none;"></div><div><input class="sparklive-widget-input sparklive-widget-input-message" placeholder="Type a message..." aria-label="Type a message..."></div><div><input class="sparklive-widget-send-btn" type="button" value="Send message" ></div></form></div></div></div>';
$('body').append(box);

var myMessage = '<div class="sparklive-widget-message-from-visitor"><div></div></div>';
var hisMessage = '<div class="sparklive-widget-message-from-agent no-agent-name"><div></div></div>';
var messageBox = $('.sparklive-widget-messages');
var messages = $(".sparklive-widget-messages");

var curLen = 0;
var refresh = function() {
    $.getJSON(sparklive_url+'/get_messages?client_id+' + client_id + "&visitor_id="+visitor_id,
        function(result) {
            console.log("success")
            console.log(result)
            resetMessages(result.messages)
        })
    timer = setTimeout(refresh, refresh_rate);
}

// function createCookie(name,value,days) {
//     var expires = "";
//     if (days) {
//         var date = new Date();
//         date.setTime(date.getTime() + (days*24*60*60*1000));
//         expires = "; expires=" + date.toUTCString();
//     }
//     document.cookie = name + "=" + value + expires + "; path=/";
// }

function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    console.log(document.cookie)
    for(var i=0;i < ca.length;i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
}

function eraseCookie(name) {
    createCookie(name,"",-1);
}

var addMessage = function (message, type) {
    if(type==2) {
        var divToAdd = $.parseHTML(myMessage);
    } else {
        var divToAdd = $.parseHTML(hisMessage);
    }
    $(divToAdd).append(message);
    return divToAdd;

}

var resetMessages = function (data) {
    var toAdd = $.parseHTML('<div></div>');
    $.each(data, function(i, item) {
        $(toAdd).append(addMessage(item.text, item.by));
    });
    messages.empty();
    messages.append($(toAdd).children());
    console.log(data.length);
    console.log(messages)
    if(curLen < data.length) {
        
        messages[0].scrollTop = messages[0].scrollHeight;
        curLen = data.length;
    }

}
var timer;
var client_id = $("#sparklive-script").attr("data-client-id");

function init() {

    $('.sparklive-widget-close-btn').click(function() {
        console.log("called");
        $('#sparklive-widget').removeClass("sparklive-widget-opened");
        $('#sparklive-button').removeClass("sparklive-widget-opened");
    });

    $('.sparklive-widget-settings-btn').click(function () {
        if($('.sparklive-widget-settings-container').hasClass('sparklive-widget-opened')) {
            $('.sparklive-widget-settings-container').removeClass('sparklive-widget-opened');
        } else {
            $('.sparklive-widget-settings-container').addClass('sparklive-widget-opened')
        }
    });
    $('#sparklive-button').click(function () {
        if($('#sparklive-widget').hasClass("sparklive-widget-opened")) {
            $('#sparklive-widget').removeClass("sparklive-widget-opened");
            $('#sparklive-button').removeClass("sparklive-widget-opened");
        } else {
            $('#sparklive-widget').addClass("sparklive-widget-opened");
            $('#sparklive-button').addClass("sparklive-widget-opened");
        }
    });

    $('.sparklive-widget-input-message').keyup(function(e){
        var code= e.which;
        if(code == 13) $('.sparklive-widget-send-btn').click();
    });

    $('.sparklive-widget-send-btn').click(function(e) {
        e.preventDefault();
        if($(".sparklive-widget-input-message").val()!="" && $(".sparklive-widget-input-message").val()!=undefined) {
            $.getJSON({
                method: "GET",
                url: sparklive_url+'/new_message/',
                data: {
                    text: $(".sparklive-widget-input-message").val(),
                    client_id: client_id,
                    visitor_id: window.visitor_id
                },
                success: function(result) {
                    var divToAdd = addMessage($(".sparklive-widget-input-message").val(),2);
                    messages.append(divToAdd);
                    $(".sparklive-widget-input-message").val("");
                    messages[0].scrollTop = messages[0].scrollHeight;
                },
                error: function(result) {
                }
            });
        }
    });
    refresh();

}
console.log("chus")
init();