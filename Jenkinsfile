node {
    def image_name = 'adaengineering/elasticsearch'
    sh 'git --no-pager log -1 --format=%an > committer.txt'
    def changes_by = readFile('committer.txt').trim()
    try {
        stage 'Checkout'
        checkout scm

        stage 'Build'
        def app = docker.build("${image_name}")

        stage 'Push'
        app.push("${env.BRANCH_NAME}-${env.BUILD_NUMBER}")
        app.push("${env.BRANCH_NAME}-latest")
        sh 'env'
        slackSend channel: '#ci-cd', color: 'good', message: "Pushed ${image_name}:${env.BRANCH_NAME}-${env.BUILD_NUMBER} with changes by ${changes_by}", teamDomain:              'projectada', token: 'eqVk8oJI8eMqp8eCaLWXwmfI'
        sh "curl http://artemis.ada.engineering:5000/newimage/${image_name}/${env.BRANCH_NAME}/${env.BUILD_NUMBER}"
    } catch (err) {
        slackSend channel: '#ci-cd', color: 'danger', message: "Failure building ${image_name}: ${err}\n(changes by ${changes_by})\n${env.BUILD_URL}", teamDomain: 'projectada',   token: 'eqVk8oJI8eMqp8eCaLWXwmfI'
    }
}
