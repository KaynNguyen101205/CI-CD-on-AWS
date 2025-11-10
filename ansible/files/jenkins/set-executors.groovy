import jenkins.model.Jenkins

// Keep Jenkins light for t2.micro. Only one executor runs jobs.
Jenkins jenkinsInstance = Jenkins.get()
if (jenkinsInstance != null) {
    int desiredExecutors = 1
    if (jenkinsInstance.getNumExecutors() != desiredExecutors) {
        jenkinsInstance.setNumExecutors(desiredExecutors)
        jenkinsInstance.save()
        println("Set master executors to " + desiredExecutors)
    } else {
        println("Jenkins already at " + desiredExecutors + " executor")
    }
}

