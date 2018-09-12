if (db.system.users.find({ user: <%= %> }).count() == 0) {
    db.createUser({
        user: getDeploymentVar("<%= %>"),
        pwd: getDeploymentVar("<%= %>"),
        roles: [
            { role: "clusterMonitor", db: "admin" },
        	{ role: "read", db: "local" }
        ]
    });
} else {
    db.changeUserPassword(getDeploymentVar("<%= %>"), getDeploymentVar("<%= %>"));
}