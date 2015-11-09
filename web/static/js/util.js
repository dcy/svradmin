//vex.dialog.buttons.YES.text = '确定'
//vex.dialog.buttons.NO.text = '取消'
//
//$('input[maxlength]').maxlength()
//$('textarea[maxlength]').maxlength()
//
//$('button[data-loading-text]').click(function () {
//    var btn = $(this).button('loading')
//    //setTimeout(function () {
//    //    btn.button('reset');
//    //}, 3000);
//})
//
//Messenger.options = {
//    extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
//    theme: 'future'
//}
//
//var datas = get_url_datas()
//var content
//if (datas.content) {
//    content = decodeURI(datas.content)
//}
//else {
//    content = ""
//}
//
//function get_url_datas()
//{
//    var aQuery = window.location.href.split("?");  //取得Get参数
//    var aGET = new Object();
//    if(aQuery.length > 1) {
//        var aBuf = aQuery[1].split("&");
//        for(var i=0, iLoop = aBuf.length; i<iLoop; i++) {
//            var aTmp = aBuf[i].split("=");  //分离key与Value
//            aGET[aTmp[0]] = aTmp[1];
//        }
//    }
//    return aGET;
//}
//
//function redirect_404()
//{
//    location.href = "/pages/not_found";
//}
//
//function msg_sth(something)
//{
//    Messenger().post({
//        message: something,
//        showCloseButton: true
//    });
//}
//
//function vex_alert_error(what) {
//    var message = '<div class="text-center text-danger">' + what + '</div>';
//    vex.dialog.alert({message: message});
//}
//
//function vex_confirm(what, callback) {
//    var message = '<div class="text-center text-danger">' + what + '</div>';
//    vex.dialog.confirm({
//        message: message,
//        callback: callback
//    });
//}
//
//function randomNumber(min, max) {
//    return Math.floor(Math.random() * (max - min + 1) + min);
//};
//
//// Generate a sum of two random numbers
//function generateCaptcha() {
//    $('#captchaOperation')
//    .html([randomNumber(1, 100), '+', randomNumber(1, 100), '='].join(' '));
//}
//
//function unixtime() {
//    return new Date().getTime();
//}
//
//function handle_general_error(result) {
//    if (result == "not_login"){
//        location.href = "/account/login";
//        return
//    }
//    else if (result =="not_found"){
//        vex_alert_error("你所要访问的东西不存在");
//        return
//    }
//}

let Util = {
    csrf_token: $('#_csrf_token').val(),
    is_login: $("#svr-data").data("is_login"),
    get_url_datas(){
        var aQuery = window.location.href.split("?")  //取得Get参数
        var aGET = new Object()
        if(aQuery.length > 1) {
            var aBuf = aQuery[1].split("&")
            for(var i=0, iLoop = aBuf.length; i<iLoop; i++) {
                var aTmp = aBuf[i].split("=")  //分离key与Value
                aGET[aTmp[0]] = aTmp[1]
            }
        }
        return aGET
    },

    generateCaptcha() {
        $('#captchaOperation')
        .html([this.randomNumber(1, 100), '+', this.randomNumber(1, 100), '='].join(' '))
    },

    redirect_404() {
        location.href = "/pages/not_found"
    },

    msg_sth(something) {
        Messenger().post({
            message: something,
            showCloseButton: true
        })
    },

    vex_alert_error(what) {
        var message = '<div class="text-center text-danger">' + what + '</div>'
        vex.dialog.alert({message: message})
    },
    
    vex_confirm(what, callback) {
        var message = '<div class="text-center text-danger">' + what + '</div>'
        vex.dialog.confirm({
            message: message,
            callback: callback
        })
    },

    randomNumber(min, max) {
        return Math.floor(Math.random() * (max - min + 1) + min)
    },

    unixtime() {
        return new Date().getTime()
    },

    handle_general_error(result) {
        if (result == "not_login"){
            location.href = "/account/login"
            return
        }
        else if (result =="not_found"){
            vex_alert_error("你所要访问的东西不存在")
            return
        }
    },

    issue_states() {
        return [{id: 1, name: "程序完成"}, {id: 2, name: "程序未完"}, {id: 3, name: "已关闭"}]
    },

    designer_states() {
        return [{name: "已完成", value: 1}, {name: "未完成", value: 0}, {name: "不需要", value: -1}]
    }
}
export default Util
