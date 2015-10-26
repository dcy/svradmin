$('button[data-loading-text]').click(function () {
    var btn = $(this).button('loading')
})

vex.dialog.buttons.YES.text = '确定'
vex.dialog.buttons.NO.text = '关闭'

function vex_alert_error(what) {
    var message = '<div class="text-center text-danger">' + what + '</div>'
    vex.dialog.alert({message: message})
}

function vex_confirm(what, callback) {
    var message = '<div class="text-center text-danger">' + what + '</div>'
    vex.dialog.confirm({
        message: message,
        callback: callback
    })
}

var is_login = $('#svr-data').data("is_login")
console.log("is_login ", is_login)

var _csrf_token = $('#_csrf_token').val()
console.log("_csrf_token", _csrf_token)

$(".reload_confs").click(function(){
    if (is_login){
        var cur_svr_id = $(this).attr('svr-id')
        var timestamp = new Date().getTime()
        $.post("/reload_confs",
               {svr_id: cur_svr_id, time: timestamp, _csrf_token: _csrf_token},
               function(data){
                   $('.reload_confs').button('reset')
                   var result = data.result
                   if (result == "serverNotLive"){
                       vex_alert_error("不能连接服务器，服务器未开启或者异常!")
                   }
                   else if (result == "success"){
                       vex_confirm("成功热更", function() {
                           location.reload()
                       })
                   }
                   else {
                       vex_alert_error("数据校验不过: " + result)
                   }
               }
              )
    }
    else{
        console.log("not login")
        $('.reload_confs').button('reset')
        location.href = "/login"
    }
})

$(".reload_svr").click(function(){
    if (is_login){
        var cur_svr_id = $(this).attr('svr-id')
        var timestamp = new Date().getTime()
        $.post("/reload_svr",
               {svr_id: cur_svr_id, time: timestamp, _csrf_token: _csrf_token},
               function(data){
                   $('.reload_svr').button('reset')
                   var result = data.result
                   if (result == "serverNotLive"){
                       vex_alert_error("不能连接服务器，服务器未开启或者异常!");
                   }
                   else if (result == "success"){
                       vex_confirm("成功热更", function() {
                           location.reload()
                       });
                   }
                   else {
                       vex_alert_error("数据校验不过: " + result)
                   }
               }
              );
    }
    else{
        $('.reload_svr').button('reset')
        location.href = "/login"
    }
})

$(".reset_svr").click(function() {
    if (is_login) {
        var cur_svr_id = $(this).attr('svr-id')
        vex_confirm("清除数据库，会删除所有角色及其他数据，确定清除？", function(value) {
            if (value) {
                var timestamp = new Date().getTime()
                $.post('/reset_svr',
                       {svr_id: cur_svr_id, time: timestamp, _csrf_token: _csrf_token},
                       function(data) {
                           $('.reset_svr').button('reset')
                           var result = data.result
                           if (result == "success") {
                               vex_confirm("成功清服", function() {
                                   location.reload()
                               });
                           }
                       }
                      )
            }
            else {
                $('.reset_svr').button('reset')
            }
        })
    }
    else{
        $('.reset_svr').button('reset')
        location.href = "/login"
    }
})
