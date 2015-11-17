import Util from "./util"

var issue_id = $('#data').data("issue_id")
console.log("is_login", Util.is_login)

var empty_designer_info = {designer_id: "", is_done_design: ""}
var model = avalon.define({
    $id: "issue",
    issue: {id: "", version_id: "", title: "", content: "", designer_id: "", is_done_design: "", designer_infos: [], frontend_ids: "", backend_ids: "", remark: ""},
    designer_states: Util.designer_states(),
    versions: [],
    designers: [],
    to_show: function() {
        location.href = "/newest_version"
    },
    to_add_designer_info: function() {
        model.issue.designer_infos.push(Util.copy_obj(empty_designer_info))
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
                     regexp: {regexp: "^[0-9\,]+$", message: '只能是数字'}
                 }
             },
             backend_ids: {
                 validators: {
                     regexp: {regexp: "^[0-9\,]+$", message: '只能是数字'}
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
         //issue_vals.designer_id = $('#designer_id').val()
         var version_id = $('#version_id').val()
         console.log("issue_vals", issue_vals)
         issue_vals.version_id = version_id 
         issue_vals.designer_infos = select_valid_designer_infos(issue_vals.designer_infos)
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

 function select_valid_designer_infos(designer_infos) {
     var infos = new Array()
     for (var i in designer_infos) {
         var item = designer_infos[i]
         console.log("item", item)
         if (item.designer_id != "" && item.is_done_design != "") {
             infos.push(item)
         } 
     }
     return infos
 }
