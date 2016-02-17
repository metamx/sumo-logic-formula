/etc/sumo:
  file.directory:
    - user: root
    - group: root
    - mode: 555

/etc/sumo/sources.json:
  file.managed:
    - user: root
    - group: root
    - mode: 400
    - template: py
    - source: salt://sumologic/files/sources.json

/etc/sumo.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 400
    - template: jinja
    - source: salt://sumologic/files/sumo.config
    - requires:
      - file: /sumo

sumocollector:
  pkg.installed:
    - sources:
      - sumocollector: https://collectors.sumologic.com/rest/download/deb/64

/opt/SumoCollector/config/wrapper.conf:
  file.managed:
    - pattern: |
        ^wrapper.java.maxmemory=.*$
    - repl: |
        wrapper.java.maxmemory={{ salt["pillar.get"]("sumologic_install:javamaxmemory", 128) }}
    - watch_in:
      - service: collector

collector:
  service.running:
    - enable: True
    - watch:
      - pkg: sumocollector
      - file: /etc/sumo.conf
      - file: /etc/sumo/sources.json
