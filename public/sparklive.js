visitor_id=7656299137;sparklive_url = 'https://4c0d0a4e.ngrok.io';refresh_rate = 1000
console.log("chu")
var mainStyle = '<link href="'+sparklive_url+'/sparklive.css" rel="stylesheet">'
var addStyle = "<style> #sparklive-widget .sparklive-widget-messages>div {margin-left: 0px;}#sparklive-widget .sparklive-widget-messages{margin-bottom: 10px;padding: 20px;}#sparklive-widget .sparklive-widget-input-container{bottom: 0 !important;}</style>";
$('head').append(mainStyle);
$('head').append(addStyle);

a = "<script src='"+sparklive_url+"/bundle.js' id='sparklive-av' data-client-id='Y2lzY29zcGFyazovL3VzL1BFT1BMRS9iMzNlZmVjNy1iNmQ2LTQ0NGQtOGI2OC1iMTc3YzVhYjE0MGY'></script>"
$('head').append(a);
outgoing_video_element = "<video autoplay='' class='video' style='display: none; width: 17%;position: absolute;    right: 10px;bottom: 50px;' id='outgoing-call'></video>"
end_call_button = "<input class='sparklive-widget-end-call-btn' style='display:none' type='button' value='End Call' >"
incoming_video_element = "<video autoplay='' class='video' style='display: none; width: 100%;' id='incoming-call'></video>"
video_call_button = '<input class="sparklive-widget-call-btn" data-type="video" type="button" style="width: 49%" value="Video Call" >'
audio_call_button = '<input class="sparklive-widget-call-btn" data-type="audio" type="button" style="margin-left: 2%;width: 49%" value="Audio Call" >'

login_form = '<form><div><input class="sparklive-widget-input sparklive-widget-input-login-name" name="name" type="text" placeholder="Name" aria-label="Name" value=""></div><div><input class="sparklive-widget-input sparklive-widget-input-login-email" name="email" type="text" placeholder="Email" aria-label="Email" value=""></div><div><input class="sparklive-widget-login-btn" type="button" value="Save"></div></form>'

close_ticket_button = '<input class="sparklive-widget-login-btn close-ticket-btn" type="button" value="Issue resolved">'

var box = '<div id="sparklive-button" class="sparklive-button-float sparklive-animatable"><div class="sparklive-button-title">We&#39;re&nbsp;offline.&nbsp;Leave&nbsp;a&nbsp;message.</div><img class="sparklive-button-icon" src="'+ sparklive_url +'/logo.svg" alt="sparklive-logo"><img class="sparklive-button-icon-close" src="'+ sparklive_url +'/close.svg" alt="Minimize chat" title="Minimize chat"></div><div id="sparklive-widget" class="sparklive-button-float sparklive-animatable"><div class="sparklive-widget-title">Support</div><img class="sparklive-widget-settings-btn" src="'+ sparklive_url +'/settings.svg" alt="Open settings" title="Open settings"><div class="sparklive-widget-settings-container">'+ close_ticket_button +'</div><img class="sparklive-widget-close-btn" src="'+ sparklive_url +'/minimize.svg" alt="Minimize chat" title="Minimize chat"><div class="sparklive-widget-content"><div class="sparklive-widget-messages"></div><div class="sparklive-widget-input-container"><form><div><input class="sparklive-widget-input sparklive-widget-input-name" name="name" type="text" placeholder="Name" aria-label="Name" value="" style="display: none;"></div><div><input class="sparklive-widget-input sparklive-widget-input-email" name="email" type="text" placeholder="Email" aria-label="Email" value="" style="display: none;"></div><div><input class="sparklive-widget-input sparklive-widget-input-message" placeholder="Type a message..." aria-label="Type a message..."></div><div><input class="sparklive-widget-send-btn" type="button" value="Send message" > '+incoming_video_element+ ''+outgoing_video_element+ video_call_button + audio_call_button +end_call_button+'</div></form></div></div></div>';
$('body').append(box);
var myMessage = '<div class="sparklive-widget-message-from-visitor"><div></div></div>';
var hisMessage = '<div class="sparklive-widget-message-from-agent no-agent-name"><div></div></div>';
var messageBox = $('.sparklive-widget-messages');
var messages = $(".sparklive-widget-messages");

$(".close-ticket-btn").click(function(argument) {
  $.getJSON(sparklive_url+'/new_message?client_id=' + client_id + "&visitor_id="+visitor_id + "&text=close+ticket&", function() {
    
  });
});

$(".sparklive-widget-call-btn").click(function() {
  call_type = $(this).data("type")
  console.log("call type" + call_type)
  $.getJSON(sparklive_url+'/new_message?client_id=' + client_id + "&visitor_id="+visitor_id + "&text=Initiating+call&support_type=" + call_type,
    function(result) {
      console.log("placing call")
      console.log(result)          
      spark = ciscospark.init({
        credentials: {
          access_token: result.access_token
        }
      });
      spark.phone.register()
      dial_email = result.sip_address
      call = spark.phone.dial(dial_email);
      window.eureka = call;
      call.on('connected', function() {
        console.log("connected call")
        incoming_call = document.getElementById('incoming-call')
        $(incoming_call).show();
        incoming_call.srcObject = call.remoteMediaStream;
        outgoing_call = document.getElementById('outgoing-call')
        $(outgoing_call).show();
        outgoing_call.srcObject = call.localMediaStream;
        $(".sparklive-widget-call-btn").hide();
        $(".sparklive-widget-end-call-btn").show();
      });
  })
});

$(".sparklive-widget-end-call-btn").click(function() {
  call.hangup();
  $(".sparklive-widget-call-btn").show()
  $(".sparklive-widget-end-call-btn").hide()
  $(incoming_call).hide();
  $(outgoing_call).hide();
  //#todo togoogle sending audio and video
})
var curLen = 0;
var refresh = function() {
    $.getJSON(sparklive_url+'/get_messages?client_id=' + client_id + "&visitor_id="+visitor_id,
        function(result) {
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
                    visitor_id: visitor_id
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
init();