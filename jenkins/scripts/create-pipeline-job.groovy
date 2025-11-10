import hudson.plugins.git.BranchSpec
import hudson.plugins.git.GitSCM
import hudson.plugins.git.UserRemoteConfig
import jenkins.model.Jenkins
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import org.jenkinsci.plugins.workflow.job.WorkflowJob

String jobName = System.getenv('JENKINS_PIPELINE_NAME') ?: 'sample-next-app-pipeline'
String repoUrl = System.getenv('PIPELINE_GIT_REPO')
String gitCredentialsId = System.getenv('PIPELINE_GIT_CREDENTIALS') ?: ''
String branch = System.getenv('PIPELINE_GIT_BRANCH') ?: '*/main'

if (!repoUrl) {
    println "Set PIPELINE_GIT_REPO to the Git URL that hosts the Jenkinsfile."
    return
}

Jenkins jenkins = Jenkins.instance
WorkflowJob job = jenkins.getItem(jobName) as WorkflowJob

if (job == null) {
    job = jenkins.createProject(WorkflowJob, jobName)
    println "Created pipeline job '${jobName}'."
} else {
    println "Updating existing pipeline job '${jobName}'."
}

def gitConfigs = [new UserRemoteConfig(repoUrl, null, null, gitCredentialsId ? gitCredentialsId : null)]
def scm = new GitSCM(
    gitConfigs,
    [new BranchSpec(branch)],
    false,
    [],
    null,
    null,
    []
)

def definition = new CpsScmFlowDefinition(scm, "Jenkinsfile")
definition.setLightweight(true)
job.definition = definition
job.save()

println "Pipeline job '${jobName}' now tracks ${repoUrl} (${branch})."

