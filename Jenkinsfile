node {
  stage 'Build'
  def app = docker.build("adaengineering/elasticsearch")
  stage 'Push'
  app.push("${env.BRANCH_NAME}-${env.BUILD_NUMBER}")
  app.push("${env.BRANCH_NAME}-latest")
}
