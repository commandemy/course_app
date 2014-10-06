default['course_roles']['database_server'] = "database_server"
default['course_roles']['jenkins_server'] = "jenkins_server"

default['database']['prod']['username'] = 'course_app'
default['database']['prod']['password'] = 'supersecret'
default['database']['prod']['dbname'] = 'course_app_prod'

default['pvpnet']['should_migrate'] = true
default['pvpnet']['force_deploy'] = true