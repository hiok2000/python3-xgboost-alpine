FROM python:3.6-alpine

ENV PYTHONUNBUFFERED=0

COPY ./ app/

RUN apk add ca-certificates freetds-dev g++ gcc unixodbc-dev cython
RUN pip install --upgrade pip
RUN pip install cython
RUN pip install pymssql
#RUN pip install -r /app/requirements.txt

RUN apk add --update --no-cache \
    --virtual=.build-dependencies \
    git && \
    mkdir /src && \
    cd /src && \
    git clone --recursive https://github.com/dmlc/xgboost && \
    sed -i '/#define DMLC_LOG_STACK_TRACE 1/d' /src/xgboost/dmlc-core/include/dmlc/base.h && \
    sed -i '/#define DMLC_LOG_STACK_TRACE 1/d' /src/xgboost/rabit/include/dmlc/base.h && \
    apk del .build-dependencies

RUN apk add --update --no-cache \
    --virtual=.build-dependencies \
    make gfortran \
    python3-dev \
    py-setuptools g++ && \
    apk add --no-cache openblas lapack-dev libexecinfo-dev libstdc++ libgomp && \
    pip install numpy && \
    pip install scipy && \
    pip install pandas scikit-learn && \
    ln -s locale.h /usr/include/xlocale.h && \
    cd /src/xgboost; make -j4 && \
    cd /src/xgboost/python-package && \
    python3 setup.py install && \
    rm /usr/include/xlocale.h && \
    rm -r /root/.cache && \
    rm -rf /src && \
    apk del .build-dependencies


WORKDIR /app

CMD [ "python", "--version" ]
