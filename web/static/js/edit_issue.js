import Util from "./util"

var issue_id = $('#data').data("issue_id")

var model = avalon.define({
    $id: "issue",
    issue: {id: "", version_id: "", title: "", content: "", designer_id: "", is_done_design: "", frontend_id: "", backend_id: "", remark: ""},
    designer_states: Util.designer_states(),
    versions: [],
    designers: []
})

$.get("/get_versions",
      function(data) {
          model.versions = data.versions
      }
     )

$.get("/get_users",
      function(data) {
         model.designers = data.users 
      }
     )

$.get("/get_issue/" + issue_id,
      function(data) {
          model.issue = data.issue
          $('#designer_id').val(model.issue.designer_id).trigger("change")
          $('#version_id').val(model.issue.version_id).trigger("change")
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
         var version_id = $('#version_id').val()
         issue_vals.version_id = version_id 
         if (issue_vals.frontend_id.length == 0) {
             issue_vals.frontend_id = 0
         }
         if (issue_vals.backend_id.length == 0) {
             issue_vals.backend_id = 0
         }
         $.ajax({
             type: "put",
             url: "/issues/" + issue_id,
             data: {issue: issue_vals, _csrf_token: Util.csrf_token},
             success: function(data) {
                 if (data.result == "success") {
                     Util.msg_sth("成功修改")
                     Util.vex_confirm("返回列表", function() {
                         window.location.href = "/versions/" + version_id
                     })
                 }
                 else if (data.result == "fail") {
                     Util.vex_alert_error("添加失败！")
                 }
                 $('button[data-loading-text]').button('reset')
             }
         })

         //$.put("/issues/" + issue_id,
         //       {issue: issue_vals, _csrf_token: Util.csrf_token},
         //       function(data) {
         //           if (data.result == "success") {
         //               Util.msg_sth("成功修改")
         //               Util.vex_confirm("返回列表", function() {
         //                   window.location.href = "/versions/" + version_id
         //               })
         //           }
         //           else if (data.result == "fail") {
         //               Util.vex_alert_error("添加失败！")
         //           }
         //           $('button[data-loading-text]').button('reset')
         //       })
     })

 })
