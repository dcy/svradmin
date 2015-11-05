import Util from "./util"
var version_id = $('#data').data("version_id") 
console.log(version_id)

var model = avalon.define({
    $id: "version_detail",
    all_issues: [],
    issues: [],
    issues_amount: 0,
    to_add: function() {
        location.href = "/issues/new?version_id=" + version_id
    }
})

$.get("/version_issues/" + version_id,
      {unixtime: Util.unixtime()},
      function(data) {
          console.log("****data", data)
          var issues = data.issues
          model.all_issues = issues
          model.issues = issues
          refresh_issues_amount()
      }

     )

function refresh_issues_amount() {
    model.issues_amount = model.issues.length
}

