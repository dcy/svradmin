import Util from "./util"

var version_id = $('#data').data("version_id") 

var model = avalon.define({
    $id: "version_detail",
    all_issues: [],
    versions: [],
    version: {id: "", name: ""},
    issues: [],
    issues_amount: 0,
    developers: [],
    states: Util.issue_states(),
    to_edit: function(issue) {
        if (Util.is_login) {
            location.href = "/issues/" + issue.id + "/edit"
        }
        else {
            location.href = "/login"
        }
    },
    to_add_version: function() {
        if (Util.is_login) {
            location.href = "/versions/new"
        }
        else {
            location.href = "/login"
        }
    },
    del_issue: function(issue, remove_fun) {
        if (Util.is_login) {
            Util.vex_confirm("确定删除该工作任务 " + issue.title + " 吗?", function(value) {
                if (value) {
                    $.ajax({
                        type: "DELETE",
                        url: "/issues/" + issue.id,
                        data: {_csrf_token: Util.csrf_token},
                        success: function(data) {
                            if (data.result == "success") {
                                Util.msg_sth("成功删除")
                                remove_fun()
                                var new_issues = new Array()
                                for (var x in model.all_issues.$model) {
                                    var item = model.all_issues.$model[x]
                                    if (item.id != issue.id) {
                                        new_issues.push(item)
                                    }
                                }
                                model.all_issues = new_issues 
                                refresh_issues_amount()
                            }
                        }
                    })
                }
            })
        }
        else {
            location.href = "/login"
        }
    },
    to_add: function() {
        if (Util.is_login) {
            location.href = "/issues/new?version_id=" + version_id
        }
        else {
            location.href = "/login"
        }
    }
})

$.get("/version_issues/" + version_id,
      {unixtime: Util.unixtime()},
      function(data) {
          var issues = data.issues
          model.all_issues = issues
          model.issues = issues
          refresh_issues_amount()
          filter_developers()
          //$('#version_id').val(version_id).trigger("change")
      }
     )

function filter_developers() {
    var developers = new Array()
    for (var i in model.all_issues.$model) {
        var item = model.all_issues.$model[i]
        var frontend_name = item.frontend_state.developer_name
        if (frontend_name.length != 0) {
            if (developers.indexOf(frontend_name) == -1) {
                developers.push(frontend_name)
            }
        }
        var backend_name = item.backend_state.developer_name
        if (backend_name.length != 0) {
            if (developers.indexOf(backend_name) == -1) {
                developers.push(backend_name)
            }
        }
    }
    model.developers = developers
}

function refresh_issues_amount() {
    model.issues_amount = model.issues.length
}

$.get("/get_versions",
      function(data) {
          model.versions = data.versions
      }
     )

$("#version_id").on("select2:select", function(e) {
  var version_id = e.params.data["id"]
  location.href = "/versions/" + version_id
})

$('#developer').on("select2:select", function(e) {
    $('#state').val("all").trigger("change")
    var developer = $('#developer').val()
    if (developer == "all") {
        model.issues = model.all_issues
    }
    else {
        var selected_issues = new Array()
        for (var i in model.all_issues.$model) {
            var item = model.all_issues.$model[i]
            var frontend_name = item.frontend_state.developer_name
            var backend_name = item.backend_state.developer_name
            if (frontend_name == developer || backend_name == developer) {
                selected_issues.push(item)
            }
        }
    model.issues = selected_issues
    }
    refresh_issues_amount()
})

$('#state').on("select2:select", function(e) {
    $('#developer').val("all").trigger("change")
    var state = $('#state').val()
    if (state == "all") {
        model.issues = model.all_issues
    }
    else if (state == 1) {
        var selected_issues = new Array()
        for (var i in model.all_issues.$model) {
            var issue = model.all_issues.$model[i]
            if (is_issue_done(issue)) {
                selected_issues.push(issue)
            }
        }
        model.issues = selected_issues
        refresh_issues_amount()
    }
    else if (state == 2) {
        var selected_issues = new Array()
        for (var i in model.all_issues.$model) {
            var issue = model.all_issues.$model[i]
            if (!is_issue_done(issue)) {
                selected_issues.push(issue)
            }
        }
        model.issues = selected_issues
        refresh_issues_amount()
    }
    else {
        var selected_issues = new Array()
        for (var i in model.all_issues.$model) {
            var issue = model.all_issues.$model[i]
            if (is_issue_close(issue)) {
                selected_issues.push(issue)
            }
        }
        model.issues = selected_issues
        refresh_issues_amount()
    }
})

function is_issue_done(issue) {
    var frontend_state = issue.frontend_state
    var backend_state = issue.backend_state
    return is_state_done(frontend_state.status_name) && is_state_done(backend_state.status_name)
}

function is_issue_close(issue) {
    var frontend_state = issue.frontend_state
    var backend_state = issue.backend_state
    return is_state_close(frontend_state.status_name) && is_state_close(backend_state.status_name)
}

function is_state_done(state_name) {
    if (state_name == "") {
        return true
    }
    else if (state_name=="可验收" || state_name=="可测试" || state_name=="已关闭") {
        return true
    }
    else {
        return false
    }
}

function is_state_close(state_name) {
    if (state_name == "") {
        return true
    }
    else if (state_name == "已关闭") {
        return true
    }
    else {
        return false
    }
}
