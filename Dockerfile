FROM alpine
COPY count404.sh /usr/local/bin/count404.sh
RUN chmod +x /usr/local/bin/count404.sh
CMD ["/usr/local/bin/count404.sh"]
