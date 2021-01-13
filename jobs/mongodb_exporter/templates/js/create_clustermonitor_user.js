<%- if p('mongodb.clustermonitor.create') == true -%>
if (db.system.users.find({ user: "<%= p('mongodb.clustermonitor.username') %>" }).count() == 0) {
    db.createUser({
        user: "<%= p('mongodb.clustermonitor.username') %>",
        pwd: "<%= p('mongodb.clustermonitor.password') %>",
        roles: [
            { role: "clusterMonitor", db: "admin" },
        	{ role: "read", db: "local" }
        ]
    });
} else {
    db.changeUserPassword("<%= p('mongodb.clustermonitor.username') %>", "<%= p('mongodb.clustermonitor.password') %>");
}
<%- end -%>