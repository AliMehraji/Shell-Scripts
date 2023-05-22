# Postgresql database  Cleanup in Sentry

### Run manually

> Put This File in Root home directory in docker container.
> if Docker restarted or container is recreated and file will be deleted in container.

```
docker exec `docker ps | grep postgres | awk '{print $1}'` /bin/bash /Postgre_cleanup.sh 
```

### Cronjob
```
42 2 * * 5 docker exec `docker ps | grep postgres | awk '{print $1}'` /bin/bash /Postgre_cleanup.sh > /var/log/postgres_cleanup.log 2>&1
```


## [Self-Hosted Troubleshooting](https://develop.sentry.dev/self-hosted/troubleshooting "TroubleShoot")

