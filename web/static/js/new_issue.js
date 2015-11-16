import Util from "./util"

$(".basic-select2").select2()

var version_id = $('#data').data('version_id')

var empty_designer_info = {designer_id: "", is_done_design: ""}
var model = avalon.define({
    $id: "new_issue",
    issue: {title: "", content: "", designer_id: 1, is_done_design: 1, designer_infos: [], frontend_ids: "", backend_ids: "", remark: ""},
    designer_states: Util.designer_states(),
    to_show: function() {
        location.href = "/versions/" + version_id
    },
    designers: [],
    designer_infos: [empty_designer_info],
    to_add_designer_info: function() {
        model.designer_infos.push(Util.copy_obj(empty_designer_info))
    }
})


$.get("/get_users",
      function(data) {
          model.designers = data.users 
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
         issue_vals.version_id = version_id
         issue_vals.designer_infos = model.designer_infos.$model
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
