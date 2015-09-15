web: bundle exec puma -t 2:1 -p ${PORT:-3000} -e ${RACK_ENV:-development}
worker: rake jobs:work
