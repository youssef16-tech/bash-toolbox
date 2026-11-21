# bash-toolbox

Scripts I wrote while learning Linux and Docker.

- errors.sh: counts 404 errors in nginx's access.log
- count404.sh: counts 404s in the nginx log files, with 3 checks: readable, exists but locked, doesn't exist
- count404.service + count404.timer: systemd unit files that run count404.sh daily at 3 AM
- Dockerfile: runs count404.sh in an alpine-based image (script switched to sh to keep the image small)
