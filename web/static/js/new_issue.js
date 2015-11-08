import Util from "./util"

$(".basic-select2").select2()

var version_id = $('#data').data('version_id')

var model = avalon.define({
    $id: "new_issue",
    issue: {title: "", content: "", designer_id: "", is_done_design: "", frontend_id: "", backend_id: "", remark: ""},
    designer_states: Util.designer_states(),
    to_show: function() {
        location.href = "/versions/" + version_id
    },
    designers: []
})


$.get("/get_users",
      function(data) {
         model.designers = data.users 
      }
     )


 avalon.ready(function() {
     $('#issue').bootstrapValidator({
         message: 'This value is not valid',
         feedbackIcons: {
             valid: 'glyphicon glyphicon-ok',
             invalid: 'glyphicon glyphicon-remove',
             validating: 'glyphicon glyphicon-refresh'
         },
         excluded: ':disabled',
         fields: {
             title: {
                 validators: {
                     notEmpty: {message: '请输入标题'}
                 }
             },
             content: {
                 validators: {
                     notEmpty: {message: '请输入内容'}
                 }
             },
             designer_id: {
                 validators: {
                     notEmpty: {message: '请选择策划'}
                 }
             },
             is_done_design: {
                 validators: {
                     notEmpty: {message: '请选择策划案状态'}
                 }
             }
         }

     })
     .on('error.form.bv', function(e) {
         $('button[data-loading-text]').button('reset');
     })
     .on('success.form.bv', function(e) {
         e.preventDefault()
         var issue_vals = model.issue.$model
         issue_vals.designer_id = $('#designer_id').val()
         issue_vals.version_id = version_id
         if (issue_vals.frontend_id.length == 0) {
             issue_vals.frontend_id = 0
         }
         if (issue_vals.backend_id.length == 0) {
             issue_vals.backend_id = 0
         }
         $.post("/issues",
                {issue: issue_vals, _csrf_token: Util.csrf_token},
                function(data) {
                    if (data.result == "success") {
                        Util.msg_sth("成功添加")
                        Util.vex_confirm("添加成功，返回添加", function() {
                            window.location.href = "/issues/new?version_id=" + version_id
                        })
                    }
                    else if (data.result == "fail") {
                        Util.vex_alert_error("添加失败！")
                    }
                    $('button[data-loading-text]').button('reset')
                })
     })

 })
