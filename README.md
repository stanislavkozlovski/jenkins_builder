# jenkins_builder
A command-line application which helps you build jenkins jobs through the cli, specifically catered towards the build setup we have at work.
That is, a single step in the build, with parameters that indicate which build/environment you want


# Sample Usage
```shell
> enether$ bundle exec ruby builder.rb application_name -j EVO-125
[INFO][16:11:54.978] [2017-11-29 16:11:54 +0100] Starting build #325 for application_name
[2017-11-29T16:11:54.978160 #68559]  INFO -- : Building job 'application_name' with parameters: {:BUILD_BRANCH=>"develop", :ENVIRONMENT=>"alpha"}
[INFO][16:16:26.960] Job #325 of application_name has ended with status SUCCESS
```
This builds the job, tries to find a JIRA ticket with that tag and comment on it

# How to set up
First off, to be able to connect to Jenkins/JIRA, you will need to provide your credentials.

### 0. Make sure you are using Ruby 2.4
### 1. Create a `.env` file in the base directory
That file should have the following variables - 
```
JENKINS_URL=https://ci.yourcompany.com
JENKINS_USERNAME=enether@github.com
JENKINS_API_TOKEN=4t24tfefr31f244
GOOGLE_USERNAME=enether@gmail.com
GOOGLE_PASSWORD=your_pw
```
Your google credentials are needed to log in to JIRA. Logging in with JIRA credentials is currently not supported.
If you do not plan to use the `-j` command to comment on a ticket after a successful build, you can skip adding your Google credentials.

### 2. Create a `options.yml` file in the base directory
Sample contents of that file
```yaml
builds:
  jenkins_meta_options:
    branch_parameter: BUILD_BRANCH
    environment_parameter: ENVIRONMENT 
  app1:
    name: Application-1
    default_env: staging
    staging:
      name: application-1
      default_branch: master
  app2:
    name: Application-1
    default_env: staging
    staging:
      name: application-1
      default_branch: master
    testing:
      name: application-1-test
      default_branch: master

jira:
  base_url: company.atlassian.net
  default_comment: On staging
```
Where the `builds` keys are the names of the applications with which you wil reference them.
For example, given the yaml above, building the first application would be done through:
```shell
> enether$ bundle exec ruby builder.rb app1
```
This will build the application and send the parameters `{BUILD_BRANCH: master, ENVIRONMENT: staging}`

### 3. (Optional) Install `chromedriver` and add it to your PATH
This is needed for Selenium to run, for commenting on JIRA tickets. If you never run the `-j` option for JIRA commenting, you will not need this

### 4. Run `bundle install`
