node('docker') {

  stage('Clone repository') {
    /* Let's make sure we have the repository cloned to our workspace */
    scmenv = checkout scm
    GIT_COMMIT = scmenv.GIT_COMMIT.take(7)
  }

  stage('Build image') {
    /* This builds the actual image; synonymous to
     * docker build on the command line */
    ikats_hmi = docker.build("ikats-hmi")
  }

  stage('Push image') {
    branchName = "${env.BRANCH_NAME}".substring("${env.BRANCH_NAME}".lastIndexOf("/") + 1)

    docker.withRegistry("${env.REGISTRY_ADDRESS}", 'DOCKER_REGISTRY') {
      ikats_hmi.push(branchName + "_${GIT_COMMIT}")
      ikats_hmi.push(branchName + "_latest")
      if ("${env.BRANCH_NAME}" == "master") {
        ikats_hmi.push("latest")
      }
    }
  }

  if ("${env.BRANCH_NAME}" == "public") {
    stage ("Publish to GitHub") {


      withCredentials([[$class: 'UsernamePasswordMultiBinding',
                        credentialsId: 'tuleap_ftortora',
                        usernameVariable: 'GIT_TULEAP_USR',
                        passwordVariable: 'GIT_TULEAP_PWD'
      ]]) {
        sh '''
        set +x

        # Setting creds to git
        git remote set-url origin https://${GIT_TULEAP_USR}:${GIT_TULEAP_PWD}@tuleap-poc.si.c-s.fr/plugins/git/ikats-ops/ikats-hmi.git

        # Update existing tags
        git fetch --tags --prune origin > /dev/null

        # Connect to github
        git remote add gh https://github.com/ikats/ikats-hmi.git

        # Get the latest versions of github master
        git fetch --tags --prune gh > /dev/null
        git checkout gh/master

        # Find the missing commits to push to GitHub by looking at the latest pushed commit and
        # check the delta with current public branch
        last_gh_sha=$(git rev-parse --short gh/master)
        echo -e "\n--> Most recent commit on GitHub is ${last_gh_sha}\n"

        # Find the latest synchronized github commit sha1
        latest_pushed_commit=$(git for-each-ref --sort=taggerdate --format '%(refname)' refs/tags/pub* | tail -1 | sed 's/.*pub-//')
        echo -e "\n--> Most recent commit pushed is ${latest_pushed_commit}\n"

        # Get the list of the commmits to synchronize (to cherry-pick)
        # Loop over the commits to push (from older to newer)
        echo -e "\n--> Number of commits behind: "$(git log --oneline pub-${latest_pushed_commit}..origin/public|wc -l)"\n"
        for current_commit in $(git log --oneline pub-${latest_pushed_commit}..origin/public | cut -c1-7 | tac)
        do

          # Cherry-pick them to the GitHub branch
          # commit it directly to set the commit message corresponding to `public` branch
          if ! git cherry-pick --strategy=recursive -X theirs ${current_commit}
          then
            git add --all
            git -c core.editor=true cherry-pick --continue
          fi

          # Delete the Jenkinsfile to avoid pushing it
          rm -f Jenkinsfile && git add Jenkinsfile && git commit --amend -CHEAD --allow-empty
          github_sha1=$(git rev-parse --short HEAD)

          # Tag the public branch
          git tag -fa pub-${github_sha1} -m "Link to GitHub ${github_sha1}" ${current_commit}
          echo -e "\n--> New link : ${current_commit} bound to pub-${github_sha1}\n"

          # push the tag
          git push origin pub-${github_sha1}
        done
        '''
      }
      // Push to GitHub the new commits
      withCredentials([[$class: 'UsernamePasswordMultiBinding',
                        credentialsId: 'GitHubSA',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GIT_PASSWORD'
      ]]) {
        sh 'git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/ikats/ikats-hmi.git HEAD:master'
      }
    }
  }
}
