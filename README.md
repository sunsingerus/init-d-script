# init-d-script
init.d script template

# systemd
Put service file into `/etc/systemd/system/`
Check service status with
```bash
systemctl status <service name>
```

In case servuce is `disbaled` - need to enable it
```bash
systemctl enable <service name>
```

and check status again
```bash
systemctl -l status <service name>
```

In case service is `inactive` - need to start it
```bash
 systemctl start <service name>
```

and check status again
```bash
systemctl -l status <service name>
```

Upon each service file change do not forget to reload `systemd` with
```bash
systemctl daemon-reload
```

