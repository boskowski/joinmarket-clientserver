FROM centos:7
SHELL ["/bin/bash", "-c"]

# dependencies
RUN yum -y groups install 'Development tools'
RUN yum -y install epel-release && \
    yum -y update
RUN yum -y install \
    python3-devel python3-pip libsodium

RUN useradd --home-dir /home/chaum --create-home --shell /bin/bash --skel /etc/skel/ chaum
ARG core_version
ARG core_dist
ARG repo_name
RUN mkdir -p /home/chaum/${repo_name}
COPY ${repo_name} /home/chaum/${repo_name}
RUN ls -la /home/chaum
RUN chown -R chaum:chaum /home/chaum/${repo_name}
USER chaum

# copy node software from the host and install
WORKDIR /home/chaum
RUN ls -la .
RUN ls -la ${repo_name}
RUN ls -la ${repo_name}/deps/cache
RUN tar xaf ./${repo_name}/deps/cache/${core_dist} -C /home/chaum
ENV PATH "/home/chaum/bitcoin-${core_version}/bin:${PATH}"
RUN bitcoind --version | head -1

# install script
WORKDIR ${repo_name}
RUN python3 -m venv jmvenv
RUN source jmvenv/bin/activate && ./test/run_tests.sh
