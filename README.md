# bash-toolbox

Scripts I wrote while learning Linux and Docker.

- count404.sh: counts 404s in the nginx log files, with 3 checks: readable, exists but locked, doesn't exist
- count404.service + count404.timer: systemd unit files that run count404.sh daily at 3 AM
- Dockerfile: runs count404.sh in an alpine-based image (script switched to sh to keep the image small)

- Ran count404 in docker through "docker run --rm -v ~/logs:/var/log/nginx:ro count404

- the -v here means --> /var/log/nginx looks inside ~/logs and :ro means read-only so we make sure the logs aren't modified

- this command runs the count404.sh so it runs on the paths which is on the script 

- expected output:

/var/log/nginx/access.log 
0 
/var/log/nginx/access.log-20261105 
3 
/var/log/nginx/banana.log that file doesnt exist  
