FROM lacledeslan/steamcmd:linux AS content-assembler

ARG contentServer=content.lacledeslan.net

# Download Custom LL TF2 Classified Content
RUN if [ "$contentServer" = false ] ; then \
        echo "\n\nSkipping LL custom content\n\n"; \
    else \
        echo "\nDownloading custom maps from $contentServer" &&\
                mkdir --parents /tmp/maps/ /output &&\
                cd /tmp/maps/ &&\
                wget -rkpN -l 1 -nH  --no-verbose --cut-dirs=3 -R "*.htm*" -e robots=off "http://"$contentServer"/fastDownloads/tf2-class/maps/" &&\
            echo "Decompressing files" &&\
                bzip2 --decompress /tmp/maps/*.bz2 &&\
            echo "Moving uncompressed files to destination" &&\
                mkdir --parents /output/tf2classified/tf2classified/maps/ &&\
                mv --no-clobber *.bsp /output/tf2classified/tf2classified/maps/; \
    fi;

COPY ./dist/sourcemod.linux /output/tf2classified/tf2classified/

COPY ./dist/sourcemod-configs /output/tf2classified/tf2classified/

COPY ./dist/linux-x64/ll-tests /output/tf2classified/ll-tests/

COPY ./dist/tf2classified /output/tf2classified/tf2classified/

FROM lacledeslan/gamesvr-tf2classified

HEALTHCHECK NONE

ARG BUILDNODE="unspecified"
ARG SOURCE_COMMIT

LABEL maintainer="Laclede's LAN <contact @lacledeslan.com>" \
      com.lacledeslan.build-node=$BUILDNODE \
      org.label-schema.schema-version="1.0" \
      org.label-schema.url="https://github.com/LacledesLAN/README.1ST" \
      org.label-schema.vcs-ref=$SOURCE_COMMIT \
      org.label-schema.vendor="Laclede's LAN" \
      org.label-schema.description="LL Team Fortress 2 Classified Dedicated Freeplay Server" \
      org.label-schema.vcs-url="https://github.com/LacledesLAN/gamesvr-tf2-freeplay"

COPY --chown=TF2classified:root --from=content-assembler /output /app

# UPDATE USERNAME & ensure permissions

RUN usermod -l TF2classifiedFreeplay TF2classified &&\
    usermod -d /app/tf2classified/ TF2classifiedFreeplay &&\
    chmod +x /app/tf2classified/ll-tests/*.sh;

USER TF2classifiedFreeplay

WORKDIR /app/tf2classified/

CMD ["/bin/bash"]

ONBUILD USER root
