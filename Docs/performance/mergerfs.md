```/etc/systemd/system/mnt-temp.service
[Unit]
Description=MergerFS Pool (/mnt/temp)
After=local-fs.target
RequiresMountsFor=/mnt/12tb/temp /mnt/10tb/121

[Service]
Type=simple
ExecStart=/usr/bin/mergerfs -f \
  -o allow_other,cache.files=off,category.create=epmfs,func.getattr=newest,dropcacheonclose=false \
  /mnt/12tb/temp:/mnt/10tb/121 \
  /mnt/temp

ExecStop=/usr/bin/fusermount3 -u /mnt/temp

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```
