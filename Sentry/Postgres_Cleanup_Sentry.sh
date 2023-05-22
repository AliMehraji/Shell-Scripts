#! /bin/bash 

set -xe 

psql -U postgres -h localhost -c "DELETE FROM public.nodestore_node WHERE timestamp < NOW() - INTERVAL '7';"
psql -U postgres -h localhost -c "VACUUM FULL public.nodestore_node;"
