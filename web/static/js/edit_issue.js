import Util from "./util"

var issue_id = $('#data').data("issue_id")
console.log("******", issue_id)

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
          console.log("******issue", data.issue)
          model.issue = data.issue
          $('#designer_id').val(model.issue.designer_id).trigger("change")
          $('#version_id').val(model.issue.version_id).trigger("change")
      }
     )

