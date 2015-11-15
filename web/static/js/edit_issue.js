import Util from "./util"

var issue_id = $('#data').data("issue_id")
console.log("is_login", Util.is_login)

var model = avalon.define({
    $id: "issue",
    issue: {id: "", version_id: "", title: "", content: "", designer_id: "", is_done_design: "", frontend_ids: "", backend_ids: "", remark: ""},
    designer_states: Util.designer_states(),
    versions: [],
    designers: [],
    to_show: function() {
        location.href = "/newest_version"
    }
})

$("input[name='frontend_ids']").tagsinput({
});
$("input[name='backend_ids']").tagsinput({
});

//$.get("/get_versions",
//      function(data) {
//          model.versions = data.versions
//      }
//     )
$.ajax({
    type: "GET",
    url: "/get_versions",
    async: false,
    success: function(data) {
        model.versions = data.versions
    }
})

//$.get("/get_users",
//      function(data) {
//         model.designers = data.users 
//      }
//     )
$.ajax({
    type: "GET",
    url: "/get_users",
    async: false,
    success: function(data) {
        model.designers = data.users
    }
})

$.get("/get_issue/" + issue_id,
      function(data) {
          console.log("data.issue", data.issue)
          model.issue = data.issue
          $('#designer_id').val(model.issue.designer_id).trigger("change")
          $('#version_id').val(model.issue.version_id).trigger("change")
          $("input[name='frontend_ids']").tagsinput('add', data.issue.frontend_ids)
          $("input[name='backend_ids']").tagsinput('add', data.issue.backend_ids)
      }
     )


 avalon.ready(function() {
     $('#issue')
     .find('[name="frontend_ids"]').change(function(e) {
         $('#issue').bootstrapValidator('revalidateField', 'frontend_ids');
     }).end()
     .find('[name="backend_ids"]').change(function(e) {
         $('#issue').bootstrapValidator('revalidateField', 'backend_ids');
     }).end()
     .bootstrapValidator({
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
             },
             frontend_ids: {
                 validators: {
                     regexp: {regexp: "^[0-9\,]+$", message: '只能是数字和","'}
                 }
             },
             backend_ids: {
                 validators: {
                     regexp: {regexp: "^[0-9\,]+$", message: '只能是数字和","'}
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
         console.log("issue_vals", issue_vals)
         issue_vals.version_id = version_id 
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
