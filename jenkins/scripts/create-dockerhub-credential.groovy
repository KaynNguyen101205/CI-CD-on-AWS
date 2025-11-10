import com.cloudbees.plugins.credentials.CredentialsScope
import com.cloudbees.plugins.credentials.SystemCredentialsProvider
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import jenkins.model.Jenkins

String credentialId = System.getenv('DOCKERHUB_CREDENTIAL_ID') ?: 'dockerhub-creds'
String username = System.getenv('DOCKERHUB_USER')
String password = System.getenv('DOCKERHUB_TOKEN')
String description = System.getenv('DOCKERHUB_DESCRIPTION') ?: 'Docker Hub push access for pipelines'

if (!username || !password) {
    println "Environment variables DOCKERHUB_USER and DOCKERHUB_TOKEN must be set before running this script."
    return
}

def store = SystemCredentialsProvider.getInstance().getStore()
def existing = store.getCredentials(Domain.global()).find { it.id == credentialId }

def credentials = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    credentialId,
    description,
    username,
    password
)

if (existing) {
    store.updateCredentials(Domain.global(), existing, credentials)
    println "Updated existing Jenkins credential '${credentialId}'."
} else {
    store.addCredentials(Domain.global(), credentials)
    println "Created new Jenkins credential '${credentialId}'."
}

SystemCredentialsProvider.getInstance().save()
Jenkins.instance?.save()

