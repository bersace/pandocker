# A simple Pandoc machine for pandoc with filters, fonts and the latex bazaar
#
# Based on :
#    https://github.com/jagregory/pandoc-docker/blob/master/Dockerfile
#    https://github.com/geometalab/docker-pandoc/blob/develop/Dockerfile
#    https://github.com/vpetersson/docker-pandoc/blob/master/Dockerfile

FROM debian:stretch-slim

# Pandoc Version
ENV PANDOC_SOURCE https://github.com/jgm/pandoc/releases/
ENV PANDOC_VERSION 1.19.2
ENV DEBIAN_REVISION ${PANDOC_VERSION}-1

# Set the env variables to non-interactive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical
ENV DEBCONF_NOWARNINGS yes

#
# Debian 
#
RUN apt -qq update && \
    # for deployment
    apt -qq -y install rsync openssh-client && \	
    # latex toolchain 
    apt -qq -y install texlive texlive-xetex && \
    # fonts
    apt -qq -y install fonts-lato && \
    # build tools
    apt -qq -y install parallel git wget tar xz-utils python-setuptools && \
    # required by pandoc-latex-tip
    apt -qq -y install python-imaging libjpeg62-turbo-dev libfreetype6 libfreetype6-dev && \
    # required by panflute
    apt -qq -y install python3 python3-dev python3-pip python3-virtualenv && \		
    # required for PDF meta analysis
    apt -qq -y install poppler-utils && \		
    # clean up
    apt clean && \
    rm -rf /var/lib/apt/lists/*

#
# SSH pre-config / useful for Gitlab CI
#
RUN mkdir -p ~/.ssh && \
    echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

#
# Install pandoc from github / debian package is too old 
#
RUN wget -O pandoc.deb ${PANDOC_SOURCE}/download/${PANDOC_VERSION}/pandoc-${DEBIAN_REVISION}-amd64.deb && \
    dpkg --install pandoc.deb

#
# Pandoc filters
#
RUN easy_install pip && \
    pip install pandocfilters \
    		pandoc-latex-environment \
                pandoc-latex-barcode \
                pandoc-latex-levelup \
                pandoc-dalibo-guidelines \ 
                icon_font_to_png \
                pypdf2  
 
# https://github.com/chdemko/pandoc-latex-tip/issues/1
RUN pip install git+https://github.com/chdemko/pandoc-latex-tip.git --egg

# planflute does not like python2
RUN pip3 install panflute \
		 pandoc-latex-admonition

# Additional Python modules
#RUN pip install pypdf2  

# Install wkhtmltopdf
# ENV WKHTMLTOX https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
# RUN wget -O wkhtmltox.tar.xz ${WKHTMLTOX} && \
#     tar -xf wkhtmltox.tar.xz
# ENV PATH ${PATH}:/wkhtmltox/bin

# Entrypoint
RUN mkdir /pandoc
WORKDIR /pandoc
ENTRYPOINT ["pandoc"]
