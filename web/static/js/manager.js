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

var _csrf_token = $('#_csrf_token').val()

$(".reload_confs").click(function(){
    if (is_login){
        var cur_svr_id = $(this).attr('svr-id')
        var timestamp = new Date().getTime()
        $.post("/reload_confs",
               {svr_id: cur_svr_id, time: timestamp, _csrf_token: _csrf_token},
               function(data){
                   $('.reload_confs').button('reset')
                   var result = data.result
                   var remark = data.remark
                   if (result == "serverNotLive"){
                       vex_alert_error("不能连接服务器，服务器未开启或者异常!")
                   }
                   else if (result == "success"){
                       vex_confirm("成功热更", function() {
                           location.reload()
                       })
                   }
                   else if (result == "makeFail") {
                       vex_alert_error("代码编译错误: " + remark)
                   }
                   else if (result == "validateFail") {
                       vex_alert_error("数据校验不过: " + remark)
                   }
               }
              )
    }
    else{
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
                   var remark = data.remark
                   if (result == "serverNotLive"){
                       vex_alert_error("不能连接服务器，服务器未开启或者异常!")
                   }
                   else if (result == "success"){
                       vex_confirm("成功热更", function() {
                           location.reload()
                       })
                   }
                   else if (result == "makeFail") {
                       vex_alert_error("代码编译错误: " + remark)
                   }
                   else if (result == "validateFail") {
                       vex_alert_error("数据校验不过: " + remark)
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

$("#changePassword").click(function() {
    $("#change_password").modal("toggle")
})

$("#to_change_password").click(function() {
    var ori_password = $("#ori_password").val()
    var new_password = $("#new_password").val()
    if (ori_password.length == 0 || new_password.length == 0) {
        vex_alert_error("密码不能为空")
        return
    }
    if (ori_password == new_password) {
        vex_alert_error("新旧密码不能一样")
        return
    }
    $.post("/change_password",
           {ori_password: ori_password, new_password: new_password, _csrf_token: _csrf_token},
           function(data) {
               var result = data.result
               if (result == "success") {
                   vex_alert_error("修改成功: " + new_password)
               }
               else if(result == "oriPasswordWrong") {
                   vex_alert_error("密码错误")
               }
           }
          )
})
