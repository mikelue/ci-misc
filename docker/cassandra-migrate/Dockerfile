FROM python:alpine

RUN pip3 install --no-cache-dir --upgrade pip

# Because the installation of driver would take almost 10 minites,
# follownig option would speed it up.
RUN CASS_DRIVER_NO_CYTHON=1 pip3 install --no-cache-dir cassandra-driver cassandra-migrate

COPY entrypoint.sh /.

ENTRYPOINT ["/entrypoint.sh"]
